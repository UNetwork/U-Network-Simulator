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
    var active:Bool
    
    init(nodeId:UNodeID, address:UNodeAddress, interface:UNetworkInterfaceProtocol)
    {
        self.id = nodeId
        self.address = address
        self.interface = interface
        self.active = true
    }
}

struct UMemoryIdAddressRecord
{
    var address:UNodeAddress
    var time:UInt64
    
    init  (anAddress:UNodeAddress, aTime:UInt64)
    {
        self.address = anAddress
        self.time = aTime
    }
    
}

struct UMemoryNameIdRecord
{
    var id:UNodeID
    var time:UInt64
    
    
    init(anId:UNodeID, aTime:UInt64)
    {
        self.id=anId
        self.time = aTime
    }
    
    
}





