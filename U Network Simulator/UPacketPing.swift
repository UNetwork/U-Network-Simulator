//
//  UPacketPing.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/28/15.

//

import Foundation

struct UPacketPing {

    let serial:UInt64
    
    init()
    {
        serial=random64()
    }
    

}