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
    PingRecieved,
    
    PongSent,
    PongRecieved,
    PingHadAPongWithProperSerial,
    PongSerialError,
    
    TrespassingPacketProcessedByNode,
    
    PacketDroppedAtInterface,
    PacketRejected,
    PacketConfirmedOK,
    PacketWithGiveUpFlagSent,
    PacketWithGiveUpFlagRecieved,
    
    SearchIdForNameProcessed,
    SearchForNameSucess,
    
    StoreIdForNameProcessed,
    SearchAddressForIdProcessed,
    StoreAddressForIdProcessed,
    IdSearchResultRecieved,
    AddressSearchResultRecieved,
    DataSent,
    DataRecieved,
    DataConfirmationSent,
    DataConfirmationRecieved,
    LookupRequestsAdded,
    LookupRequestProcessed,
    PacketDropped,
    DropPacketDropped
    
    static let allValues = ["DiscoveryBroadcastSent", "DiscoveryBroadcastPacketProcessed", "PingSent", "PingRecieved", "PongSent", "PongRecieved", "PingHadAPongWithProperSerial", "PongSerialError", "TrespassingPacketProcessedByNode",  "PacketDroppedAtInterface", "PacketRejected", "PacketConfirmedOK", "PacketWithGiveUpFlagSent", "PacketWithGiveUpFlagRecieved", "SearchIdForNameProcessed", "SearchForNameSucess", "StoreIdForNameProcessed", "SearchAddressForIdProcessed", "StoreAddressForIdProcessed", "IdSearchResultRecieved", "AddressSearchResultRecieved", "DataSent", "DataRecieved", "DataConfirmationSent", "DataConfirmationRecieved", "LookupRequestsAdded", "LookupRequestProcessed", "PacketDropped", "DropPacketDropped"]

}