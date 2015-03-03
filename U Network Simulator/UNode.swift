//
//  UNode.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/19/15.
//

import Foundation

/*
This is basic class of the U Network. U Node communicates with interfaces to the networks.
Node has a router responsible for choosing the next currently connected node (peer)
to transmit the trespassing packet. Node is servicing user application with U Network Services.
*/

class UNode {
    
    
    let id:UNodeID                                  // Unique Id
    var address:UNodeAddress?                       // Current Address - geographical position
    var time:UInt64 = 0                             // Local "time"
    
    var interfaces=[UNetworkInterfaceProtocol]()    // Array of network interfaces
    var router:URouterProtocol!                     // Handler for router
    var peers = [UPeerDataRecord]()                 // Currently available connected peers
    var knownAddresses = [UMemoryIdAddressRecord]() // Memory of search for address service
    var knownNames  = [UMemoryNameIdRecord]()       // Memory of search for name service
    
    var contacts = [UNodeContacts] ()               // Commonly contacted noods, contacts

    //  Init
    
    init ()
    {
        id=UNodeID(lenght: uIDlengh)
        router = CurrentRouter(node:self)
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


