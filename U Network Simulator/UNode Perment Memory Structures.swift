//
//  UNode Perment Memory Record.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/22/15.
//

/*
Here we have data structures for node
*/

import Foundation

struct UPeerDataRecord
{
    var id:UNodeID
    var address:UNodeAddress
    var interface:UNetworkInterfaceProtocol
    
    init(nodeId:UNodeID, address:UNodeAddress, interface:UNetworkInterfaceProtocol)
    {
        self.id=nodeId
        self.address=address
        self.interface=interface
    }
}

struct UMemoryIdAddressRecord
{
    var id:UNodeID
    var address:UNodeAddress
    var time:UInt64
}

struct UMemoryNameIdRecord
{
    var name:String
    var id:UNodeID
    var time:UInt64
    
    
    init(name:String, id:UNodeID, time:UInt64)
    {
        self.name=name
        self.id=id
        self.time = time
    }
    
    
}

struct UNodeContacts {
    
}




