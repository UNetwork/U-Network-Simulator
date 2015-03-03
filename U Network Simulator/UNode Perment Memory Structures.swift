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
}

struct UNodeContacts {
    
}




