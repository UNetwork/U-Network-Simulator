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

struct UPacket
{
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
    
    var txt:String
    {
        var result=""
        switch self.packetCargo
        {
        case .ReceptionConfirmation(let _): result += "RCNF "
        case .DiscoveryBroadcast(let _): result += "DBRD "
        case .ReplyForDiscovery(let _): result += "RDBR "
        case .ReplyForNetworkLookupRequest(let _): result += "RNDL "
        case .SearchIdForName(let cargo): result += "SID: \(cargo.name) "
        case .StoreIdForName(let cargo): result += "STRI: \(cargo.name) "
        case .SearchAddressForID(let cargo): result += "SADR "
        case .StoreAddressForId(let _): result += "STRA "
        case .ReplyForIdSearch(let _): result += "RSID "
        case .ReplyForAddressSearch(let _): result += "RSAD "
        case .Ping(let _): result += "PING "
        case .Pong(let _): result += "PONG "
        case .Data(let _): result += "DATA "
        case .DataDeliveryConfirmation(let _): result += "DCNF "
        case .Dropped(let _): result += "RIP "
            
        default: result += "UNKNOWN"
            
        }

result += "\(self.header.transmitedByUID.txt) \n   H.TO:\(self.header.transmitedToUID.txt) E.FROM: \(self.envelope.orginatedByUID.txt) E.TO: \(self.envelope.destinationUID.txt)"
        result += " ser: \(self.envelope.serial)"
        return result
    }
    
}

enum UPacketType
{
    
    case ReceptionConfirmation (UPacketReceptionConfirmation)                   // confirmation of delivery of every packet between directly connected nodes (peer)
    case DiscoveryBroadcast (UPacketDiscoveryBroadcast)                         // broadcast packet for obtaining or refresing peers
    case ReplyForDiscovery (UPacketyReplyForDiscovery)                          // reply for discovery request
    case ReplyForNetworkLookupRequest (UPacketReplyForNetworkLookupRequest)     // reply for attached to packet lookUpRequest
    case SearchIdForName (UPacketSearchIdForName)                               // request for search for id given name
    case ReplyForIdSearch (UPacketReplyForIdSearch)                             // reply for search for id given name
    case StoreIdForName (UPacketStoreIdForName)                                 // store name request
    case StoreNamereply (UPacketStoreNamereply)                                 // repaly for name store request
    case SearchAddressForID (UPacketSearchAddressForID)                         // request for search for address given id
    case ReplyForAddressSearch (UPacketReplyForAddressSearch)                   // reply for search for address given id
    case StoreAddressForId (UPacketStoreAddressForId)                           // store address request
    case Ping (UPacketPing)                                                     // ping packet
    case Pong (UPacketPong)                                                     // reply for ping
    case Data (UPacketData)                                                     // workmule of the network transfer
    case DataDeliveryConfirmation (UPacketDataDeliveryConfirmation)             // end point data packet sucessful transfer confirmation
    case Dropped (UPacketDropped)                                               // information sent to the packet originator in case of not delivery and no route possibilities or lifttime expire

}