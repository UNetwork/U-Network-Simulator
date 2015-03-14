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
    
    var nodeStats = Array(count: 64, repeatedValue: 0)
    
    func addNodeStatsEvent(event:StatsEvents)
    {
    nodeStats[event.rawValue]++
    }
    
}


enum StatsEvents:Int
{
    case
    
            PingSent = 0,
            PingRecieved,
            PongSent,
            PongRecieved,
            PingHadAPongWithProperSerial,
            PongSerialError,

            TrespassingPacketProcessedByNode,
            DiscoveryBroadcastPacketProcessed,
    
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
    LookupRequestProcessed
    
    static let allValues = ["PingSent", "PingRecieved", "PongSent", "PongRecieved", "PingHadAPongWithProperSerial", "PongSerialError", "TrespassingPacketProcessedByNode", "DiscoveryBroadcastPacketProcessed", "PacketDroppedAtInterface", "PacketRejected", "PacketConfirmedOK", "PacketWithGiveUpFlagSent", "PacketWithGiveUpFlagRecieved", "SearchIdForNameProcessed", "SearchForNameSucess", "StoreIdForNameProcessed", "SearchAddressForIdProcessed", "StoreAddressForIdProcessed", "IdSearchResultRecieved", "AddressSearchResultRecieved", "DataSent", "DataRecieved", "DataConfirmationSent", "DataConfirmationRecieved", "LookupRequestsAdded", "LookupRequestProcessed"]

}