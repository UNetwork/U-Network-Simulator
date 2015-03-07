//
//  UPacketBasicDiscoveryReply.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/21/15.
//

import Foundation

struct UPacketyReplyForDiscovery
{
   
    
        var levelAndFlags:UPacketDiscoveryBroadcastReplyCounterAndFlags
    
    init()
    {
        self.levelAndFlags=UPacketDiscoveryBroadcastReplyCounterAndFlags()
    }
    
}

struct UPacketDiscoveryBroadcastReplyCounterAndFlags {
    
    var data:UInt64
    
    init()
    {
    
    data=0
    
    
    }
    
    /*
    
    hoop counter 8 bit
    request type 8 bit
    serial 48 bits
    
    
    */
    
}