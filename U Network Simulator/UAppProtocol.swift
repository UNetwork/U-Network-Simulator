//
//  UAppProtocol.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/3/15.
//

import Foundation

// this protocol must be implemented by app to run on node


protocol UAppProtocol
{
    var appID:UInt64 {get}
    
    var nodeAPI:UNodeAPI? {get set}
    
    func getIdSearchResults(name:String, id:UNodeID)
    
    func getAddressSearchResults(id:UNodeID, address:UNodeAddress)
    
    func getUNetworkError(error:UNetworkAPIError)
    
    func getDataPacket(name:String, envelope:UPacketEnvelope, data:[UInt64])

    
}


struct UNetworkAPIError {
    var flags:UInt64=0
}