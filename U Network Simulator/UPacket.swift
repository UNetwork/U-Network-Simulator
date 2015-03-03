//
//  UPacket.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/21/15.
//

import Foundation

struct UPacket {
    
    var header:UPacketHeader
    var lookUpRequest:UNetworkLookUpRequest?
    var packetCargo:PacketType
    
    
}

enum PacketType {
    
    case PacketReceptionConfirmation (UPacketReceptionConfirmation)
    case DiscoveryBroadcast (UPacketDiscoveryBroadcast)
    case DiscoveryBroadcastReplay (UPacketDiscoveryReply)
    





}