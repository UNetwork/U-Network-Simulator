//
//  UNAppStats.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/3/15.

//

/*
This is an example of "internal" app. This kind of apps can be hooked more to the node than regular api for apps.
*/

import Foundation

class UNAppNodeStats {
    
    var nodeStats = Array(count: StatsEvents.allValues.count, repeatedValue: 0)
    
    func addNodeStatsEvent(event:StatsEvents)
    {
      
            nodeStats[event.rawValue]++
     
    }
    
}


enum StatsEvents:Int
{
    case
    
    DiscoveryBroadcastSent = 0,
    DiscoveryBroadcastPacketProcessed,
    
    PingSent,
    PingReceived,
    
    PongSent,
    PongReceived,
    PingHadAPongWithProperSerial,
    PongSerialError,
    
    TrespassingPacketProcessedByNode,
    
    PacketDroppedAtInterface,
    PacketRejected,
    PacketConfirmedOK,
    PacketWithGiveUpFlagSent,
    PacketWithGiveUpFlagReceived,
    
    SearchIdForNameProcessed,
    SearchForNameSucess,
    
    StoreIdForNameProcessed,
    SearchAddressForIdProcessed,
    StoreAddressForIdProcessed,
    
    SearchForAddressSucess,
    
    IdSearchResultReceived,
    AddressSearchResultReceived,
    DataSent,
    DataReceived,
    DataConfirmationSent,
    DataConfirmationReceived,
    LookupRequestsAdded,
    LookupRequestProcessed,
    PacketDropped,
    DropPacketDropped,
    PacketReturnedToSender
    
    static let allValues = ["DiscoveryBroadcastSent", "DiscoveryBroadcastPacketProcessed", "PingSent", "PingReceived", "PongSent", "PongReceived", "PingHadAPongWithProperSerial", "PongSerialError", "TrespassingPacketProcessedByNode",  "PacketDroppedAtInterface", "PacketRejected", "PacketConfirmedOK", "PacketWithGiveUpFlagSent", "PacketWithGiveUpFlagReceived", "SearchIdForNameProcessed", "SearchForNameSucess", "StoreIdForNameProcessed", "SearchAddressForIdProcessed", "StoreAddressForIdProcessed", "SearchForAddressSucess", "IdSearchResultReceived", "AddressSearchResultReceived", "DataSent", "DataReceived", "DataConfirmationSent", "DataConfirmationReceived", "LookupRequestsAdded", "LookupRequestProcessed", "PacketDropped", "DropPacketDropped", "PacketReturnedToSender"]

}