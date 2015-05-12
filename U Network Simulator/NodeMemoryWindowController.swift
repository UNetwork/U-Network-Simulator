//
//  NodeMemoryWindowController.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 5/11/15.
//

import Foundation
import Cocoa

class NodeMemoryWindowController:NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
    
    
    @IBOutlet weak var memoryTable: NSTableView!
    var currentNodeId:UNodeID?
    
    
    var dataForNameIdTable = [UNodeID:NameIdTableRecord]()
    var memoryArrayToDisplay = [String, String, String]()
    
    
    struct NameIdTableRecord
    {
        var name:String=""
        var address = UNodeAddress()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
    if let simNode = simulator.simulationNodes[currentNodeId!]
        {
            dataForNameIdTable = [UNodeID:NameIdTableRecord]()
            unifyNodeMemoryForTable()
            return memoryArrayToDisplay.count
        }
        return (0)
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var aCell:NSTableCellView?
        aCell = memoryTable.makeViewWithIdentifier(viewForTableColumn!.title, owner: self) as! NSTableCellView
        
        let record=memoryArrayToDisplay[row]
        switch viewForTableColumn!.title
        {
        case "Name": aCell!.textField!.stringValue = record.0
        case "Id" :aCell!.textField!.stringValue = record.1
        case "Address": aCell!.textField!.stringValue = record.2
        default: log(7,"FTW 55")
        }
        return aCell

        
        
    }


    
    override func windowDidLoad() {
    
        memoryTable.setDataSource(self)
        memoryTable.setDelegate(self)
        memoryTable.reloadData()
    
    }
    
    func unifyNodeMemoryForTable()
    {
        if let simNode = simulator.simulationNodes[currentNodeId!]
        {
            for nameIdRecord in simNode.node.knownIDs
            {
                let newTableRecord = NameIdTableRecord(name: nameIdRecord.0, address: UNodeAddress())
                dataForNameIdTable[nameIdRecord.1.id] = newTableRecord
            }
            
            for idAddressRecord in simNode.node.knownAddresses
            {
                if var existingRecord = dataForNameIdTable[idAddressRecord.0]
                {
                    existingRecord.address = idAddressRecord.1.address
                    dataForNameIdTable[idAddressRecord.0] = existingRecord
                }
                else
                {
                    let newTableRecord=NameIdTableRecord(name: "", address: idAddressRecord.1.address)
                    dataForNameIdTable[idAddressRecord.0] = newTableRecord
                }
                
            }
            
            memoryArrayToDisplay = [String, String, String]()
            
            for data in dataForNameIdTable
            {
                let name = data.1.name
                let id = data.0.txt
                let address = data.1.address.txt
                
                memoryArrayToDisplay.append(name, id, address)
            }
            
            
            
        }
        
    }

    
}