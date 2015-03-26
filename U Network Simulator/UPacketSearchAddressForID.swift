//
//  UPacketSearchAddressForID.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/28/15.

//

import Foundation

struct UPacketSearchAddressForID {

    var id:UNodeID
    var time:UInt64
    
    init (anId:UNodeID, aTime:UInt64)
    {
        self.id=anId
        self.time=aTime
    }

}