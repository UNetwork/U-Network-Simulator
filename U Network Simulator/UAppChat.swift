//
//  UAppChat.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/3/15.

//

/*
This is an example of app for U Network
*/

import Foundation
/*
class UAppChat:UAppProtocol {
    
    
    // protocol
    
    let appID:UInt64
    var nodeAPI:UNodeAPI
    
    // app
    
    var chats = [String:[String]]()   // chat history with users
    
    

    
    init(nodeAPI:UNodeAPI)
    {
        
        self.appID = 0xfabaceae
        self.nodeAPI=nodeAPI
    }
    
    // protocol
    
    func getDataPacket(name:String, envelope:UPacketEnvelope, data:[UInt64])
    {
        if var chat = chats[name]
        {
            chat.append(uDataToString(data))
            self.chats[name] = chat

        }
        else
        {
            var stringTable = [String]()
            stringTable.append(uDataToString(data))
            self.chats[name] = stringTable
        }
    }
    
    func getUNetworkError(error:UNetworkAPIError)
    {
        
    }
    
    //user functions
    
    
    func sendMessageTo(name:String, message:String)
    {
        if var chat = self.chats[name]
        {
            chat.append("> " + message)
            self.chats[name] = chat
        }
        else
        {
            var stringTable = [String]()
            stringTable.append("> " + message)
            self.chats[name] = stringTable
            
        }
        
        let convertedData = stringToUData(message)
        
        self.nodeAPI.sendDataToUser(name, data: convertedData, app: self)
        
        
        
    }
    
    func showChatHistoryWithUser(name:String)
    {
        if let chat = self.chats[name]
        {
            for line in chat
            {
                println(line)
            }
        }
        else
        {
            println("No chat chistory for user \(name)")
        }
        
        
        
    }
    
    
    
}
*/