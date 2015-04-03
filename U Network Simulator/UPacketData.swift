//
//  UPacketCargo.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/28/15.

//

import Foundation

struct UPacketData {
    
    var appID = UInt64 (0)

    var load = [UInt64]()
    
    
    init (appID:UInt64, data:[UInt64])
    {
        self.appID=appID
        self.load=data
    }
}