//
//  UNAppSearch.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/12/15.
//

import Foundation

class UNAppSearch
{
    var nameSearchTable=[NameSearchTableRecord]()
    var addressSearchTable=[AddressSearchTableRecord]()
    

    let node:UNode
    
    init(node:UNode)
    {
        self.node=node
    }
    
    func findIdForName(name:String, depth:UInt32)
    {
      //  Destination of packet is specified in envelope, but not treated as id or address but route for packet.
        let header=UPacketHeader(from: node.id, to: node.id, lifeTime: depth)
        let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: UNodeID(), toAddress: aboveNorthPoleRight)
        let searchCargo=UPacketSearchIdForName(nameToSearch: name)
        
        let searchTableRecord = NameSearchTableRecord(searchedName: name, searchSerial: searchCargo.searchSerial)
        
        self.nameSearchTable.append(searchTableRecord)

        node.processSearchIdForName(header, envelope: envelope, request: searchCargo)
        
    }
    
    func nameFound(packetCargo:UPacketReplyForIdSearch)
    {
      node.nodeStats.addNodeStatsEvent(StatsEvents.SearchForNameSucess)
    }
    
    func findAddressForId(id:UNodeID)
    {
        
    }
    
    func addressFound(packetCargo:UPacketReplyForAddressSearch)
    {
        
    }



}

struct NameSearchTableRecord
{
    var searchedName:String=""
    var searchSerial:UInt64=0
}

struct AddressSearchTableRecord {
    var searchedId:UNodeID
    var searcheSearial:UInt64
}
