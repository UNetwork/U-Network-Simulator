//
//  NodeInfoWindow.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/4/15.
//

import Foundation
import Cocoa


class NodeWindowController:NSWindowController, NSTabViewDelegate, NSTableViewDataSource, NSTableViewDelegate, UAppProtocol
    
{
    
    var currentNodeId=UNodeID()
    
    
    
    
    
    @IBOutlet weak var theTabView: NSTabView!
    
    @IBOutlet weak var infoText: NSTextField!
    
    @IBAction func resetNode(sender: AnyObject)
    {
        if let aNode =  simulator.simulationNodes[currentNodeId]
        {
            aNode.node.resetInternalData()
        }

    }
    
    
    @IBAction func refreshNodesPeers(sender: AnyObject)
    {
        if let aNode =  simulator.simulationNodes[currentNodeId]
        {
            aNode.node.refreshPeers()
        }
    }
    
    
    
    
    //Ping
    @IBOutlet weak var pingIdField: NSTextField!
    @IBOutlet weak var pingAddressField: NSTextField!
    @IBAction func doPing(sender: AnyObject)
    {
        
    }
    
    @IBAction func pingAllSelectedNodes(sender: AnyObject)
    {
        var pingToData = [UNodeID, UNodeAddress]()
        let appdel = NSApplication.sharedApplication().delegate as! AppDelegate
        
        if let visWin = appdel.visualisationWindow
        {
            
            for aView in visWin.window!.contentView.layer!!.sublayers
            {
                if aView is NodeLayer
                {
                    if ((aView as! NodeLayer).clicked == true) && (!(aView as! NodeLayer).forNode.isEqual(currentNodeId))
                    {
                        if let toNode = simulator.simulationNodes[(aView as! NodeLayer).forNode]
                        {
                            let toID=toNode.node.id
                            let toNodeAddress=toNode.node.address
                            pingToData.append(toID, toNodeAddress)
                        }
                    }
                }
            }
            
            for (_, (id, address)) in enumerate(pingToData)
            {
                if let nodeToPing = simulator.simulationNodes[currentNodeId]
                {
                    nodeToPing.node.pingApp.sendPing(id, address: address)
                }
                
            }
        }
        
    }
    
    
    //Search
    @IBOutlet weak var searchWithNameField: NSTextField!
    @IBOutlet weak var searchWithIdField: NSTextField!
    
    @IBOutlet weak var searchResultsField: NSTextField!
    var appID:UInt64 = 0x0000000000000001
    
    var nodeAPI:UNodeAPI?
    
    
    func getIdSearchResults(name:String, id:UNodeID)
    {
       searchResultsField.stringValue += "Id search result: \(name) -> \(id.txt) \n"
        
        searchWithIdField.stringValue = ""
        for aInt in id.data
        {
            searchWithIdField.stringValue += "\(aInt) "
        }
        
     
    }
    
    func getAddressSearchResults(id:UNodeID, address:UNodeAddress)
    {
        searchResultsField.stringValue += "Address search result: \(id.txt) -> \(address.txt) \n"

    }
    

    
    
    
    @IBAction func searchAddress(sender: AnyObject)
    {
    
    let idInString = searchWithIdField.stringValue
        let stringsInArray = idInString.componentsSeparatedByString(" ")
        
        var idData = [UInt64]()
        
        for aString in stringsInArray
        {
            if aString != ""
            {
            let aInt = strToUInt64(aString)
            idData.append(aInt)
            }
        }
    
        var id = UNodeID(lenght: idData.count)
        
        id.data = idData
        
        nodeAPI?.searchForAddress(id, app: self)
    
    
    }
    
    
    
    
    
    @IBAction func search(sender: AnyObject)
    {
        searchResultsField.stringValue = ""
        nodeAPI?.searchForID(searchWithNameField.stringValue, app: self)
    }
    
    
    
    
    
    
    @IBAction func broadcastAddress(sender: AnyObject)
    {
        if let simNode = simulator.simulationNodes[currentNodeId]
        {
            simNode.node.searchApp.storeAddress()
        }
    }
    
    @IBAction func broadcastName(sender: AnyObject) {
        if let simNode = simulator.simulationNodes[currentNodeId]
        {
            simNode.node.searchApp.storeName()
        }

        
    }
    // chat app
    
    @IBOutlet weak var chatText: NSTextField!
    
    @IBOutlet weak var namesTable: NSTableView!
    
    @IBOutlet weak var message: NSTextField!
   
    @IBAction func sendMessage(sender: AnyObject)
    {
        
        
    }
    //Memory
    
    @IBOutlet weak var nameIdTable: NSTableView!
    var dataForNameIdTable = [UNodeID:NameIdTableRecord]()
    var memoryArrayToDisplay = [String, String, String]()
    
    
    struct NameIdTableRecord
    {
        var name:String=""
        var address = UNodeAddress()
    }
    
