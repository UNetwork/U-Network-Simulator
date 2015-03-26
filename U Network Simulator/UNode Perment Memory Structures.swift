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
    
    init (aId:UNodeID, anAddress:UNodeAddress, aTime:UInt64)
    {
        self.id = aId
        self.address = anAddress
        self.time = aTime
    }
    
}

struct UMemoryNameIdRecord
{
    var name:String
    var id:UNodeID
    var time:UInt64
    
    
    init(aName:String, anId:UNodeID, aTime:UInt64)
    {
        self.name=aName
        self.id=anId
        self.time = aTime
    }
    
    
}

struct UNodeContacts {
    
}




