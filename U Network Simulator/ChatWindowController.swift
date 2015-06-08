//
//  ChatWindowController.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 5/11/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Foundation
import Cocoa

class ChatWindowController:NSWindowController, NSTableViewDataSource, NSTableViewDelegate, UAppProtocol {
    
    
    @IBOutlet weak var chatTextField: NSTextField!
    
    @IBOutlet weak var avaliableNamesTable: NSTableView!
    
    @IBOutlet weak var nameField: NSTextField!
    
    @IBOutlet weak var messageField: NSTextField!
    
    var chats = [String:[String]]()   // chat history with users

    
    @IBAction func sendChatLine(sender: AnyObject)
    {
        sendMessageTo(nameField.stringValue, message: messageField.stringValue)
    }
    
    var appID:UInt64 = 0x0011223344556677
    
    var nodeAPI:UNodeAPI?
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        avaliableNamesTable.setDataSource(self)
        avaliableNamesTable.setDelegate(self)
        nodeAPI!.launchApp(self)
        self.window?.title = "Chat: " + nodeAPI!.node.ownerName
    }

    
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
        
        chatTextField.stringValue += "\(name): \(uDataToString(data)) \n"
        avaliableNamesTable.reloadData()

    }
    
    func getIdSearchResults(name:String, id:UNodeID)
    {
        
    }
    
    func getAddressSearchResults(id:UNodeID, address:UNodeAddress)
    {
        
    }
    
    func getUNetworkError(error:UNetworkAPIError)
    {
        
    }
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        return chats.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let chatNames = chats.keys.array
        var aCell:NSTableCellView?
        aCell = avaliableNamesTable.makeViewWithIdentifier(viewForTableColumn!.title, owner: self) as! NSTableCellView
        
        aCell!.textField!.stringValue = chatNames[row]
        
        return aCell
        
    }
    
    func sendMessageTo(name:String, message:String)
    {
        let newText = "> " + message + "\n"

        if var chat = self.chats[name]
        {
            chat.append(newText)
            self.chats[name] = chat
        }
        else
        {
            var stringTable = [String]()
            stringTable.append(newText)
            self.chats[name] = stringTable
            
        }
        
        chatTextField.stringValue += newText
        let convertedData = stringToUData(message)
        
        self.nodeAPI!.sendDataToUser(name, data: convertedData, app: self)
        
        
        
    }

    
}