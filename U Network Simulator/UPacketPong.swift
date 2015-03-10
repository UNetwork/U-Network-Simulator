//
//  UPacketPong.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/28/15.

//

import Foundation

struct UPacketPong {

     let serialOfPing:UInt64
    
    init(serialOfPing:UInt64)
    {
        self.serialOfPing=serialOfPing
    }
    
}