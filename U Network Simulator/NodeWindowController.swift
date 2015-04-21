//
//  NodeInfoWindow.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/4/15.
//

import Foundation
import Cocoa


class NodeWindowController:NSWindowController
    
{
    
    var currentNodeId=UNodeID()
    
    @IBOutlet weak var infoText: NSTextField!
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
    @IBAction func search(sender: AnyObject)
    {
        
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
    
    //Router
    
    //Stats
    
    @IBOutlet weak var nodeStatsTextField: NSTextField!

    @IBAction func resetNodeStats(sender: AnyObject) {
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        

        
    }
    
    
    func showNode(nodeId:UNodeID)
    {
        if let simNode = simulator.simulationNodes[nodeId]
        {
            currentNodeId=nodeId
            var info = "Name: "
            info += simNode.node.userName
            info += "\n"
            info += "Lat: \(simNode.node.address.latitude)\n"
            info += "Long: \(simNode.node.address.longitude)\n"
            info += "Alt: \(simNode.node.address.altitude)\n"
            info += "\n"
            info += "Peers: \(simNode.node.peers.count)\n"
            
            infoText.stringValue = info

            
            
        }
    }
    
    
}