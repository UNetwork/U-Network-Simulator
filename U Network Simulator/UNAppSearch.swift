//
//  UNAppSearch.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/12/15.
//

import Foundation

class UNAppSearch
{
    var idSearches = [UInt64: String]()
    var addressSearches = [UInt64: UNodeID]()
    
    
    let node:UNode
    
    init(node:UNode)
    {
        self.node=node
        
    }
    
    func findIdForName(name:String, serial:UInt64)
    {
        //  Destination of packet is specified in envelope, but not treated as id or address but route for packet.
        
        var searchCargo=UPacketSearchIdForName(nameToSearch: name)
        searchCargo.searchSerial = serial
        idSearches[serial] = name
        
        for (_, address) in enumerate(searchStoreAddresses)
        {
            let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: UNodeID(), toAddress: address)
            node.router.getPacketToRouteFromNode(envelope, cargo: UPacketType.SearchIdForName(searchCargo))
        }
    }
    
    func idFound(packetCargo:UPacketReplyForIdSearch)
    {
        
        if let name = idSearches[packetCargo.searchRequestSerial]
        {
            node.knownIDs[name] = UMemoryNameIdRecord (anId: packetCargo.foundId, aTime: 0)
            node.dataApp.recieveIdSearchResults(packetCargo)
            node.nodeStats.addNodeStatsEvent(StatsEvents.SearchForNameSucess)
        }
        else
        {
            log(6,"No serial for id search")
        }
    }
    
    func findAddressForId(id:UNodeID, serial:UInt64)
    {
        var cargo = UPacketSearchAddressForID(anId: id, aTime: UInt64(0))
        cargo.searchSerial = serial
        addressSearches[serial] = id
     
        for (_, address) in enumerate(searchStoreAddresses)
        {
            let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: UNodeID(), toAddress: address)
            node.router.getPacketToRouteFromNode(envelope, cargo: UPacketType.SearchAddressForID(cargo))
        }
    }
    
    func addressFound(packetCargo:UPacketReplyForAddressSearch)
    {
        if let id = addressSearches[packetCargo.searchRequestSerial]
        {
            node.knownAddresses[id] = UMemoryIdAddressRecord(anAddress: packetCargo.address, aTime: 0)
            node.dataApp.recieveAddressSearchResults(packetCargo)
            node.nodeStats.addNodeStatsEvent(StatsEvents.SearchForAddressSucess)
        }
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

