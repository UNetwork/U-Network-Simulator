//
//  URouter_DictionaryBruteForce.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/30/15.
//

import Foundation

class URouter_DictionaryBruteForceRouting:URouterProtocol {
    
    var node:UNode
    var packetDict=[UInt64:DictionaryBruteForcePacketStackRecord]()
    
    
    
    init(node:UNode)
    {
        self.node=node
    }
    
    
    func maintenanceLoop()
    {
        for (serial, aRecord) in packetDict
        {
            if aRecord.status == DictionaryBrutForcePacketStatus.Sent
            {
               
                
                var updatedRecord = aRecord
                updatedRecord.waitingTimeOnPacketStack++
                
                packetDict[serial]=updatedRecord
                
                
                
                if aRecord.waitingTimeOnPacketStack  > delayInPacketResend
                {
                    getPacketToRouteFromStack(serial)
                    node.refreshPeers()
                    sleep(1)
                }
            }
        }
        
        
        // find not deliverd packets and resend
        // delete some useless and old data from packetstack
    }
    
    
    
    func getReceptionConfirmation(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        var returningPacketSerial:UInt64 = 0
        
        switch packet.packetCargo
        {
        case .ReceptionConfirmation(let recptionConfirmation): returningPacketSerial = recptionConfirmation.serial
        default: log(6, "Packet type error in getReceptionConfirmation")
        }
        
        
        if let packetRecord=packetDict[returningPacketSerial]
        {
            if(packet.header.lifeCounterAndFlags.replyConfirmationType)
            {
                // this is rejected packet by peer
                // resend to another peer
                
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketRejected)
                let packetFromStack = packetDict[returningPacketSerial]!.packet
                
                self.getPacketToRouteFromStack(returningPacketSerial)
            }
            else
            {
                //confirmation ok
                
                var updatedPacketRecord = packetRecord
                updatedPacketRecord.status = DictionaryBrutForcePacketStatus.Delivered
                packetDict[returningPacketSerial] =  updatedPacketRecord
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketConfirmedOK)
            }
        }
        else
        {
            // delivery confirmation packet serial not found on packet stack
            log(6,"R: \(node.txt) delivery confirmation packet serial: \(returningPacketSerial) not found on packet stack ")
        }
        
    }
    
    
    
    func getReplyForNetworkLookupRequest(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    func getPacketToRouteFromStack(serial:UInt64)
    {
       if let stackRecord = packetDict[serial]
       {
        
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
            if(stackRecord.recievedFrom.isEqual(node.id))
            {
                log(6, "R: \(node.txt) Returned after checking all possibilities")
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketReturnedToSender)
            }
            else
            {
                log(2, "R: \(node.txt) Resending packet from stack to the peer that sent it to node")
                var packetToResend=stackRecord.packet
                var peerToSendId=stackRecord.recievedFrom
                
                //nobody to send - trying to find the original peer
                if let returningToIndex = node.peers[peerToSendId]
                {
                    packetToResend.header.lifeCounterAndFlags.setGiveUpFlag(true)
                    
                    node.nodeStats.addNodeStatsEvent(StatsEvents.PacketWithGiveUpFlagSent)
                    
                    forwardPacketToPeer(nil, packet: packetToResend, peerID: returningToIndex.id)
                }
                else
                {
                    //drop
                    log(6, "R: \(node.txt) Packet lost - no geniue peer aveliable")
                    node.sendDropped(nil, packet: stackRecord.packet)
                }
                
            }
            
        }
        }
    }
    
    
    func getPacketToRouteFromNode(envelope:UPacketEnvelope, cargo:UPacketType)
    {
        log(2,"R: \(node.txt) Created packet from envelope and cargo")
        
        let packetLiftime = (envelope.destinationUID.isBroadcast() ? defaultStoreSearchDepth : standardPacketLifeTime)
        
        
        
        if let peerToSendID = selectPeerFromIndexListAfterExclusions(envelope.destinationAddress, peerIDs: node.peers.keys.array)
        {
            var header=UPacketHeader(from: node.id, to: peerToSendID, lifeTime: packetLiftime)
            
            let packet=UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: cargo)
            
            log(2,"R: \(node.txt) Selected getPacketToRouteFromNode (E&C) \(peerToSendID.txt)")
            
            var sentArray=[UNodeID]()
            sentArray.append(peerToSendID)
            
            
            let newStackItem=DictionaryBruteForcePacketStackRecord(packet: packet, recievedFrom: node.id, sentToNodes: sentArray, status:DictionaryBrutForcePacketStatus.Sent, waitingTimeOnPacketStack:0)
           
            
            self.packetDict[packet.envelope.serial] = newStackItem
            
            
            
            
            forwardPacketToPeer(nil, packet: packet, peerID: peerToSendID)
        }
        else
        {
            // must be lonely node
            log(2,"R: \(node.txt) Lonely node tried to send a packet, trying to refresh peers")

            node.refreshPeers()

           sleep(1)
            
            if node.peers.count > 0
            {
                log(2,"R: \(node.txt) refreshing peers helped, we have \(node.peers.count) peers, reentering getPacketToRouteFromNode(envelope, cargo)")

                getPacketToRouteFromNode(envelope, cargo: cargo)
            }
            else
            {
                log(6,"R: \(node.txt) Lonely node tried to send a packet, refreshing peers didnt help")

            }
            node.nodeStats.addNodeStatsEvent(StatsEvents.PacketReturnedToSender)
            
        }
        
    }
    
    
    func   getPacketToRouteFromNode(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
        if let packetRecord = packetDict[packet.envelope.serial]
        {
            // counter in this place
            if(packet.header.lifeCounterAndFlags.isGiveUp)
            {
                // returning, new peer must be selected
                
                
                log(2, "R: \(node.txt) Processed with givup flag")
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketWithGiveUpFlagRecieved)
                
                
                var peersIDs = selectPeersExcluding(packetRecord.sentToNodes)
                
                if let peerIDToSendPacket = selectPeerFromIndexListAfterExclusions(packet.envelope.destinationAddress, peerIDs: peersIDs)
                {
                    log(2,"R: \(node.txt) Selected getPacketToRouteFromNode \(peerIDToSendPacket.txt)")
                    
                   var updatedPacketRecord = packetRecord
                    updatedPacketRecord.sentToNodes.append(peerIDToSendPacket)
                    
                    packetDict[packet.envelope.serial]=updatedPacketRecord
                    
                    // put GiveUp flag down
                    
                    var updatedPacket=packet
                    updatedPacket.header.lifeCounterAndFlags.setGiveUpFlag(false)
                    
                    forwardPacketToPeer(interface, packet: updatedPacket, peerID: peerIDToSendPacket)
                }
                else
                {
                    // send back to the origin
                    
                    if(packet.envelope.orginatedByUID.isEqual(node.id))
                    {
                        
                        log(6,"\(node.txt) recieved back own packet and dont have any peer to forward it")
                        node.nodeStats.addNodeStatsEvent(StatsEvents.PacketReturnedToSender)
                        
                        
                    }
                    else
                    {
                        
                        node.nodeStats.addNodeStatsEvent(StatsEvents.PacketWithGiveUpFlagSent)
                        
                        
                        
                        
                        
                        
                        var originID = packetRecord.recievedFrom
                        var updatedPacket = packet
                        
                        updatedPacket.header.lifeCounterAndFlags.setGiveUpFlag(true)
                        
                        
                        log(2,"R: \(node.txt) Returned TO: \(originID.txt) at \(node.peers[originID]?.address.txt)")
                        
                        forwardPacketToPeer(interface, packet: updatedPacket, peerID: originID)

                       /*
                        
                        if(originIndex != nil)
                        {
                            log(2,"R: \(node.txt) Returned TO: \(node.peers[originIndex!].id.txt) at \(node.peers[originIndex!].address.txt)")
                            
                            forwardPacketToPeer(interface, packet: updatedPacket, peerIndex: originIndex!)
                        }
                        else
                        {
                            log(7, "\(node.txt) cannot find a originator of the packet on own packet stack \(packet.txt)")
                        }

*/
                    }
                }
            }
            else
            {
                
                // packet already processed, send negative packet delivery (rejected)
                
                log(2,"R: \(node.txt) Rejected \(packet.txt) ")
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketRejected)
                
                var updatedPacketRecord = packetRecord
                updatedPacketRecord.sentToNodes.append(packet.header.transmitedByUID)
                packetDict[packet.envelope.serial]=updatedPacketRecord
                
                
                
                sendPacketDeliveryConfirmation(interface, packet: packet, rejected:true)
                
            }
        }
        else
        {
            // select peer
            log(2,"R: \(node.txt) Recieved new packet")
            
            
            var oneElementArray=[UNodeID]()
            oneElementArray.append(packet.header.transmitedByUID)
            
            let peersOtherThanSender=selectPeersExcluding(oneElementArray)
            
            if let peerToSendPacketID = selectPeerFromIndexListAfterExclusions(packet.envelope.destinationAddress, peerIDs: peersOtherThanSender)
                
                
                //  ^^^ this suck
                
            {
                
                log(2,"R: \(node.txt) Selected getPacketToRouteFromNode \(node.peers[peerToSendPacketID]!.id.txt) ")
                
                // add to packet to stack
                
                var transmitedToPeers=[UNodeID]()
                
                transmitedToPeers.append(packet.header.transmitedByUID)
                transmitedToPeers.append(peerToSendPacketID)
                let newStackItem = DictionaryBruteForcePacketStackRecord(packet: packet, recievedFrom: packet.header.transmitedByUID, sentToNodes: transmitedToPeers, status:DictionaryBrutForcePacketStatus.Sent, waitingTimeOnPacketStack:0)
                
                packetDict[packet.envelope.serial]=newStackItem
                  forwardPacketToPeer(interface, packet:packet, peerID:peerToSendPacketID)
            }
            else
            {
                log(2, "R: \(node.txt) cannot find a peer for a new packet, refreshing")
                
                let currentPeersCount = node.peers.count
                
                node.refreshPeers()
                
                sleep(1)
                
                
                
                if node.peers.count > currentPeersCount // this must be done better, by checking if anything in peer changed in active
                {
                    log(2, "R: \(node.txt) refreshing peers worked somehow, we have \(node.peers.count) peers, reentering getPacketToRouteFromNode(interface,packet)")

                    getPacketToRouteFromNode(interface,packet: packet)

                }
                else
                {
                    log(2, "R: \(node.txt) cannot find a peer for a new packet, refreshing peers faild, rejecting")

                sendPacketDeliveryConfirmation(interface, packet: packet, rejected: true)
                }
                
                
                
                
                
            }
            
        }
    }
    
    
    
    
    
    // processing functions
    
    
    
    
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
    
    
    
    func selectPeerFromIndexListAfterExclusions(toAddress:UNodeAddress, peerIDs:[UNodeID]) -> UNodeID?
    {
     
        
        
        var address = toAddress
        var result:UNodeID?
        
        if ((address.latitude == UInt64(0) || address.latitude == maxLatitude) && (address.longitude == UInt64(0) || (address.longitude == maxLongitude) && (address.altitude == UInt64(0)) || address.altitude == maxAltitude))
        {
            // this is search store packet
            address=findAddressForSearchOrStorePacket(address)
            
        }
        
        
        
        
        if(node.peers.count > 0)
        {
            result = peerIDs[Int(arc4random_uniform(UInt32(peerIDs.count)))]
            
        }
        
        
        return result
    }
    
    func findAddressForSearchOrStorePacket(address:UNodeAddress) -> UNodeAddress
    {
        var corrLat = node.address.latitude
        var corrLong = node.address.longitude
        var corrAlt = node.address.altitude
        
        
        
        if(address.latitude == maxLatitude)
        {
            corrLat = corrLat + (2 * wirelessInterfaceRange)
        }
        else
        {
            corrLat = corrLat - (2 * wirelessInterfaceRange)
        }
        
        if( address.longitude == maxLongitude)
        {
            corrLong = corrLong + (2 * wirelessInterfaceRange)
            corrLat = corrLat + (1 * wirelessInterfaceRange)
        }
        else
        {
            corrLong = corrLong - (2 * wirelessInterfaceRange)
            corrLat = corrLat - (1 * wirelessInterfaceRange)
            
        }
        
        if ( address.altitude == maxAltitude)
        {
            corrAlt = maxAltitude
            
        }
        else
        {
            corrAlt = 0
        }
        
        let result=UNodeAddress(inputLatitude: corrLat, inputLongitude: corrLong, inputAltitude: corrAlt)
        return result
        
    }
    
    
    // communication functions
    
    func sendPacketDeliveryConfirmation (interface:UNetworkInterfaceProtocol, packet:UPacket, rejected:Bool)
    {
        var header=UPacketHeader(from: node.id, to: packet.header.transmitedByUID, lifeTime: 16)
        header.lifeCounterAndFlags.setConfirmationType(rejected)
        let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: packet.header.transmitedByUID, toAddress: unknownNodeAddress)
        let receptionConfirmation=UPacketReceptionConfirmation(serial: packet.envelope.serial)
        let receptionConfirmationCargo=UPacketType.ReceptionConfirmation(receptionConfirmation)
        
        let confirmationReceptionPacket=UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: receptionConfirmationCargo)
        
        
        interface.sendPacketToNetwork(confirmationReceptionPacket)
        
    }
    
    
    func forwardPacketToPeer(interface:UNetworkInterfaceProtocol?, packet:UPacket, peerID:UNodeID)
    {
        
        if let peerTosend = node.peers[peerID]
        {
        
        // send  reception confirmation
        if(!packet.envelope.orginatedByUID.isEqual(node.id) && interface != nil)
        {
            sendPacketDeliveryConfirmation(interface!, packet: packet, rejected:false)
        }
        
        // here the networklookuprequest may be attached
        
        
        // push to the interface
        
        var updatedPacket=packet
        updatedPacket.header.transmitedByUID=node.id
        updatedPacket.header.transmitedToUID=peerTosend.id
        updatedPacket.header.lifeCounterAndFlags.decreaseLifeCounter()
        
        node.peers[peerTosend.id]?.interface.sendPacketToNetwork(updatedPacket)
            

        }
    }
    
    
    func reset()
    {
        packetDict=[UInt64:DictionaryBruteForcePacketStackRecord]()
    }
    
    func status() -> [(String, String, String, String, String)]
    {
    
    var result = [(String, String, String, String, String)]()
        
        for aRecord in packetDict
        {
            let from = aRecord.1.recievedFrom.txt
            let sent = String(aRecord.1.sentToNodes.count)
            let stat = String(aRecord.1.status.rawValue)
            let wait = String(aRecord.1.waitingTimeOnPacketStack)
            let packet = aRecord.1.packet.txt
            
            result.append((from, sent, stat, wait, packet))
        }
        return result

    }
}




struct DictionaryBruteForcePacketStackRecord {
    
    var packet:UPacket
    var recievedFrom:UNodeID
    var sentToNodes:[UNodeID]
    var status:DictionaryBrutForcePacketStatus
    var waitingTimeOnPacketStack: Int
}


enum DictionaryBrutForcePacketStatus:Int {
    case WaitingForRoute
    case Sent
    case Delivered
    
}
