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
    
    var nodeAPI:UNodeAPI {get set}
    
    func getDataPacket(name:String, envelope:UPacketEnvelope, data:[UInt64])
    
    func getUNetworkError(error:UNetworkAPIError)
    
    
    
    
    
    
    
    
    
    
    
    /*
    
    
    func getDataDeliveryConfirmation(envelope:UPacketEnvelope, data:UPacketDataDeliveryConfirmation)
    
    func getIdSearchResults(result:UPacketReplyForIdSearch, forName:String)
    
    func getAddressSearchResult(result:UPacketReplyForAddressSearch)
    
    func getPong(envelope:UPacketEnvelope, serial:UInt64)
    */
    
}


struct UNetworkAPIError {
    var flags:UInt64=0
}