//
//  URouter_BruteForce.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/21/15.
//

import Foundation

class URouter_BruteForceRouting:URouterProtocol {
    
    var node:UNode
    var packetStack=[BruteForcePacketStackRecord]()
    
    init(node:UNode)
    {
        self.node=node
    }
    
    
    func maintenanceLoop()
    {
       for (index, aRecord) in enumerate(packetStack)
       {
        if aRecord.status == BrutForcePacketStatus.Sent
        {
            packetStack[index].waitingTimeOnPacketStack++
            if aRecord.waitingTimeOnPacketStack  > delayInPacketResend
            {
                getPacketToRouteFromStack(index)
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
        default: log(7, "Packet type error in getReceptionConfirmation")
        }
        
        
        if let packetIndex=searchForSerialOnStack(returningPacketSerial)
        {
            if(packet.header.lifeCounterAndFlags.replyConfirmationType)
            {
                // this is rejected packet by peer
                // resend to another peer
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketRejected)
                let packetFromStack = packetStack[packetIndex].packet
                
               // self.getPacketToRouteFromNode(packetFromStack.envelope, cargo: packetFromStack.packetCargo)
                self.getPacketToRouteFromStack(packetIndex)
            }
            else
            {
                //confirmation ok
                packetStack[packetIndex].status=BrutForcePacketStatus.Delivered
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketConfirmedOK)
            }
        }
        else
        {
            // delivery confirmation packet serial not found on packet stack
            log(7,"R: \(node.txt) delivery confirmation packet serial: \(returningPacketSerial) not found on packet stack ")
            
            
        }
        
    }
    
    
    
