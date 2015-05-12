//
//  UNAppSearch.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/12/15.
//

import Foundation

class UNAppSearch
{
    var idSearches = [UInt64: IdSearchDictRecord]()
    var addressSearches = [UInt64: AddressSearchDictRecord]()
    
    
    let node:UNode
    
    init(node:UNode)
    {
        self.node=node
        
    }
    
    func findIdForName(name:String, app:UAppProtocol)
    {
        //  Destination of packet is specified in envelope, but not treated as id or address but route for packet.
        
        var searchCargo = UPacketSearchIdForName(nameToSearch: name)
        searchCargo.searchSerial = random64()
        
        let newIdSearchEntry = IdSearchDictRecord(name: name, appId: app)
        
        idSearches[searchCargo.searchSerial] = newIdSearchEntry
        

        for (_, address) in enumerate(searchStoreAddresses)
        {
            let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: UNodeID(), toAddress: address)
            node.router.getPacketToRouteFromNode(envelope, cargo: UPacketType.SearchIdForName(searchCargo))
        }
    }
    
    func idFound(packetCargo:UPacketReplyForIdSearch)
    {
        
        if let record = idSearches[packetCargo.searchRequestSerial]
        {
            node.knownIDs[record.name] = UMemoryNameIdRecord (anId: packetCargo.foundId, aTime: 0)
            node.nodeStats.addNodeStatsEvent(StatsEvents.SearchForNameSucess)

            record.appId.getIdSearchResults(record.name, id: packetCargo.foundId)
            
            idSearches[packetCargo.searchRequestSerial] = nil
            
            
        }
        else
        {
            log(6,"No serial for id search, propably found ealier")
        }
    }
    
    func findAddressForId(id:UNodeID, app:UAppProtocol)
    {
        var cargo = UPacketSearchAddressForID(anId: id, aTime: UInt64(0))
        cargo.searchSerial = random64()
        
        let newSearchForAddressRecord = AddressSearchDictRecord(id: id, appId: app)
        
        addressSearches[cargo.searchSerial] = newSearchForAddressRecord
     
        for (_, address) in enumerate(searchStoreAddresses)
        {
            let envelope=UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: UNodeID(), toAddress: address)
            node.router.getPacketToRouteFromNode(envelope, cargo: UPacketType.SearchAddressForID(cargo))
        }
    }
    
    func addressFound(packetCargo:UPacketReplyForAddressSearch)
    {
        if let searchRecord = addressSearches[packetCargo.searchRequestSerial]
        {
            node.knownAddresses[searchRecord.id] = UMemoryIdAddressRecord(anAddress: packetCargo.address, aTime: 0)
            node.nodeStats.addNodeStatsEvent(StatsEvents.SearchForAddressSucess)

            searchRecord.appId.getAddressSearchResults(searchRecord.id, address: packetCargo.address)
            addressSearches[packetCargo.searchRequestSerial] = nil
            
          
            
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

struct IdSearchDictRecord
{
    var name:String
    var appId:UAppProtocol
}
struct AddressSearchDictRecord
{
    var id:UNodeID
    var appId:UAppProtocol
}