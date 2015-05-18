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
    var memoryWindow:NodeMemoryWindowController?
    var stackWindow:NodeRouterStackWindowController?
    var chatWindow:ChatWindowController?

    
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
    @IBOutlet weak var addressField: NSTextField!
    
    @IBOutlet weak var searchResultsField: NSTextField!
    var appID:UInt64 = 0x0000000000000001
    
    var nodeAPI:UNodeAPI?
    
    func getUNetworkError(error:UNetworkAPIError)
    {
        
    }
    
    func getDataPacket(name:String, envelope:UPacketEnvelope, data:[UInt64])
    {
        
    }
    

    
    
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
        
        addressField.stringValue = "\(address.latitude) \(address.longitude) \(address.altitude)"

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
    
    
    @IBAction func ping(sender: AnyObject)
    {
        let idInString = searchWithIdField.stringValue
        let idStringsInArray = idInString.componentsSeparatedByString(" ")
        let addressInSTring = addressField.stringValue
        let addressStringsInArray = addressInSTring.componentsSeparatedByString(" ")
        
        
        var idData = [UInt64]()
        
        for aString in idStringsInArray
        {
            if aString != ""
            {
                let aInt = strToUInt64(aString)
                idData.append(aInt)
            }
        }
        
        var id = UNodeID(lenght: idData.count)
        
        id.data = idData
        
        
        let address = UNodeAddress(inputLatitude: strToUInt64(addressStringsInArray[0]), inputLongitude: strToUInt64(addressStringsInArray[1]), inputAltitude: strToUInt64(addressStringsInArray[2]))
        
        nodeAPI?.node.pingApp.sendPing(id, address: address)
        
    }
    
    @IBAction func showMemoryWindow(sender: AnyObject)
    {
    
    memoryWindow = NodeMemoryWindowController(windowNibName: "NodeMemoryWindow")
        memoryWindow?.currentNodeId=currentNodeId
        memoryWindow!.window?.makeKeyWindow()
        
    
    
    }
    
    
    @IBAction func showRouterStack(sender: AnyObject)
    {
        stackWindow = NodeRouterStackWindowController(windowNibName: "NodeRouterStackWindow")
        stackWindow?.currentNodeId=currentNodeId
        stackWindow!.window?.makeKeyWindow()

    }
    
    
    @IBAction func showChatApp(sender: AnyObject)
    {
        chatWindow = ChatWindowController(windowNibName: "ChatWindow")
        chatWindow?.nodeAPI=simulator.simulationNodes[currentNodeId]?.node.appsAPI
        chatWindow!.window?.makeKeyWindow()

        
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
    
    //Stats
    
    @IBOutlet weak var nodeStatsTextField: NSTextField!

    @IBAction func resetNodeStats(sender: AnyObject)
    {
    }
    
    
    
    
    
    
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        theTabView.delegate = self

 
        
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

    }
    
    func refreshNodeRouterView()
    {
        
        
        
        
        
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
            info += simNode.node.ownerName
            info += ", "
            info += "\(simNode.node.id.txt) "
            info += "Lat: \(simNode.node.address.latitude), "
            info += "Long: \(simNode.node.address.longitude), "
            info += "Alt: \(simNode.node.address.altitude), "
            info += "Peers: \(simNode.node.peers.count)"
            
            
            infoText.stringValue = info

            refreshCurrentViewTab()
            
            
        }
    }
    
    
}