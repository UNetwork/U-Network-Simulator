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
            if(packet.header.lifeCounterAndFlags.replayConfirmationType)
            {
                // this is rejected packet by peer
                // resend to another peer
                self.getPacketToRouteFromNode(nil, packet: packetStack[packetIndex].packet)
            }
            else
            {
                //confirmation ok
                packetStack[packetIndex].status=BrutForcePacketStatus.Delivered
            }
        }
        else
        {
            // rejected packet not found on packet stack

        }
        
    }
    

    
    func getReplyForNetworkLookupRequest(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    func   getPacketToRouteFromNode(interface:UNetworkInterfaceProtocol?, packet:UPacket)
    {
        
        if let packetIndex = searchForSerialOnStack(packet.envelope.serial)
        {
            if(packet.header.lifeCounterAndFlags.isGiveUp)
            {
                // returning, new peer must be selected
                var peersIndexes = selectPeersExcluding(packetStack[packetIndex].sentToNodes)
                if let peerToSendPacketIndex = selectPeerFromIndexListAfterExclusions(packet.envelope.destinationAddress, peerIndexes: peersIndexes)
                {
                    packetStack[packetIndex].sentToNodes.append(node.peers[peerToSendPacketIndex].id)
                    forwardPacketToPeer(interface, packet: packet, peerIndex: peerToSendPacketIndex)
                }
                else
                {
                    // send back to the origin
                    
                    var originIndex = searchForIdInNodePeers(packetStack[packetIndex].recievedFrom)
                    var updatedPacket=packet
                    updatedPacket.header.lifeCounterAndFlags.setGiveUpFlag(true)
                    
                    if(originIndex != nil)
                    {
                        forwardPacketToPeer(interface, packet: updatedPacket, peerIndex: originIndex!)
                    }
                }
            }
            else
            {
                if(interface != nil)
                {
                    // packet already processed, send negative packet delivery
                    sendPacketDeliveryConfirmation(interface!, packet: packet, rejected:true)
                }
            }
        }
        else
        {
            // select peer
            if let peerToSendPacketIndex = selectPeerForAddressFromAllPeers(packet.envelope.destinationAddress)
            {
                // add to packet to stack
                
                var transmitedToPeers=[UNodeID]()
                transmitedToPeers.append(node.peers[peerToSendPacketIndex].id)
                let newStackItem=BruteForcePacketStackRecord(packet: packet, recievedFrom: packet.header.transmitedByUID, sentToNodes: transmitedToPeers, status:BrutForcePacketStatus.Sent)
                forwardPacketToPeer(interface!, packet:packet, peerIndex:peerToSendPacketIndex)
            }
            else
            {
                log(7, " no peer to send error ")
                // no peer to send error -
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
    
    
    func selectPeerFromIndexListAfterExclusions(addresss:UNodeAddress, peerIndexes:[Int]) -> Int?
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
        var header=UPacketHeader(from: node.id, to: packet.header.transmitedToUID, lifeTime: 16)
        header.lifeCounterAndFlags.setConfirmationType(rejected)
        let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: packet.header.transmitedToUID, toAddress: unknownNodeAddress)
        let receptionConfirmation=UPacketReceptionConfirmation(serial: packet.envelope.serial)
        let receptionConfirmationCargo=UPacketType.ReceptionConfirmation(receptionConfirmation)
        
        let confirmationReceptionPacket=UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: receptionConfirmationCargo)
        
        
        interface.sendPacketToNetwork(confirmationReceptionPacket)
        
    }
    
    
    func forwardPacketToPeer(interface:UNetworkInterfaceProtocol?, packet:UPacket, peerIndex:Int)
    {
        // send  reception confirmation
        
        if(interface != nil)
        {
            sendPacketDeliveryConfirmation(interface!, packet: packet, rejected:false)
            
        }
        // here the networklookuprequest may be attached
        
        
        // puch to the interface
        
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


