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
            log(7,">>>>>>\(node.txt) delivery confirmation packet serial not found on packet stack \(packet.txt)")
            
            
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
            packetStack[packetIndex].sentToNodes.append(node.peers[peerToSendIndex].id)
            forwardPacketToPeer(nil, packet: stackRecord.packet, peerIndex: peerToSendIndex)
        }
        else
        {
            
            var packetToResend=stackRecord.packet
            var peerToSendId=stackRecord.recievedFrom
            
            //nobody to send - trying to find the original peer
            if let returningToIndex = node.findInPeers(peerToSendId)
            {
                forwardPacketToPeer(nil, packet: stackRecord.packet, peerIndex: returningToIndex)
            }
            else
            {
                //drop
                node.sendDropped(stackRecord.packet.envelope)
            }
            
            
            
        }
    }
    
    
    func getPacketToRouteFromNode(envelope:UPacketEnvelope, cargo:UPacketType)
    {
        if let peerToSendIndex = selectPeerForAddressFromAllPeers(envelope.destinationAddress)
        {
            var header=UPacketHeader(from: node.id, to: node.peers[peerToSendIndex].id, lifeTime: standardPacketLifeTime)
            
            let packet=UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: cargo)
            
            log(2,"Packet \(packet.txt) created from envelope and cargo by \(node.txt)")
            
            getPacketToRouteFromNode(node.peers[peerToSendIndex].interface, packet: packet)
        }
        else
        {
            // must be lonely node
            log(7,"Lonely node tried to send a packet")
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
                
                
                log(2, " \(packet.txt) is processed by \(node.txt) with givup flag")
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketWithGiveUpFlagRecieved)
                
                
                var peersIndexes = selectPeersExcluding(packetStack[packetIndex].sentToNodes)
                if let peerToSendPacketIndex = selectPeerFromIndexListAfterExclusions(packet.envelope.destinationAddress, peerIndexes: peersIndexes)
                {
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
                        
                        log(6,"\(node.txt) recieved back own packet and dont have any peer to forward it \(packet.txt)")
                        
                    }
                    else
                    {
                        
                        node.nodeStats.addNodeStatsEvent(StatsEvents.PacketWithGiveUpFlagSent)
                        var originIndex = searchForIdInNodePeers(packetStack[packetIndex].recievedFrom)
                        var updatedPacket=packet
                        
                        updatedPacket.header.lifeCounterAndFlags.setGiveUpFlag(true)
                        
                        log(2,"give up\n")
                        
                        if(originIndex != nil)
                        {
                            log(2,"\(packet.txt) is returned to \(node.peers[originIndex!].id.txt) at \(node.peers[originIndex!].address.txt)")
                            
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
                
                // packet already processed, send negative packet delivery
                
                log(2,"\(node.txt) rejected \(packet.txt) ")
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketRejected)
                packetStack[packetIndex].sentToNodes.append(packet.header.transmitedByUID)
                sendPacketDeliveryConfirmation(interface, packet: packet, rejected:true)
                
            }
        }
        else
        {
            // select peer
            log(2,"\(node.txt) recieved NEW \(packet.txt)")
            
            
            var oneElementArray=[UNodeID]()
            oneElementArray.append(packet.header.transmitedByUID)
            
            let peersOtherThanSender=selectPeersExcluding(oneElementArray)
            
            if let peerToSendPacketIndex = selectPeerFromIndexListAfterExclusions(packet.envelope.destinationAddress, peerIndexes: peersOtherThanSender)

                
          //  if let peerToSendPacketIndex = selectPeerForAddressFromAllPeers(packet.envelope.destinationAddress)
                
            {
                
                log(2,"\(node.txt) selected  \(node.peers[peerToSendPacketIndex].id.txt) at \(node.peers[peerToSendPacketIndex].address.txt)")
                
                // add to packet to stack
                
                var transmitedToPeers=[UNodeID]()
                
                transmitedToPeers.append(packet.header.transmitedByUID)
                transmitedToPeers.append(node.peers[peerToSendPacketIndex].id)
                let newStackItem=BruteForcePacketStackRecord(packet: packet, recievedFrom: packet.header.transmitedByUID, sentToNodes: transmitedToPeers, status:BrutForcePacketStatus.Sent)
                self.packetStack.append(newStackItem)
                forwardPacketToPeer(interface, packet:packet, peerIndex:peerToSendPacketIndex)
            }
            else
            {
                log(2, "\(node.txt) cannot find a peer for a NEW \(packet.txt) returning with give up status")
                
                // send back to the origin
                node.nodeStats.addNodeStatsEvent(StatsEvents.PacketWithGiveUpFlagSent)
                var updatedPacket=packet
                updatedPacket.header=packet.header.replyHeader()
                updatedPacket.header.lifeCounterAndFlags.setGiveUpFlag(true)
                updatedPacket.envelope=packet.envelope
                
                
                
                interface.sendPacketToNetwork(updatedPacket)
                
                
                
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
    
    func selectPeerForAddressFromAllPeers(address:UNodeAddress) -> Int?
    {
        
        // Here the brutality of brutal force takes place...
        
        var result:Int?
        if(node.peers.count > 0)
        {
            result = Int(arc4random_uniform(UInt32(node.peers.count)))
        }
        
        return result
    }
    
    
    func selectPeerFromIndexListAfterExclusions(address:UNodeAddress, peerIndexes:[Int]) -> Int?
    {
        var result:Int?
        if(node.peers.count > 0)
        {
            result = Int(arc4random_uniform(UInt32(peerIndexes.count)))
        }
        
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
    
    
    
    
    
}


struct BruteForcePacketStackRecord {
    
    var packet:UPacket
    var recievedFrom:UNodeID
    var sentToNodes:[UNodeID]
    var status:BrutForcePacketStatus
}


enum BrutForcePacketStatus:Int {
    case WaitingForRoute
    case Sent
    case Delivered
    
}


