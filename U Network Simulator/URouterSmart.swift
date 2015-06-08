//
//  URouterSmart.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 08/06/15.
//

import Foundation

class URouterSmart: URouterSimpleDirection
{
    var smartRouterMemory = [UNodeID:SmartRouterRecord]()
    
    override func   getPacketToRouteFromNode(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
        
        
        
        
        
        super.getPacketToRouteFromNode(interface, packet: packet)
    }
    
    override func getReceptionConfirmation(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
        super.getReceptionConfirmation(interface, packet: packet)
    }

    
    override func selectPeerFromIndexListAfterExclusions(toAddress:UNodeAddress, peerIDs:[UNodeID]) -> UNodeID?
    {
        var result:UNodeID?

        
        
        return result
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

struct SmartRouterRecord
{
    var direction:NetworkDirection
    var distance:UInt64
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