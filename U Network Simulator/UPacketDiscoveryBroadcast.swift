//
//  UPacketDiscoveryBroadcast.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/21/15.
//

import Foundation

struct UPacketDiscoveryBroadcast
{

    var levelAndFlags:UPacketDiscoveryBroadcastCounterAndFlags
}

struct UPacketDiscoveryBroadcastCounterAndFlags {
    
    var data:UInt64
    
    /*
    
    hoop counter 8 bit
    request type 8 bit
    serial 48 bits
    
    
    */
    
}