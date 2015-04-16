//
//  VizualisationWindow.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/9/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Foundation
import Cocoa

class VisualisationWindowController:NSWindowController, NSWindowDelegate
{
    
    let maxConnection = 5000
    var viewLimitExceeded = false
    
    var nodeViews = [UNodeID:NodeView]()
    var connectionViews = [ConnectionView]()
    
    var currentSlot = 0
    
    
    
    
    
    
    func windowDidResize(notification: NSNotification) {
        refreshEverything() 
    }
    
    func addNodeView(aNodeView:NodeView)
    {
        self.nodeViews[aNodeView.forNode] = aNodeView
        self.window?.contentView.addSubview(aNodeView)
        
    }
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.delegate = self
        
        refreshEverything()
    }
    
    
    @IBAction func showNode(sender: AnyObject) {
        
        refreshEverything()
        
    }
    
    override func  mouseDown(theEvent: NSEvent) {
    log(7,"window cklicke")
    }
    
    
    
    func showConnection(fromId:UNodeID, toId:UNodeID, forWindow:NSWindow, packet:UPacket)
    {
    
        let connectionType=packetTypeInInt(packet)
        
        if(visiblePackets[connectionType]){
        
        
        if let visWin = self.window
        {
            let conView = ConnectionView(nodes: fromId, toId: toId, forWindow: forWindow, packet: packet)
            
            if viewLimitExceeded
            {
                connectionViews[currentSlot].removeFromSuperview()
                connectionViews[currentSlot] = conView
                visWin.contentView.addSubview(conView)
                currentSlot++
                if currentSlot > maxConnection - 1 {currentSlot = 0}
            }
            else
            {
                connectionViews.append(conView)
                visWin.contentView.addSubview(conView)
                
                currentSlot++
                if currentSlot > maxConnection - 1 {currentSlot = 0; viewLimitExceeded = true}

                
            }
            
            
            

        }
        
        }
        
        
        
    }
    

    
    
    func refreshEverything()
    {
        
        
        if let visWin = self.window
        {
            for aView in visWin.contentView.subviews
            {
                aView.removeFromSuperview()
                nodeViews = [UNodeID:NodeView]()
            }
            
            for aSimulationNode in simulator.simulationNodes.values
            {
                self.addNodeView(aSimulationNode.node.view(visWin))
            }
            
       
            
            
            
            
        }
    }
    
}


