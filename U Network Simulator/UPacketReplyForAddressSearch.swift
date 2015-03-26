//
//  UPacketReplyForAddressSearch.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/28/15.

//

import Foundation

struct UPacketReplyForAddressSearch {
 
    var id:UNodeID
    var address:UNodeAddress
    var time:UInt64
    
    init(anId:UNodeID, anAddress:UNodeAddress, aTime:UInt64)
        {
            self.id=anId
            self.address=anAddress
            self.time=aTime
        }

}
