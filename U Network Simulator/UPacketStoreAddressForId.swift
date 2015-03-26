//
//  UPacketAddressForIdStore.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/28/15.

//

import Foundation

struct UPacketStoreAddressForId {

    var id:UNodeID
    var address:UNodeAddress
    var time:UInt64
    
    init(anID:UNodeID, anAddress:UNodeAddress, aTime:UInt64)
    {
        self.id = anID
        self.address = anAddress
        self.time = aTime
        
    }
    
}