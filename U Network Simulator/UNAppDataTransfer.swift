//
//  UNAppDataTransfer.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/12/15.
//

import Foundation

class UNAppDataTransfer:UAppProtocol
{
    let node:UNode
    // var nodeAppsPacketStack = [UInt64:DataStackRecord]()    //
    
    var stack = [String:[UInt64:DataStackRecord]]()
    
    
    
    var appID:UInt64=0x0101010101
    
    var nodeAPI:UNodeAPI?
    

    
  
    func getUNetworkError(error:UNetworkAPIError)
    {
        
    }
    
    func getDataPacket(name:String, envelope:UPacketEnvelope, data:[UInt64])
    {
        
    }
    
    
    
    init(node:UNode)
    {
        self.node=node
    }
    
    func recieveDataPacketFromNetwork(name:String, dataCargo:UPacketData, envelope:UPacketEnvelope)
    {
        if  let app = node.appsAPI.apps[dataCargo.appID]

       {

        app.getDataPacket(name, envelope: envelope, data: dataCargo.load)
        
        }
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
                
                if let stackForName = stack[name]
                {
                    var stackForNameMutable = stackForName
                    stackForNameMutable[packetSerial] = stackRecord
                    stack[name]=stackForNameMutable
                }
                else
                {
                    var emptyStackForName = [UInt64:DataStackRecord]()
                    emptyStackForName[packetSerial] = stackRecord
                    stack[name]=emptyStackForName
                }
                
                
            }
            else
            {
                
                
                
                
                // no address
                
                if let stackForName = stack[name]
                {
                    var stackForNameMutable = stackForName
                    stackForNameMutable[packetSerial] = stackRecord
                    stack[name]=stackForNameMutable
                }
                else
                {
                    var emptyStackForName = [UInt64:DataStackRecord]()
                    emptyStackForName[packetSerial] = stackRecord
                    stack[name]=emptyStackForName
                }

                
                
                
                
                
                node.searchApp.findAddressForId(destinationIDRecord.id, app: self)
                
            }
            
        }
        else
        {
            // no ID
            if let stackForName = stack[name]
            {
                var stackForNameMutable = stackForName
                stackForNameMutable[packetSerial] = stackRecord
                stack[name]=stackForNameMutable
            }
            else
            {
                var emptyStackForName = [UInt64:DataStackRecord]()
                emptyStackForName[packetSerial] = stackRecord
                stack[name]=emptyStackForName
            }

            node.searchApp.findIdForName(name, app: self)
            
        }
        
        
        
    }
    
    func recieveDataTransferConfirmation (cargo:UPacketDataDeliveryConfirmation)
    {
        
        
    }
    
    func getIdSearchResults(name:String, id:UNodeID)
    {
        log(6,text: "searching id")

        if let stackForName = stack[name]
        {
            var stackForNameMuteble = stackForName
            
            for aStackRecord in stackForName
            {
                if aStackRecord.1.status == UDataTransferStatus.waitingForID
                {
                    var changedRecord = aStackRecord
                    
                    changedRecord.1.destinationID = id
                    changedRecord.1.status = UDataTransferStatus.waitingForAddress
                    
                    stackForNameMuteble[aStackRecord.0] = changedRecord.1
                }
            }
            stack[name] = stackForNameMuteble
            
            node.searchApp.findAddressForId(id, app: self)
            
        }
        else
        {
            log(6, text: "No name found for id search replay")
        }
        
        
    }
    
    func getAddressSearchResults(id:UNodeID, address:UNodeAddress)
    {

        
        var name = ""
        
        for record in node.knownIDs
        {
            if record.1.id.isEqual(id)
            {
                name = record.0
                break
            }
        }
        log(6,text: "searching address for name: \(name) \(id.txt)")

        if name != ""
        {
        
        if let stackForName = stack[name]
        {
            var stackForNameMuteble = stackForName
            
            for aStackRecord in stackForName
            {
                if aStackRecord.1.status == UDataTransferStatus.waitingForAddress
                {
                    var changedRecord = aStackRecord
                    
                    changedRecord.1.destinationAddress = address
                    changedRecord.1.status = UDataTransferStatus.readyToTransmit
                    
                    var envelope = UPacketEnvelope(fromId: node.id, fromAddress: node.address, toId: changedRecord.1.destinationID!, toAddress:changedRecord.1.destinationAddress!)
                    
                    log(6,text: "collected data sending packets")
                    node.router.getPacketToRouteFromNode(envelope, cargo: UPacketType.Data(changedRecord.1.dataCargo))
                    
                     changedRecord.1.status = UDataTransferStatus.transmitted


                    
                    stackForNameMuteble[aStackRecord.0] = changedRecord.1
                }
            }
            stack[name] = stackForNameMuteble
            
            
        }
        else
        {
            log(6, text: "No name found for address search replay")
        }

        
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