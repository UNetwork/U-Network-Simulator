//
//  NodeRouterStackWindowController.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 5/11/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Foundation
import Cocoa

class NodeRouterStackWindowController:NSWindowController,  NSTableViewDataSource, NSTableViewDelegate

{
    
    @IBOutlet weak var stackTable: NSTableView!
    var routerArrayToDisplay = [(String, String, String, String, String)]()
    var currentNodeId:UNodeID?
    
    func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var aCell:NSTableCellView?
        
        aCell = stackTable.makeViewWithIdentifier(viewForTableColumn!.title, owner: self) as! NSTableCellView
        
        let record = routerArrayToDisplay[row]
        switch viewForTableColumn!.title
        {
        case "from": aCell!.textField!.stringValue = record.0
        case "sent": aCell!.textField!.stringValue = record.1
            
        case "stat": aCell!.textField!.stringValue = record.2
            
        case "wait": aCell!.textField!.stringValue = record.3
            
        case "packet": aCell!.textField!.stringValue = record.4
        default: log(7,text: "FTW ddd300")
            
            
            
            
            
        }
        
        
        
        
        return aCell
        
        
    }
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        
   
            if let aNode = simulator.simulationNodes[currentNodeId!]
            {
                routerArrayToDisplay =  aNode.node.router.status()
                return routerArrayToDisplay.count
            }
            return 0
 
        
    }
    

    
    override func windowDidLoad()
    {
    
    stackTable.setDelegate(self)
        stackTable.setDataSource(self)
    
    
    }
}