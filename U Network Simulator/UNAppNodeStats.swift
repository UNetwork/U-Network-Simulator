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
    
    func addNodeStatsEvent(event:StatsEvents)
    {
    
    }
    
}


enum StatsEvents:Int{
    
    
    case    TrespassingPacketProcessedByNode = 0,
            PacketDroppedAtInterface,
            DiscoveryBroadcastPacketProcessed,
            SearchIdForNameProcessed,
            StoreIdForNameProcessed,
            SearchAddressForIdProcessed,
            StoreAddressForIdProcessed,
            IdSearchResultRecieved,
            AddressSearchResultRevieved,
            PingRecieved,
            PingSent,
            PongRevieved,
            PongSent,
            DataSent,
            DataConfirmationRecieved,
            LookupRequestsAdded,
            LookupReguestProcessed
    
    
    
    
    
    
    
    
}