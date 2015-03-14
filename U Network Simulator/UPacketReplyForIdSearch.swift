//
//  UPacketReplyForIdSearch.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/28/15.

//

import Foundation

struct UPacketReplyForIdSearch {

    var searchRequestSerial:UInt64
    var foundId:UNodeID
    
    init(id:UNodeID, serial:UInt64)
    {
        
        self.foundId=id
        self.searchRequestSerial=serial
        
    }
}