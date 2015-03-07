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

    func getReply(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    func   getPacketToRouteFromNode(interface:UNetworkInterfaceProtocol?, packet:UPacket)
    {
    
        if let packetIndex = searchForSerialOnStack(packet.envelope.serial)
        {
            if(packet.header.lifeCounterAndFlags.isGiveUp)
            {
                // returning, new peer must be selected
            }
            else
            {
                if(interface != nil)
                {
                   // packet already processed negative packet delivery
                    
                    sendNegativePacketDelivery(interface!, packet: packet)
                    
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
                
            let newStackItem=BruteForcePacketStackRecord(packet: packet, recievedFrom: packet.header.transmitedByUID, sentToNodes: transmitedToPeers)
            
            
            // send positive reception confirmation
                
                if(interface != nil)
                {
                    sendPositivePacketDelivery(interface!, packet: packet)

                }
            // puch to the interface
                
                var updatedPacket=packet
                updatedPacket.header.transmitedByUID=node.id
                updatedPacket.header.transmitedToUID=node.peers[peerToSendPacketIndex].id
                
                node.peers[peerToSendPacketIndex].interface.sendPacketToNetwork(updatedPacket)
            }
            else
            {
                // no peer to send return to sender with give up sign
            }
        }
        
 
        
    }
    
    init(node:UNode)
    {
        self.node=node
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
    
    // communication functions
    
    func sendPositivePacketDelivery(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    func sendNegativePacketDelivery(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }

    
    
    
    
    
    
}


struct BruteForcePacketStackRecord {
    
    var packet:UPacket
    var recievedFrom:UNodeID
    var sentToNodes:[UNodeID]
    
    
    
}