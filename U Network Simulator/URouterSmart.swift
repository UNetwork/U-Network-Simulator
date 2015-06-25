//
//  URouterSmart.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 08/06/15.
//

import Foundation

let numberOfDistanceRanges = UInt64(8)

class URouterSmart: URouterSimpleDirection
{
    
    var sentNetworkLookupRequests = [UInt64:SentNetworkLookupRequestRecord]()
    var replysForNetworkLookupRequest = [ReplyForNetworkLookupRequestRecord]()
    
    var bestPeersForDirectionAndDistance = [[UNodeID]]()
    
     override init(node:UNode)
    {
        
        // Init arrays and sets BUT peers are not known yet?
        
        
        super.init(node: node)
    }
    
    override func selectPeerFromIndexListAfterExclusions(toAddress:UNodeAddress, peerIDs:[UNodeID]) -> UNodeID?
    {
        
        var peersIDsSet = Set <UNodeID>()
        
        for anId in peerIDs{
            peersIDsSet.insert(anId)
        }
        
        var targetArray = bestPeersForDirectionAndDistance[(findDirectionFromAddress(node.address, toAddress).rawValue * 8) + Int(findDistanceRangeFromAddresses(node.address, toAddress))]
        
        var targetSet = Set <UNodeID>()
        
        for anId in targetArray{
            targetSet.insert(anId)
        }
        
        
        var resultSet = targetSet.intersect(peersIDsSet)
        
        
        
        return resultSet.first
    }
    
    override func   getPacketToRouteFromNode(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
        
        
        
        
        
        super.getPacketToRouteFromNode(interface, packet: packet)
    }
    
    override func getReceptionConfirmation(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
        super.getReceptionConfirmation(interface, packet: packet)
    }
    
    

    
    override func getReplyForNetworkLookupRequest(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }

    
    
}

func findDirectionFromAddress (fromAddress:UNodeAddress, toAddress:UNodeAddress) -> NetworkDirection
{
    var result = NetworkDirection.N
    var deltaX = UInt64(0)
    var deltaY = UInt64(0)
    var isEast = false
    var isNorth = false
    
    if fromAddress.latitude > toAddress.latitude
    {
        deltaX = fromAddress.latitude - toAddress.latitude
        isEast = false
    }
    else
    {
        deltaX = toAddress.latitude - fromAddress.latitude
        isEast = true
    }
    
    if fromAddress.longitude > toAddress.longitude
    {
        deltaY = fromAddress.longitude - toAddress.longitude
        isNorth = false
    }
    else
    {
        deltaY = toAddress.longitude - fromAddress.longitude
        isNorth = true
    }
    
    if isNorth
    {
        if deltaX >> 1  < deltaY
        {
            result = NetworkDirection.N
        }
        else if deltaX > deltaY >> 1
        {
            if isEast
            {
                result = NetworkDirection.E
            }
            else
            {
                result = NetworkDirection.W
            }
        }
        else
        {
            if isEast
            {
                result = NetworkDirection.NE
            }
            else
            {
                result = NetworkDirection.NW
            }
            
        }
        
    }
    else
    {
        if deltaX >> 1  < deltaY
        {
            result = NetworkDirection.S
        }
        else if deltaX > deltaY >> 1
        {
            if isEast
            {
                result = NetworkDirection.E
            }
            else
            {
                result = NetworkDirection.W
            }
        }
        else
        {
            if isEast
            {
                result = NetworkDirection.SE
            }
            else
            {
                result = NetworkDirection.SW
            }
            
        }
        
    }
    log(1, "the direction from \(fromAddress.txt) to \(toAddress.txt) is \(result.rawValue)")
    return result
}

func findDistanceRangeFromAddresses(fromAddress:UNodeAddress, toAddress:UNodeAddress) -> UInt64
{
    var deltaX = UInt64(0)
    var deltaY = UInt64(0)
    
    if fromAddress.latitude > toAddress.latitude
    {
        deltaX = fromAddress.latitude - toAddress.latitude
    }
    else
    {
        deltaX = toAddress.latitude - fromAddress.latitude
    }
    
    if fromAddress.longitude > toAddress.longitude
    {
        deltaY = fromAddress.longitude - toAddress.longitude
    }
    else
    {
        deltaY = toAddress.longitude - fromAddress.longitude
    }
    
    
    let distance = (deltaX + deltaY)/(2*wirelessInterfaceRange)
    
    
    
    var result = UInt64(0)
    
    for  i in 1...numberOfDistanceRanges
    {
        if ( (distance >> i) > 0 )
        {
            result = i
        }
        
    }
    
    return result

}


struct SentNetworkLookupRequestRecord
{
    var serial:UInt64
    var peerID:UNodeID
    var toID:UNodeID
    var toAddress:UNodeAddress
    var requestedHoops:UInt64
    var timer = UInt64(0)
}

struct ReplyForNetworkLookupRequestRecord
{
    var peerID:UNodeID
    var toID:UNodeID
    var toAddress:UNodeAddress
    var requestedHoops:UInt64
    var replayFromID:UNodeID
    var replayFromAddress:UNodeAddress
}

enum NetworkDirection:Int
{
    case N = 0
    case NE
    case E
    case SE
    case S
    case SW
    case W
    case NW
}

