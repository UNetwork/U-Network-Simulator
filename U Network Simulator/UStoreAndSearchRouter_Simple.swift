//
//  UStoreAndSearchRouter_Simple.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/13/15.
//

import Foundation

class UStoreAndSearchRouterSimple:UStoreAndSearchRoutingProtocol {
    
    var node:UNode
    
    init(node:UNode)
    {
        self.node=node
    }
    
    func storeName(depth:UInt32)
    {
        let header=UPacketHeader(from: node.id, to: node.id, lifeTime: depth)
        let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: UNodeID(), toAddress: aboveNorthPoleRight)
        let storeCargo=UPacketStoreIdForName(name: node.userName, id:node.id)
        
        node.processStoreIdForName(header, envelope: envelope, request: storeCargo)
        
        
    }
    
    func storeAddress()
    {
        
    }
    
    func selectNodeForPacketForwarding(envelope:UPacketEnvelope) -> Int
    {
        return 0
    }
    
    
    func getStoreOrSearchPacket(packet:UPacket)
    {
        // drop the forward bit
        var newPacket=packet
        newPacket.envelope.destinationUID=packet.header.transmitedToUID    //just any id other then broadcast and self to avoid any confusions
        
        // new serial to avoid confiusion with the forwarding information packet
        newPacket.envelope.serial=random64()

        // send to all peers and find best one to forward the packet
        var bestPeerIndex:Int?
        
        
        let latitudeSummingSign=falseToMinus(packet.envelope.destinationAddress.latitude == maxLatitude)
        let longitudeSummingSign=falseToMinus(packet.envelope.destinationAddress.longitude == maxLongitude)
        let altitudeSummingSign=falseToMinus(packet.envelope.destinationAddress.altitude == maxAltitude)

        
        var bestSummedPeerDistance:Int64 = 0
        
        
        
        for (index, peer) in enumerate(node.peers)
        {
           // update header
            newPacket.header.transmitedByUID = node.id
            newPacket.header.transmitedToUID = peer.id
            newPacket.envelope.destinationUID = peer.id
            newPacket.envelope.destinationAddress = peer.address
            
            
            
            peer.interface.sendPacketToNetwork(newPacket)
            
            // select a peer according to tips in destination fields in envelope
            
            let distanceVector = node.address.positionToAddress(peer.address)
            
            let summedDistanceInRightDirection = latitudeSummingSign * distanceVector.deltaLat + longitudeSummingSign * distanceVector.deltaLong + altitudeSummingSign * distanceVector.deltaAlt

            if (summedDistanceInRightDirection > bestSummedPeerDistance)
            {
                bestSummedPeerDistance = summedDistanceInRightDirection
                bestPeerIndex = index
            }
            
        }
        if (bestPeerIndex != nil)
        {
            var updatedPacket=packet
            updatedPacket.header.transmitedByUID = node.id
            updatedPacket.header.transmitedToUID = node.peers[bestPeerIndex!].id
            updatedPacket.header.lifeCounterAndFlags.decreaseLifeCounter()
            updatedPacket.envelope.destinationUID = node.peers[bestPeerIndex!].id
            updatedPacket.envelope.destinationAddress = node.peers[bestPeerIndex!].address
            
            // send to selected peer with broadcast and old serial
            
            if(updatedPacket.header.lifeCounterAndFlags.lifeCounter() > 0)
            {
               // node.peers[bestPeerIndex!].interface.sendPacketToNetwork(updatedPacket)
                
            }
            else
            {
                // Send DroppedRaport
                log(6,"dropped 1")
            }
        }
        else
        {
            // Send DroppedRaport
            log(6,"dropped 2")

            
        }
        
        
    }
}

func falseToMinus(sign:Bool) -> Int64
{
    if(sign == false)
    {
        return Int64(-1)
    }
    else
    {
        return Int64(1)
    }
}

// some orientation points for data search and distribition packets

let aboveNorthPoleLeft=UNodeAddress(inputLatitude: maxLatitude, inputLongitude:  UInt64(0), inputAltitude: maxAltitude)
let belowNorthPoleLeft=UNodeAddress(inputLatitude: maxLatitude, inputLongitude:  UInt64(0), inputAltitude: UInt64(0))
let aboveSouthPoleLeft=UNodeAddress(inputLatitude: UInt64(0), inputLongitude:  UInt64(0), inputAltitude: maxAltitude)
let belowSouthPoleLeft=UNodeAddress(inputLatitude: UInt64(0), inputLongitude: UInt64(0), inputAltitude: UInt64(0))

let aboveNorthPoleRight=UNodeAddress(inputLatitude: maxLatitude, inputLongitude:  maxLongitude, inputAltitude: maxAltitude)
let belowNorthPoleRight=UNodeAddress(inputLatitude: maxLatitude, inputLongitude:  maxLongitude, inputAltitude: UInt64(0))
let aboveSouthPoleRight=UNodeAddress(inputLatitude: UInt64(0), inputLongitude:  maxLongitude, inputAltitude: maxAltitude)
let belowSouthPoleRight=UNodeAddress(inputLatitude: UInt64(0), inputLongitude: maxLongitude, inputAltitude: UInt64(0))