    //Router
    @IBOutlet weak var routerTable: NSTableView!
    var routerArrayToDisplay = [(String, String, String, String, String)]()
    
    
    //Stats
    
    @IBOutlet weak var nodeStatsTextField: NSTextField!

    @IBAction func resetNodeStats(sender: AnyObject)
    {
    }
    
    
    
    
    
    
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        theTabView.delegate = self
        nameIdTable.setDataSource(self)
        nameIdTable.setDelegate(self)
        routerTable.setDelegate(self)
        routerTable.setDataSource(self)
        
    }
    
    func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?)
    {
        
        let nameOfTab = tabViewItem!.label
        
        switch nameOfTab
        {
        case "Ping" : refreshNodePingView()
        case "Search": refreshNodeSearchView()
        case "Chat" : refreshNodeChatView()
        case "Memory" : refreshNodeMemoryView()
        case "Router" : refreshNodeRouterView()
        case "Stats" : refreshNodeStatsView()
        case "Interfaces" : refreshNodeInterfacesView()
            
        default : log(7,"Nope")
        }
        
        
        
    }
    
   
    
  
    
    func refreshNodePingView()
    {
        
    }
    
    func refreshNodeSearchView()
    {
        
    }
    
    func refreshNodeChatView()
    {
        
    }
    
    func refreshNodeMemoryView()
    {
    nameIdTable.reloadData()
    }
    
    func refreshNodeRouterView()
    {
        
     routerTable.reloadData()
        
        
        
        
    }
    
    func refreshNodeStatsView()
    {
        log(7,"refreshing node stats view")
        
        var result = ""
        
        if let aNode = simulator.simulationNodes[currentNodeId]
        {
            for index in  0..<StatsEvents.allValues.count
            {
                result+="\(StatsEvents.allValues[index]) : \(aNode.node.nodeStats.nodeStats[index]) \n"     // what a crappy naming
                result += (index == 1 || index == 7 || index == 13 ? "\n":"")
            }
            
            self.nodeStatsTextField.stringValue = result
        }
    }
    
    func refreshNodeInterfacesView()
    {
        
    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        
        if tableView.identifier == "Memory"
        {
            
            if let simNode = simulator.simulationNodes[currentNodeId]
            {
                dataForNameIdTable = [UNodeID:NameIdTableRecord]()
                unifyNodeMemoryForTable()
                return memoryArrayToDisplay.count
            }
            return 0
        }
        else if tableView.identifier == "Router"
        {
            if let aNode = simulator.simulationNodes[currentNodeId]
            {
                routerArrayToDisplay =  aNode.node.router.status()
                return routerArrayToDisplay.count
            }
            return 0
            
        }
        return 0

    }
    
    
    func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var aCell:NSTableCellView?
        if tableView.identifier == "Memory"
        {
            
            aCell = nameIdTable.makeViewWithIdentifier(viewForTableColumn!.title, owner: self) as! NSTableCellView
            
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
        else if tableView.identifier == "Router"
        {
            aCell = routerTable.makeViewWithIdentifier(viewForTableColumn!.title, owner: self) as! NSTableCellView

            let record = routerArrayToDisplay[row]
            switch viewForTableColumn!.title
            {
                case "from": aCell!.textField!.stringValue = record.0
            case "sent": aCell!.textField!.stringValue = record.1

            case "stat": aCell!.textField!.stringValue = record.2

            case "wait": aCell!.textField!.stringValue = record.3

            case "packet": aCell!.textField!.stringValue = record.4
            default: log(7,"FTW ddd300")


            }
            
            
        }
        
        
        
        
        return aCell
        
        
    }
    
    
    func unifyNodeMemoryForTable()
    {
        if let simNode = simulator.simulationNodes[currentNodeId]
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

    
    
    func refreshCurrentViewTab()
    {
        let nameOfTab = theTabView.selectedTabViewItem!.label
        
        switch nameOfTab
        {
        case "Ping" : refreshNodePingView()
        case "Search": refreshNodeSearchView()
        case "Chat" : refreshNodeChatView()
        case "Memory" : refreshNodeMemoryView()
        case "Router" : refreshNodeRouterView()
        case "Stats" : refreshNodeStatsView()
        case "Interfaces" : refreshNodeInterfacesView()
            
        default : log(7,"Nope")
        }

    }
    
    func showNode(nodeId:UNodeID)
    {
        if let simNode = simulator.simulationNodes[nodeId]
        {
            currentNodeId=nodeId
            nodeAPI=simNode.node.appsAPI
            
            
            
            var info = "Name: "
            info += simNode.node.userName
            info += "\n"
            info += "Lat: \(simNode.node.address.latitude)\n"
            info += "Long: \(simNode.node.address.longitude)\n"
            info += "Alt: \(simNode.node.address.altitude)\n"
            info += "Id: \(simNode.node.id.txt)\n"
            info += "Peers: \(simNode.node.peers.count)\n"
            
            
            infoText.stringValue = info

            refreshCurrentViewTab()
            
            
        }
    }
    
    
}