//
//  URouter_SimpleDirection.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/10/15.
//

import Foundation


class URouterSimpleDirection: URouter_BruteForceRouting
{
    
    override func selectPeerFromIndexListAfterExclusions(inputAddress:UNodeAddress, peerIndexes:[Int]) -> Int?
    {
        var result:Int?
        
        var address = inputAddress
        
        
        if ((address.latitude == UInt64(0) || address.latitude == maxLatitude) && (address.longitude == UInt64(0) || (address.longitude == maxLongitude) && (address.altitude == UInt64(0)) || address.altitude == maxAltitude))
        {
///
        address=findAddressForSearchOrStorePacket(address)
        
        
        }
       
            var smallestDifferenceToAddress:UInt64 = 1 << 63
            for(_, index) in enumerate(peerIndexes)
            {
                let dlat=unsignedDifference(address.latitude, node.peers[index].address.latitude)
                let dlong=unsignedDifference(address.longitude, node.peers[index].address.longitude)
                let dalt=unsignedDifference(address.altitude, node.peers[index].address.altitude)
                
                if ( dlat + dlong + dalt < smallestDifferenceToAddress)
                {
                    smallestDifferenceToAddress=dlat+dlong+dalt
                    result=index
                }
            }
        
        return result
    }
}