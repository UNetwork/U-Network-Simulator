//
//  VizualisationWindow.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/9/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Foundation
import Cocoa
import QuartzCore

class VisualisationWindowController:NSWindowController, NSWindowDelegate
{
    var nodeViews = [UNodeID:NodeLayer]()
    var connectionViews = [UInt64:ConnectionLayer]()
    
    func windowDidResize(notification: NSNotification) {
        refreshEverything()
    }
    
    func addNodeLayer(aNodeLayer:NodeLayer)
    {
        self.nodeViews[aNodeLayer.forNode] = aNodeLayer
        self.window?.contentView.layer!!.addSublayer(aNodeLayer)
        
    }
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.delegate = self
        var cv = self.window!.contentView as! NSView
        cv.wantsLayer = true
        refreshEverything()
    }
    
    

    
    override func  mouseDown(theEvent: NSEvent) {
        log(7,"window cklicke")
        
        for aLayer in self.window!.contentView.layer!!.sublayers
        {
            if aLayer is NodeLayer{
                if let hitlayer = (aLayer as! NodeLayer).hitTest(CGPoint(x: theEvent.locationInWindow.x, y: theEvent.locationInWindow.y))
                {
                    log(7,"layer clicked")
                    (hitlayer as! NodeLayer).getClick()
                    
                }
            }
        }
    }
    
    
    
    func showConnection(fromId:UNodeID, toId:UNodeID, forWindow:NSWindow, packet:UPacket)
    {
        let packetColor = packetTypeInInt(packet)
        
        let rootLayer = self.window?.contentView.layer!!
        
        if visiblePackets[packetColor]
        {
            
            
            let connectionViewHash = fromId.hashForView(toId)
            
            if let aConnectionView = connectionViews[connectionViewHash]
            {
                aConnectionView.color = packetColor
                aConnectionView.opacity = 0.1
               //  aConnectionView.setNeedsDisplayInRect(aConnectionView.bounds)
                aConnectionView.strokeColor = packetColors[packetColor]
                let fadeAnimation = CABasicAnimation(keyPath: "opacity")
                
                fadeAnimation.fromValue = NSNumber(float: 1.0)
                fadeAnimation.toValue = NSNumber(float: 0.1)
                fadeAnimation.duration = 3.0
                
                aConnectionView.addAnimation(fadeAnimation, forKey: "")
            }
            else
                
            {
                var newConnectionView = createConnectionLayer(nodes: fromId, toId, rootLayer!, packet)
                
                
                
                connectionViews[connectionViewHash] = newConnectionView
                newConnectionView.opacity = 0.1
                let fadeAnimation = CABasicAnimation(keyPath: "opacity")
                
                fadeAnimation.fromValue = NSNumber(float: 1.0)
                fadeAnimation.toValue = NSNumber(float: 0.1)
                fadeAnimation.duration = 3.0
                
                newConnectionView.addAnimation(fadeAnimation, forKey: "")
                
                rootLayer!.addSublayer(newConnectionView)
                
            }
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    func refreshEverything()
    {
        
        
        if let visWinContentLayer = self.window?.contentView.layer
        {
            visWinContentLayer?.sublayers = nil
            self.connectionViews = [UInt64:ConnectionLayer]()
            self.nodeViews = [UNodeID:NodeLayer]()
            
            
            for aSimulationNode in simulator.simulationNodes.values
            {
                self.addNodeLayer(aSimulationNode.node.visualistaionLayer(visWinContentLayer!))
            }
            
            
            
            
            
            
        }
    }
    
}


extension UNodeID
{
    func hashForView(withId:UNodeID) -> UInt64
    {
        return self.data[0] ^ withId.data[0]
    }
    var txt:String
        {
            return "id: \(self.data[0]%1000000)"
    }
}


