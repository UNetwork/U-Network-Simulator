//
//  UPacketSearchIdForName.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/28/15.

//

import Foundation

struct UPacketSearchIdForName {
    
    var name:String
    var searchSerial:UInt64
    
    init(nameToSearch:String)
    {
        self.name=nameToSearch
        self.searchSerial=random64() 
    }

}