//
//  URouter_DictionaryBruteForce.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/30/15.
//

import Foundation
/*
Router is critical part of UNode Network. The task of the router seems to be simple - select one of avaliable peers
to forward the packet to. Router also gethers information about sucessful or wrongful choices. It must learn to optimise network traffic.
Subclassing this class gives new routers that can be easly tested in this application.
*/

// This basic router selects a random peer to transmit the packet.
class URouter_DictionaryBruteForceRouting:URouterProtocol
{
    // Router's Node
    var node:UNode
    
    // Packet stack as a dictionery with packet serial as key
    var packetDict=[UInt64:DictionaryBruteForcePacketStackRecord]()
    
    // Initialisation
    init(node:UNode)
    {
        self.node=node
    }
    
    // This is main entry to the router functionality. 
    // This function chooses a peer to forward packet to and delivers it to the interface the chosen peer is avaliable.
    // The interface in arguments is the interface from which the packet was received by Node.
    func   getPacketToRouteFromNode(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        // Firs we check if we already had this packet before
        if let packetRecord = packetDict[packet.envelope.serial]
        {
            // If we already had this packet we should reject it - unless the rejected:true was set by the sender.
            if(packet.header.lifeCounterAndFlags.isGiveUp)
            {
                // The sender is rejecting the packet, we need to send the packet to other peer
                
                log(2, "R: \(node.txt) Processed packet with give up flag")
                
                // Stats
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketWithGiveUpFlagReceived)
                
                // Take the list of nodes the packet had beent sent to
                var peersIDs = selectPeersExcluding(packetRecord.sentToNodes)
                
                // Try to find a peer the packet hasn't been sent before
                if let peerIDToSendPacket = selectPeerFromIndexListAfterExclusions(packet.envelope.destinationAddress, peerIDs: peersIDs)
                {
                    log(2,"R: \(node.txt) Selected getPacketToRouteFromNode \(peerIDToSendPacket.txt)")
                    
                    // Update the packet's stack record by adding the chosen node
                    var updatedPacketRecord = packetRecord
                    updatedPacketRecord.sentToNodes.append(peerIDToSendPacket)
                    packetDict[packet.envelope.serial]=updatedPacketRecord
                    
                    // Put GiveUp flag down
                    var updatedPacket=packet
                    updatedPacket.header.lifeCounterAndFlags.setGiveUpFlag(false)
                    
                    // Send the packet to chosen peer
                    forwardPacketToPeer(interface, packet: updatedPacket, peerID: peerIDToSendPacket)
                }
                else
                {
                    // Peer to send not found, node did what it could, and now is time to send the packet back to
                    // send back to the origin or if the node is the originator of this packet display sad message
                    
                    if(packet.envelope.orginatedByUID.isEqual(node.id))
                    {
                        // This is our packet that cannot be send
                        log(6,"\(node.txt) received back own packet and dont have any peer to forward it")
                        node.nodeStats.addNodeStatsEvent(StatsEvents.PacketReturnedToSender)
                    }
                    else
                    {
                        // The packet is trespassing packet, and all can be done is to send it to the peer the node received it from
                        
                        // Stats
                        node.nodeStats.addNodeStatsEvent(StatsEvents.PacketWithGiveUpFlagSent)
                        
                        // Data from stack
                        var originID = packetRecord.receivedFrom
                        var updatedPacket = packet
                        
                        // Set up the giveup flag in the header
                        updatedPacket.header.lifeCounterAndFlags.setGiveUpFlag(true)
                        
                        log(2,"R: \(node.txt) Returned TO: \(originID.txt) at \(node.peers[originID]?.address.txt)")
                        
                        // Packet is sent to the peer it was received from first
                        forwardPacketToPeer(interface, packet: updatedPacket, peerID: originID)
                    }
                }
            }
            else
            {
                // Here is the situation when the packet is already known, but was sent to us with rejected:false in header
                // We already served this packet, and sender has other peers to send it, so the negative packet delivery (rejected) is send
                
                // Log & Stats
                log(2,"R: \(node.txt) Rejected \(packet.txt) ")
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketRejected)
                
                // We add to packets's sent history peer we received the packet from
                var updatedPacketRecord = packetRecord
                updatedPacketRecord.sentToNodes.append(packet.header.transmitedByUID)
                packetDict[packet.envelope.serial]=updatedPacketRecord
                
                // Here the delivery confirmation with rejected:true is sent
                sendPacketDeliveryConfirmation(interface, packet: packet, rejected:true)
            }
        }
        else
        {
            // The packet is a new packet - the serial number was not found in stack dictionary
            
            log(2,"R: \(node.txt) Received new packet")
            
            // Create an excluded from selection peers array and add the sender of the packet to it
            var oneElementArray=[UNodeID]()
            oneElementArray.append(packet.header.transmitedByUID)
            
            // Create an array of peers with excluded the sender of the packet
            let peersOtherThanSender=selectPeersExcluding(oneElementArray)
            
            // Select a peer to send a packet
            if let peerToSendPacketID = selectPeerFromIndexListAfterExclusions(packet.envelope.destinationAddress, peerIDs: peersOtherThanSender)
            {
                // Peer to send sucessfully selected
                log(2,"R: \(node.txt) Selected getPacketToRouteFromNode \(node.peers[peerToSendPacketID]!.id.txt) ")
                
                // This is new packet so add it to packet's stack
                // First create empty array on nodes the packet was sent
                var transmitedToPeers=[UNodeID]()
                
                // Add the selected peer's ID to the array
                transmitedToPeers.append(packet.header.transmitedByUID)
                transmitedToPeers.append(peerToSendPacketID)
                
                // Create stack entry
                let newStackItem = DictionaryBruteForcePacketStackRecord(packet: packet, receivedFrom: packet.header.transmitedByUID, sentToNodes: transmitedToPeers, status:DictionaryBrutForcePacketStatus.Sent, waitingTimeOnPacketStack:0)
                
                // Add to the stack
                packetDict[packet.envelope.serial]=newStackItem
                
                // Forward packet to selected peer
                forwardPacketToPeer(interface, packet:packet, peerID:peerToSendPacketID)
            }
            else
            {
                // The peer was not found - try to refresh th peers and if the number of peers changed try to select
                log(2, "R: \(node.txt) cannot find a peer for a new packet, refreshing peers")
                
                // Save current number of peers
                let currentPeersCount = node.peers.count
                
                // Send DiscoveryBroadcast packet
                node.refreshPeers()
                
                // Here we see the limit of my programming skills
                // We need to hold this tread waiting for reply sent by nodes which received the DiscoveryBroadcast packet
                // The replys must be serviced by other threads, so app to use this feature MUSt run in multithread mode
                // Mulithread is working but buggy and have some issues
                // To run app in serial mode (more stable) you need to initialise the network, but initilising network works well for small networks (< ~2000 nodes)
                // For larger network mulithread is nessesery, network runs uninitilised, and refreshes the peers on demand here
                sleep(1)
                
                // Check here if refreshing peers chenged anything in situation
                if node.peers.count > currentPeersCount // this must be done better, by checking if anything peer changed in any peer, especialy the active property
                {
                    // Refreshing peers changed the peers dictionary
                    log(2, "R: \(node.txt) refreshing peers worked somehow, we have \(node.peers.count) peers, reentering getPacketToRouteFromNode(interface,packet)")
                    
                    // So start the function again with entry parameters
                    getPacketToRouteFromNode(interface,packet: packet)
                }
                else
                {
                    log(2, "R: \(node.txt) cannot find a peer for a new packet, refreshing peers faild, rejecting")
                    
                    // No change in peers dictionary, reject (rejected: true) the packet to the node send it here
                    sendPacketDeliveryConfirmation(interface, packet: packet, rejected: true)
                }
            }
        }
    }

    
    // This function is called peridicaly to allow stack maintenance and packet resend.
    func maintenanceLoop()
    {
        // Check all stack records
        for (serial, aRecord) in packetDict
        {
            if aRecord.status == DictionaryBrutForcePacketStatus.Sent
            {
                // Packet was sent bat no any confirmation received
                var updatedRecord = aRecord
                
                // Update waiting time
                updatedRecord.waitingTimeOnPacketStack++
                packetDict[serial]=updatedRecord
                
                // If waiting time is longer then delayInPacketResend cont, resend it and update peers - somthing wrong happed if any confirmation hasent been received
                if aRecord.waitingTimeOnPacketStack  > delayInPacketResend
                {
                    node.refreshPeers()
                    sleep(1)
                    getPacketToRouteFromStack(serial)

                }
            }
                
            else if aRecord.status == DictionaryBrutForcePacketStatus.Delivered
            {
                var updatedRecord = aRecord
                
                // Update waiting time for delivered packets
                updatedRecord.waitingTimeOnPacketStack++
                packetDict[serial]=updatedRecord
                if aRecord.waitingTimeOnPacketStack  > delayInPacketDelete
                {
                    // Delete packet from stack
                    packetDict[serial]=nil
                }
            }
        }
    }
    
    // This function is called when node receives reception confirmation of the sent packet
    func getReceptionConfirmation(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        var returningPacketSerial:UInt64 = 0
        
        switch packet.packetCargo
        {
        case .ReceptionConfirmation(let recptionConfirmation): returningPacketSerial = recptionConfirmation.serial
        default: log(6, "Packet type error in getReceptionConfirmation")
        }
        
        // Find the packet the reception confirmation is about
        if let packetRecord=packetDict[returningPacketSerial]
        {
            // Check if packet was accepted by peer
            if(packet.header.lifeCounterAndFlags.replyConfirmationType)
            {
                // This is rejected packet by peer - resend to another peer
                
                // Stats
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketRejected)
                
                // Recover whole packet from stack
                let packetFromStack = packetDict[returningPacketSerial]!.packet
                
                // Send it again - the node that rejected the packet will by excluded
                self.getPacketToRouteFromStack(returningPacketSerial)
            }
            else
            {
                // Reception Confirmation is OK
                
                // Recover whole packet from stack
                var updatedPacketRecord = packetRecord
                
                // Update packet status
                updatedPacketRecord.status = DictionaryBrutForcePacketStatus.Delivered
                
                // Save back to stack
                packetDict[returningPacketSerial] =  updatedPacketRecord
                
                // Stats
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketConfirmedOK)
            }
        }
        else
        {
            // Delivery confirmation packet serial not found on packet stack - this happends sometimes
            // I dont know why
            log(6,"R: \(node.txt) delivery confirmation packet serial: \(returningPacketSerial) not found on packet stack ")
        }
        
    }
    
    // This function recieves the network monitoring packet and processes information from it
    // It will be overrided in better router than basic brute force
    func getReplyForNetworkLookupRequest(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    // This function recovers a packet form stack and sends it to the network
    func getPacketToRouteFromStack(serial:UInt64)
    {
        // Get the packet from the stack
        if let stackRecord = packetDict[serial]
        {
            // Find peer to send to
            if let peerToSend = selectPeerFromIndexListAfterExclusions(stackRecord.packet.envelope.destinationAddress, peerIDs:selectPeersExcluding(stackRecord.sentToNodes ))
            {
                log(2,"R: \(node.txt) Selected getPacketToRouteFromStack  \(peerToSend.txt)")
                
                var updatedStackRecord = stackRecord
                updatedStackRecord.sentToNodes.append(peerToSend)
                
                updatedStackRecord.packet.header.lifeCounterAndFlags.decreaseLifeCounter()
                
                
                packetDict[serial] = updatedStackRecord
                forwardPacketToPeer(nil, packet: stackRecord.packet, peerID: peerToSend)
            }
            else
            {
                // Peer to send packet not found
                
                // Is it a packet origineted by us?
                if(stackRecord.receivedFrom.isEqual(node.id))
                {
                    // Packet returned to tge originator without possibilities to send it
                    log(6, "R: \(node.txt) Returned after checking all possibilities")
                    node.nodeStats.addNodeStatsEvent(StatsEvents.PacketReturnedToSender)
                }
                else
                {
                    // No peers to send packet to - resending to the peer which sent it to the node
                    log(2, "R: \(node.txt) Resending packet from stack to the peer that sent it to node")
                    
                    // Unwrap the data
                    var packetToResend=stackRecord.packet
                    var peerToSendId=stackRecord.receivedFrom
                    
                    //nobody to send - trying to find the original peer
                    if let returningToIndex = node.peers[peerToSendId]
                    {
                        // Set up the givUp flag in packet header
                        packetToResend.header.lifeCounterAndFlags.setGiveUpFlag(true)
                        
                        // Stats
                        node.nodeStats.addNodeStatsEvent(StatsEvents.PacketWithGiveUpFlagSent)
                        
                        // Send the packet to the peer that the node received it from
                        forwardPacketToPeer(nil, packet: packetToResend, peerID: returningToIndex.id)
                    }
                    else
                    {
                        // We cant do anything but send the dropped packet to the originator of the packet
                        log(6, "R: \(node.txt) Packet lost - no geniue peer aveliable")
                        node.sendDropped(nil, packet: stackRecord.packet)
                    }
                    
                }
                
            }
        }
        else
        {
            // The packet with requested serial was not found on the stack - deleted too early
            log(6, "R: \(node.txt) No packet found on stack for resend")
        }
    }
    
    // This function assembels a new packet form data received form node or node's app
    func getPacketToRouteFromNode(envelope:UPacketEnvelope, cargo:UPacketType)
    {
        // Stats
        log(2,"R: \(node.txt) Created packet from envelope and cargo")
        
        // Depending of packet type select proper liftime
        let packetLiftime = (envelope.destinationUID.isBroadcast() ? defaultStoreSearchDepth : standardPacketLifeTime)
        
        // Find a peer to send from all peers
        if let peerToSendID = selectPeerFromIndexListAfterExclusions(envelope.destinationAddress, peerIDs: node.peers.keys.array)
        {
            // Create packet's header
            var header=UPacketHeader(from: node.id, to: peerToSendID, lifeTime: packetLiftime)
            
            // Assemble the packet
            let packet=UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: cargo)
            
            log(2,"R: \(node.txt) Selected getPacketToRouteFromNode (E&C) \(peerToSendID.txt)")
            
            // Create empty array for peers that the packet was dent to
            var sentArray=[UNodeID]()
            
            // Add chosen peer to the array
            sentArray.append(peerToSendID)
            
            // Create stack item
            let newStackItem=DictionaryBruteForcePacketStackRecord(packet: packet, receivedFrom: node.id, sentToNodes: sentArray, status:DictionaryBrutForcePacketStatus.Sent, waitingTimeOnPacketStack:0)
            
            // Add packet to stack
            self.packetDict[packet.envelope.serial] = newStackItem

            // Send the packet to selected peer
            forwardPacketToPeer(nil, packet: packet, peerID: peerToSendID)
        }
        else
        {
            // No peer found for the new packet - seems node has no peers
            log(2,"R: \(node.txt) Lonely node tried to send a packet, trying to refresh peers")
            
            // Find peers
            node.refreshPeers()
            
            // If you haven read the note about my programming skills :) move up to catch up the sllep(1) issue
            sleep(1)
            
            // If we have some peers, resend the packet
            if node.peers.count > 0
            {
                log(2,"R: \(node.txt) refreshing peers helped, we have \(node.peers.count) peers, reentering getPacketToRouteFromNode(envelope, cargo)")
                
                // Reenter function
                getPacketToRouteFromNode(envelope, cargo: cargo)
            }
            else
            {
                log(6,"R: \(node.txt) Lonely node tried to send a packet, refreshing peers didnt help")
                
            }
            node.nodeStats.addNodeStatsEvent(StatsEvents.PacketReturnedToSender)
            
        }
        
    }
    
    // Communication functions
    
    // This function is called if the packet had been sucesfully processed by node
    // Function is sending positive or negative reception confirmation to the node that send the packet to us
    func sendPacketDeliveryConfirmation (interface:UNetworkInterfaceProtocol, packet:UPacket, rejected:Bool)
    {
        // Create header
        var header=UPacketHeader(from: node.id, to: packet.header.transmitedByUID, lifeTime: 16)
        header.lifeCounterAndFlags.setConfirmationType(rejected)
        
        // Create envelope
        let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: packet.header.transmitedByUID, toAddress: unknownNodeAddress)
        
        // Create the cargo
        let receptionConfirmation=UPacketReceptionConfirmation(serial: packet.envelope.serial)
        let receptionConfirmationCargo=UPacketType.ReceptionConfirmation(receptionConfirmation)
        
        // Create packet
        let confirmationReceptionPacket=UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: receptionConfirmationCargo)
        
        // Send packet to the inferface from which the packet was reveived from
        interface.sendPacketToNetwork(confirmationReceptionPacket)
        
    }
    
    // After processing the packet, node here sends it to the selected peer
    func forwardPacketToPeer(interface:UNetworkInterfaceProtocol?, packet:UPacket, peerID:UNodeID)
    {
        
        // Find peer by ID
        if let peerTosend = node.peers[peerID]
        {
            
            // If interface is avalible, this is packet that came from other node
            // if not this is nodes own, new packet
            if(!packet.envelope.orginatedByUID.isEqual(node.id) && interface != nil)
            {
                // Confirm the reception of the packet
                sendPacketDeliveryConfirmation(interface!, packet: packet, rejected:false)
            }
            
            // Here the networklookuprequest may be attached
            
            
            // Push to the interface
            var updatedPacket=packet
            updatedPacket.header.transmitedByUID=node.id
            updatedPacket.header.transmitedToUID=peerTosend.id
            updatedPacket.header.lifeCounterAndFlags.decreaseLifeCounter()
            
            node.peers[peerTosend.id]?.interface.sendPacketToNetwork(updatedPacket)
            
            
        }
        else
        {
            log(7,"The PeerDI provided to forwardPacketToPeer was not found")
        }
    }
    
    // Helper functions
    
    // This function returns the array of IDs which difference between all peers and the IDs send as argument
    // The sentToNodes array should be refactor to set type, and delete this function
    func selectPeersExcluding(excludedNodeIDs:[UNodeID]) -> [UNodeID]
    {
        var result = [UNodeID]()
        
        for peerID in node.peers.keys
        {
            var addCurrentPeer=true
            if node.peers[peerID]?.active == true
            {
                for (_, excudedId) in enumerate(excludedNodeIDs)
                {
                    if(peerID.isEqual(excudedId))
                    {
                        addCurrentPeer=false
                        break
                    }
                }
            }
            else
            {
                addCurrentPeer=false
            }
            if(addCurrentPeer)
            {
                result.append(peerID)
            }
        }
        return result
    }
    
    // This fuction selects a peer from provided ID list
    // Overriding this function is key for next level routers
    // Broute force router guaranees that the packet will be delivered (if possible)
    // But not in an optimal way
    func selectPeerFromIndexListAfterExclusions(toAddress:UNodeAddress, peerIDs:[UNodeID]) -> UNodeID?
    {
        
        var address = toAddress
        var result:UNodeID?
        
        // For this router it is meanigless but here are the transfer and broadcast (search or store) packets distinguished
        if ((address.latitude == UInt64(0) || address.latitude == maxLatitude) && (address.longitude == UInt64(0) || (address.longitude == maxLongitude) && (address.altitude == UInt64(0)) || address.altitude == maxAltitude))
        {
            // This is search or store packet, the address for routing must be genereted
            address=findAddressForSearchOrStorePacket(address)
            
        }
        
        // Here is the place from this router took its name: Brute Force ;)
        if(node.peers.count > 0)
        {
            result = peerIDs[Int(arc4random_uniform(UInt32(peerIDs.count)))]
        }
        
        
        return result
    }
    
    // This function returns the address which shoud be taken for search or store packet routing
    func findAddressForSearchOrStorePacket(address:UNodeAddress) -> UNodeAddress
    {
        var corrLat = node.address.latitude
        var corrLong = node.address.longitude
        var corrAlt = node.address.altitude

        if (address.latitude == maxLatitude)
        {
            corrLat = corrLat + (2 * wirelessInterfaceRange)
        }
        else
        {
            corrLat = corrLat - (2 * wirelessInterfaceRange)
        }
        
        if (address.longitude == maxLongitude)
        {
            corrLong = corrLong + (2 * wirelessInterfaceRange)
            corrLat = corrLat + (1 * wirelessInterfaceRange)
        }
        else
        {
            corrLong = corrLong - (2 * wirelessInterfaceRange)
            corrLat = corrLat - (1 * wirelessInterfaceRange)
        }
        
        if (address.altitude == maxAltitude)
        {
            corrAlt = maxAltitude
        }
        else
        {
            corrAlt = 0
        }
        
        // Create the address
        let result=UNodeAddress(inputLatitude: corrLat, inputLongitude: corrLong, inputAltitude: corrAlt)
        
        return result
    }
    
    // Reset routers data
    func reset()
    {
        packetDict=[UInt64:DictionaryBruteForcePacketStackRecord]()
    }
    
    // For node monitiring by simulator
    func status() -> [(String, String, String, String, String)]
    {
        var result = [(String, String, String, String, String)]()
        for aRecord in packetDict
        {
            let from = aRecord.1.receivedFrom.txt
            let sent = String(aRecord.1.sentToNodes.count)
            let stat = String(aRecord.1.status.rawValue)
            let wait = String(aRecord.1.waitingTimeOnPacketStack)
            let packet = aRecord.1.packet.txt
            
            result.append((from, sent, stat, wait, packet))
        }
        return result
        
    }
}


// Data structures

// Packet stack
struct DictionaryBruteForcePacketStackRecord
{
    var packet:UPacket
    var receivedFrom:UNodeID
    // todo sentToNodes should be set not array
    var sentToNodes:[UNodeID]
    var status:DictionaryBrutForcePacketStatus
    var waitingTimeOnPacketStack: Int
}

// packet status on stack
enum DictionaryBrutForcePacketStatus:Int
{
    case WaitingForRoute
    case Sent
    case Delivered
}
