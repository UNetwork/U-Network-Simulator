//
//  UNAppDataTransfer.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/12/15.
//

import Foundation

class UNAppDataTransfer
{
    let node:UNode
    var nodeAppsPacketStack = [UInt64:DataStackRecord]()    // 
    
    init(node:UNode)
    {
        self.node=node
    }
    
    func deliverData(name:String, data:[UInt64], appID:UInt64)
    {
        let packetSerial = random64()
        let packetCargo = UPacketData(appID: appID, data: data)
        
        var stackRecord = DataStackRecord(destinationUserName: name, dataCargo: packetCargo, status: UDataTransferStatus.waitingForID, destinationID: nil, destinationAddress: nil)
        
        
        if let destinationIDRecord = node.knownIDs[name]
        {
            stackRecord.destinationID = destinationIDRecord.id
            stackRecord.status = UDataTransferStatus.waitingForAddress
            
            if let destinationAddressRecord = node.knownAddresses[destinationIDRecord.id]
            {
                // we have all data here
                stackRecord.destinationAddress = destinationAddressRecord.address
                
                stackRecord.status = UDataTransferStatus.readyToTransmit
                
                var envelope = UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: destinationIDRecord.id, toAddress: destinationAddressRecord.address)
                
                envelope.serial = packetSerial
                
                node.router.getPacketToRouteFromNode(envelope, cargo: UPacketType.Data(packetCargo))
                
                stackRecord.status = UDataTransferStatus.transmitted
                
                nodeAppsPacketStack[packetSerial] = stackRecord
                
            }
            else
            {
                // no address
                nodeAppsPacketStack[packetSerial] = stackRecord
              //  node.searchApp.findAddressForId(destinationIDRecord.id, serial: packetSerial)
                
            }
            
        }
        else
        {
            // no ID
            nodeAppsPacketStack[packetSerial] = stackRecord
          //  node.searchApp.findIdForName(name, serial: packetSerial)
            
        }
        
        
        
    }
    
    func recieveDataTransferConfirmation (cargo:UPacketDataDeliveryConfirmation)
    {
        nodeAppsPacketStack[cargo.deliveredPacketSerial] = nil      //delete from stack
    }
    
    func recieveIdSearchResults (searchResult:UPacketReplyForIdSearch)
    {
        if var stackRecord = nodeAppsPacketStack[searchResult.searchRequestSerial]
        {
            
            stackRecord.destinationID = searchResult.foundId
            stackRecord.status = UDataTransferStatus.waitingForAddress
            nodeAppsPacketStack[searchResult.searchRequestSerial] = stackRecord
        //    node.searchApp.findAddressForId(searchResult.foundId, serial:searchResult.searchRequestSerial)
            
        }
        else
        {
            log(5, "no serial found for id search replay")
        }
        
        
    }
    
    func recieveAddressSearchResults (searchResult:UPacketReplyForAddressSearch)
    {
        
        if var stackRecord = nodeAppsPacketStack[searchResult.searchRequestSerial]
        {
            
            
            stackRecord.destinationAddress = searchResult.address
            stackRecord.status = UDataTransferStatus.readyToTransmit
            
            var envelope = UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: stackRecord.destinationID!, toAddress:stackRecord.destinationAddress!)
            
            envelope.serial = searchResult.searchRequestSerial
            
            node.router.getPacketToRouteFromNode(envelope, cargo: UPacketType.Data(stackRecord.dataCargo))
            
            stackRecord.status = UDataTransferStatus.transmitted
            
            nodeAppsPacketStack[searchResult.searchRequestSerial] = stackRecord
            
            
        }
        else
        {
            log(5, "no serial found for address search replay")
        }
        
        
        
    }
    
    
    
    
    
}


struct DataStackRecord
{
    var destinationUserName:String
    var dataCargo:UPacketData
    var status: UDataTransferStatus
    
    var destinationID:UNodeID?
    var destinationAddress:UNodeAddress?
    
    
    
}


enum UDataTransferStatus
{
    case waitingForID, waitingForAddress, readyToTransmit, transmitted, delivered
}