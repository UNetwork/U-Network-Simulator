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
    
    func findIdForName(name:String)
    {
        
        
        
        //  Destination of packet is specified in envelope, but not treated as id or address but route for packet.
        let searchCargo=UPacketSearchIdForName(nameToSearch: name)
        
        let searchTableRecord = NameSearchTableRecord(searchedName: name, searchSerial: searchCargo.searchSerial)
        
        self.nameSearchTable.append(searchTableRecord)
        
        for (_, address) in enumerate(searchStoreAddresses)
        {
            let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: UNodeID(), toAddress: address)
            node.router.getPacketToRouteFromNode(envelope, cargo: UPacketType.SearchIdForName(searchCargo))
        }
        
        
    }
    
    func nameFound(packetCargo:UPacketReplyForIdSearch)
    {
        node.nodeStats.addNodeStatsEvent(StatsEvents.SearchForNameSucess)

    
    }
    
    func findAddressForId(id:UNodeID)
    {
let cargo=UPacketType.SearchAddressForID(UPacketSearchAddressForID(anId: id, aTime: UInt64(0)))
        for (_, address) in enumerate(searchStoreAddresses)
        {
            let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: UNodeID(), toAddress: address)
            node.router.getPacketToRouteFromNode(envelope, cargo: cargo)
        }
    
     
    
    }
    
    func addressFound(packetCargo:UPacketReplyForAddressSearch)
    {
        node.nodeStats.addNodeStatsEvent(StatsEvents.AddressSearchResultRecieved)
        log(3, "\(node.txt) Address found: \(packetCargo.address.txt) for \(packetCargo.id) ")
        
    }
    
    func storeName()
    {
        
        
        for (_, address) in enumerate(searchStoreAddresses)
        {
            let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: UNodeID(), toAddress: address)
            let storeCargo=UPacketStoreIdForName(name: node.userName, id:node.id)
            
            node.router.getPacketToRouteFromNode(envelope, cargo: UPacketType.StoreIdForName(storeCargo))
        }
        
        
        

        
        
    }
    
    func storeAddress()
    {
        
        for (_, address) in enumerate(searchStoreAddresses)
        {
            let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: UNodeID(), toAddress: address)
            let storeCargo=UPacketStoreAddressForId(anID: node.id, anAddress: node.address, aTime: node.timeCounter)
            
            node.router.getPacketToRouteFromNode(envelope, cargo: UPacketType.StoreAddressForId(storeCargo))
        }

        
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
