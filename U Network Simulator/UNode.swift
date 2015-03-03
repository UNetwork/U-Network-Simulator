//
//  UNode.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/19/15.
//

import Foundation

class UNode {
    
    
    let id:UNodeID
    var address:UNodeAddress?
    
    var interfaces=[UNetworkInterfaceProtocol]()
    
    var router:URouterProtocol!
    
    var peers=[UPeerDataRecord]()
    
    var knownaddresses=[UAddressMemoryRecord]()
    

    
    //  Init
    
    init ()
    {
        id=UNodeID(lenght: uIDlengh)
        router = URouter_BruteForceRouting(node:self)
    }
 
    func getPacketFromInterface(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
        // decode type of packet
        
        
        
        // for me?
        
        
        // broadcast?
        self.router.getPacketToRouteFromNode(packet)
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    func refreshPeers()
    {
        // assemble packet and deliver to all interfaces
    }
    
    func ping(uID:UNodeID, address:UNodeAddress)
    {
        
    }
    
 
    
    
    
    
}


