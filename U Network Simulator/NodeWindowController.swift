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
    
    
    
    @IBOutlet weak var chatText: NSTextField!
    
    @IBOutlet weak var namesTable: NSTableView!
    
    @IBOutlet weak var message: NSTextField!
   
    @IBAction func sendMessage(sender: AnyObject)
    {
        
        
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