//
//  URouter_SimpleDirection.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/10/15.
//

import Foundation


class URouterSimpleDirection: URouter_BruteForceRouting
{
    
    override func selectPeerFromIndexListAfterExclusions(address:UNodeAddress, peerIndexes:[Int]) -> Int?
    {
        var result:Int?
        
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
    
    override func selectPeerForAddressFromAllPeers(address:UNodeAddress) -> Int?
    {
        
        // Here the brutality of brutal force takes place...
        
        var result:Int?
        var smallestDifferenceToAddress:UInt64 = 1 << 63
        
        for(index, peer) in enumerate(node.peers)
        {
            let dlat=unsignedDifference(address.latitude, peer.address.latitude)
            let dlong=unsignedDifference(address.longitude, peer.address.longitude)
            let dalt=unsignedDifference(address.altitude, peer.address.altitude)
            
            if ( dlat + dlong + dalt < smallestDifferenceToAddress)
            {
                smallestDifferenceToAddress=dlat+dlong+dalt
                result=index
            }
            
        }
        
        
        
        
        
        return result
    }
}