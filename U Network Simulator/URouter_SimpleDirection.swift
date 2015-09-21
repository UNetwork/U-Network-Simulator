//
//  URouter_SimpleDirection.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/10/15.
//

import Foundation


class URouterSimpleDirection: URouter_DictionaryBruteForceRouting
{
    
    override func selectPeerFromIndexListAfterExclusions(toAddress:UNodeAddress, peerIDs:[UNodeID]) -> UNodeID?

    {
        var result:UNodeID?
        
        var address = toAddress
        
        
        if ((address.latitude == UInt64(0) || address.latitude == maxLatitude) && (address.longitude == UInt64(0) || (address.longitude == maxLongitude) && (address.altitude == UInt64(0)) || address.altitude == maxAltitude))
        {
///
        address=findAddressForSearchOrStorePacket(address)
        
        
        }
       
            var smallestDifferenceToAddress:UInt64 = 1 << 63
        
        if peerIDs.count > 0
        {
            for anID in peerIDs
            {
                let dlat=unsignedDifference(address.latitude, b: node.peers[anID]!.address.latitude)
                let dlong=unsignedDifference(address.longitude, b: node.peers[anID]!.address.longitude)
                let dalt=unsignedDifference(address.altitude, b: node.peers[anID]!.address.altitude)
                
                if ( dlat + dlong + dalt < smallestDifferenceToAddress)
                {
                    smallestDifferenceToAddress=dlat+dlong+dalt
                    result=anID
                }
            }
        }
        
        return result
    }
}