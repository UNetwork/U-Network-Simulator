//
//  UPacketDropped.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/14/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Foundation

struct UPacketDropped {
    var serial:UInt64
    var flags:UInt64
    
    init(serial:UInt64)
    {
        self.serial=serial
        self.flags = 0
    }
}
