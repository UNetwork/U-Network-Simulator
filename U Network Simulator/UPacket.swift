//
//  UPacket.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/21/15.
//


/*
This is structure that holds all data transmitted through the network.
Optional lookUpRequest is used to attach to some of trespassing packets to find out how they go through.
*/

import Foundation

struct UPacket {
    var header:UPacketHeader
    var lookUpRequest:UNetworkLookUpRequest?
    var envelope:UPacketEnvelope
    var packetCargo:UPacketType
    
    init(inputHeader:UPacketHeader, inputEnvelope:UPacketEnvelope, inputCargo:UPacketType)
    {
        self.header=inputHeader
        self.envelope=inputEnvelope
        self.packetCargo=inputCargo
    
    }
   mutating func addLookupRequest (request:UNetworkLookUpRequest)
    {
        self.lookUpRequest = request
    }
}

enum UPacketType {
    
    
    
    case ReceptionConfirmation (UPacketReceptionConfirmation)                   // confirmation of delivery of every packet between directly connected nodes (peer)
    case DiscoveryBroadcast (UPacketDiscoveryBroadcast)                         // broadcast packet for obtaining or refresing peers
    case ReplyForDiscovery (UPacketyReplyForDiscovery)                          // replay for discovery request
    case ReplyForNetworkLookupRequest (UPacketReplyForNetworkLookupRequest)     // replay for attached to packet lookUpRequest
    case SearchIdForName (UPacketSearchIdForName)                               // request for search for id given name
    case ReplyForIdSearch (UPacketReplyForIdSearch)                             // replay for search for id given name
    case StoreIdForName (UPacketStoreIdForName)                                 // store name request
    case SearchAddressForID (UPacketSearchAddressForID)                         // request for search for address given id
    case ReplyForAddressSearch (UPacketReplyForAddressSearch)                   // replay for search for address given id
    case StoreAddressForId (UPacketStoreAddressForId)                           // store address request
    case Ping (UPacketPing)                                                     // ping packet
    case Pong (UPacketPong)                                                     // replay for ping
    case Data (UPacketData)                                                     // workmule of the network transfer
    case DataDeliveryConfirmation (UPacketDataDeliveryConfirmation)             // end point data packet sucessful transfer confirmation

}