    func getReplyForNetworkLookupRequest(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    func getPacketToRouteFromStack(packetIndex:Int)
    {
        let stackRecord = packetStack[packetIndex]
        
        if let peerToSendIndex = selectPeerFromIndexListAfterExclusions(stackRecord.packet.envelope.destinationAddress, peerIndexes:selectPeersExcluding(stackRecord.sentToNodes ))
        {
            log(2,"R: \(node.txt) Selected getPacketToRouteFromStack  \(node.peers[peerToSendIndex].id.txt)")
            
            packetStack[packetIndex].sentToNodes.append(node.peers[peerToSendIndex].id)
            forwardPacketToPeer(nil, packet: stackRecord.packet, peerIndex: peerToSendIndex)
        }
        else
        {
            if(stackRecord.recievedFrom.isEqual(node.id))
            {
                log(5, "R: \(node.txt) Returned after checking all possibilities")
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketReturnedToSender)
            }
            else
            {
                log(3, "R: \(node.txt) Resending packet from stack to the peer that sent it to node")
                var packetToResend=stackRecord.packet
                var peerToSendId=stackRecord.recievedFrom
                
                //nobody to send - trying to find the original peer
                if let returningToIndex = node.findInPeers(peerToSendId)
                {
                    packetToResend.header.lifeCounterAndFlags.setGiveUpFlag(true)
                    
                    node.nodeStats.addNodeStatsEvent(StatsEvents.PacketWithGiveUpFlagSent)

                    forwardPacketToPeer(nil, packet: packetToResend, peerIndex: returningToIndex)
                }
                else
                {
                    //drop
                    log(6, "R: \(node.txt) Packet lost - no geniue peer aveliable")
                    node.sendDropped(stackRecord.packet.envelope)
                }
                
            }
            
        }
    }
    
    
    func getPacketToRouteFromNode(envelope:UPacketEnvelope, cargo:UPacketType)
    {
        log(2,"R: \(node.txt) Created packet from envelope and cargo")
        
        let packetLiftime = (envelope.destinationUID.isBroadcast() ? defaultStoreSearchDepth : standardPacketLifeTime)
        

        if let peerToSendIndex = selectPeerFromIndexListAfterExclusions(envelope.destinationAddress, peerIndexes: allPeerIndexes())
        {
            var header=UPacketHeader(from: node.id, to: node.peers[peerToSendIndex].id, lifeTime: packetLiftime)
            
            let packet=UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: cargo)
            
            log(2,"R: \(node.txt) Selected getPacketToRouteFromNode (E&C) \(node.peers[peerToSendIndex].id.txt)")
            
            var sentArray=[UNodeID]()
            sentArray.append(node.peers[peerToSendIndex].id)
            
            
            let newStackItem=BruteForcePacketStackRecord(packet: packet, recievedFrom: node.id, sentToNodes: sentArray, status:BrutForcePacketStatus.Sent, waitingTimeOnPacketStack:0)
            self.packetStack.append(newStackItem)
            
            
            forwardPacketToPeer(nil, packet: packet, peerIndex: peerToSendIndex)
        }
        else
        {
            // must be lonely node
            log(7,"R: \(node.txt) Lonely node tried to send a packet")
            node.nodeStats.addNodeStatsEvent(StatsEvents.PacketReturnedToSender)

        }
        
    }
    
    
    func   getPacketToRouteFromNode(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
        if let packetIndex = searchForSerialOnStack(packet.envelope.serial)
        {
            // counter in this place
            if(packet.header.lifeCounterAndFlags.isGiveUp)
            {
                // returning, new peer must be selected
                
                
                log(2, "R: \(node.txt) Processed with givup flag")
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketWithGiveUpFlagRecieved)
                
                
                var peersIndexes = selectPeersExcluding(packetStack[packetIndex].sentToNodes)
                if let peerToSendPacketIndex = selectPeerFromIndexListAfterExclusions(packet.envelope.destinationAddress, peerIndexes: peersIndexes)
                {
                    log(2,"R: \(node.txt) Selected getPacketToRouteFromNode \(node.peers[peerToSendPacketIndex].id.txt)")
                    
                    packetStack[packetIndex].sentToNodes.append(node.peers[peerToSendPacketIndex].id)
                    // put GiveUp flag down
                    
                    var updatedPacket=packet
                    updatedPacket.header.lifeCounterAndFlags.setGiveUpFlag(false)
                    
                    forwardPacketToPeer(interface, packet: updatedPacket, peerIndex: peerToSendPacketIndex)
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
                        var originIndex = searchForIdInNodePeers(packetStack[packetIndex].recievedFrom)
                        var updatedPacket=packet
                        
                        updatedPacket.header.lifeCounterAndFlags.setGiveUpFlag(true)
                        
                        
                        if(originIndex != nil)
                        {
                            log(2,"R: \(node.txt) Returned TO: \(node.peers[originIndex!].id.txt) at \(node.peers[originIndex!].address.txt)")
                            
                            forwardPacketToPeer(interface, packet: updatedPacket, peerIndex: originIndex!)
                        }
                        else
                        {
                            log(7, "\(node.txt) cannot find a originator of the packet on own packet stack \(packet.txt)")
                        }
                    }
                }
            }
            else
            {
                
                // packet already processed, send negative packet delivery (rejected)
                
                log(2,"R: \(node.txt) Rejected \(packet.txt) ")
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketRejected)
                packetStack[packetIndex].sentToNodes.append(packet.header.transmitedByUID)
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
            
            if let peerToSendPacketIndex = selectPeerFromIndexListAfterExclusions(packet.envelope.destinationAddress, peerIndexes: peersOtherThanSender)

                
          //  ^^^ this suck
                
            {
                
                log(2,"R: \(node.txt) Selected getPacketToRouteFromNode \(node.peers[peerToSendPacketIndex].id.txt) ")
                
                // add to packet to stack
                
                var transmitedToPeers=[UNodeID]()
                
                transmitedToPeers.append(packet.header.transmitedByUID)
                transmitedToPeers.append(node.peers[peerToSendPacketIndex].id)
                let newStackItem=BruteForcePacketStackRecord(packet: packet, recievedFrom: packet.header.transmitedByUID, sentToNodes: transmitedToPeers, status:BrutForcePacketStatus.Sent, waitingTimeOnPacketStack:0)
                self.packetStack.append(newStackItem)
                forwardPacketToPeer(interface, packet:packet, peerIndex:peerToSendPacketIndex)
            }
            else
            {
                log(2, "R: \(node.txt) cannot find a peer for a new packet rejecting")
                
                // reject
                
                sendPacketDeliveryConfirmation(interface, packet: packet, rejected: true)
                
                
   
                
                
                
            }
            
        }
    }
    
    
    
    
    
    // processing functions
    
    func searchForSerialOnStack(serial:UInt64) -> Int?
    {
        var result:Int?
        
        for (i, stackRecord) in enumerate(self.packetStack)
        {
            if(stackRecord.packet.envelope.serial == serial)
            {
                result = i
                break
            }
        }
        return result
    }
    
    
    
    func selectPeersExcluding(excludedNodeIDs:[UNodeID]) -> [Int]
    {
        var result = [Int]()
        
        for (peerIndexInNodeArray, peer) in enumerate(node.peers)
        {
            var addCurrentPeer=true
            
            for (_, excudedId) in enumerate(excludedNodeIDs)
            {
                if(peer.id.isEqual(excudedId))
                {
                    addCurrentPeer=false
                    break
                }
            }
            if(addCurrentPeer)
            {
                result.append(peerIndexInNodeArray)
            }
        }
        return result
    }
    

    
    func selectPeerFromIndexListAfterExclusions(toAddress:UNodeAddress, peerIndexes:[Int]) -> Int?
    {
        var address = toAddress
        var result:Int?
        
        if ((address.latitude == UInt64(0) || address.latitude == maxLatitude) && (address.longitude == UInt64(0) || (address.longitude == maxLongitude) && (address.altitude == UInt64(0)) || address.altitude == maxAltitude))
        {
            // this is search store packet
            address=findAddressForSearchOrStorePacket(address)

        }
       
        
        
        
        if(node.peers.count > 0)
        {
            result = Int(arc4random_uniform(UInt32(peerIndexes.count)))
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
        
        /*
        if(address.latitude == maxLatitude)
        {
            corrLat = corrLat + (5 * wirelessInterfaceRange)
        }
        else
        {
            corrLat = corrLat - (5 * wirelessInterfaceRange)
        }
        
        if( address.longitude == maxLongitude)
        {
            corrLong = corrLong + (5 * wirelessInterfaceRange)
            corrLat = corrLat + (2 * wirelessInterfaceRange)
        }
        else
        {
            corrLong = corrLong - (5 * wirelessInterfaceRange)
            corrLat = corrLat - (2 * wirelessInterfaceRange)

        }
        
        if ( address.altitude == maxAltitude)
        {
            corrAlt = corrAlt + (5 * wirelessInterfaceRange)
            
        }
        else
        {
            corrAlt = corrAlt - (5 * wirelessInterfaceRange)
        }

*/
        
        let result=UNodeAddress(inputLatitude: corrLat, inputLongitude: corrLong, inputAltitude: corrAlt)
        return result
        
    }
    
    
    func searchForIdInNodePeers(id:UNodeID) -> Int?
    {
        var result:Int?
        
        for (index, peer) in enumerate(node.peers)
        {
            if (peer.id.isEqual(id))
            {
                result=index
                break
            }
        }
        return result
    }
    
    func allPeerIndexes() -> [Int]
    {
        var result = [Int]()
        for (index, _) in enumerate(node.peers){
         result.append(index)
        }
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
    
    
    func forwardPacketToPeer(interface:UNetworkInterfaceProtocol?, packet:UPacket, peerIndex:Int)
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
        updatedPacket.header.transmitedToUID=node.peers[peerIndex].id
        updatedPacket.header.lifeCounterAndFlags.decreaseLifeCounter()
        
        node.peers[peerIndex].interface.sendPacketToNetwork(updatedPacket)
    }
    
    
    func reset()
    {
        packetStack=[BruteForcePacketStackRecord]()
    }
    
}




struct BruteForcePacketStackRecord {
    
    var packet:UPacket
    var recievedFrom:UNodeID
    var sentToNodes:[UNodeID]
    var status:BrutForcePacketStatus
    var waitingTimeOnPacketStack: Int
}


enum BrutForcePacketStatus:Int {
    case WaitingForRoute
    case Sent
    case Delivered
    
}


