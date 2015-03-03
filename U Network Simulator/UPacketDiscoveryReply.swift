//
//  UPacketBasicDiscoveryReply.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/21/15.
//

import Foundation

struct UPacketDiscoveryReply
{
   
        var envelope:UPacketEnvelope
        var levelAndFlags:UPacketDiscoveryBroadcastReplyCounterAndFlags
        var key=[UInt64]()
    
}

struct UPacketDiscoveryBroadcastReplyCounterAndFlags {
    
    var data:UInt64
    
    /*
    
    hoop counter 8 bit
    request type 8 bit
    serial 48 bits
    
    
    */
    
}