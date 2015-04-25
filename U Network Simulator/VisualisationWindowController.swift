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

var scaleLat = Float64 (0.000047894736842105261)
var scaleLong = Float64 (0.000047894736842105261)
var scaleAlt = Float64 (0.00001)


class VisualisationWindowController:NSWindowController, NSWindowDelegate
{
    var nodeViews = [UNodeID:NodeLayer]()
    var connectionViews = [UInt64:ConnectionLayer]()
    
    
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        self.window?.delegate = self
        var cv = self.window!.contentView as! NSView
        cv.wantsLayer = true
        refreshEverything()
    }
    
    
    override func  mouseDown(theEvent: NSEvent)
    {
        
        
        switch currentModeOfOperationForVisualisationVindow
        {
        case 0: processAddNode(theEvent)
        case 1: processDeleteNodeclick(theEvent)
        case 2: processSelectMove(theEvent)
        default: log(7,"Please NO")
        }
        
        
        
    }
    
    
    func processDeleteNodeclick(theEvent:NSEvent)
    {
        if let sublayers = self.window!.contentView.layer!!.sublayers
        {
            for aLayer in sublayers
            {
                if aLayer is NodeLayer{
                    if let hitlayer = (aLayer as! NodeLayer).hitTest(CGPoint(x: theEvent.locationInWindow.x, y: theEvent.locationInWindow.y))
                    {
                        let nodeToDeleteId = (hitlayer as! NodeLayer).forNode
                        simulator.simulationNodes[nodeToDeleteId] = nil
                        refreshEverything()
                        break
                    }
                }
            }
        }
        
    }
    
    func processAddNode(theEvent:NSEvent)
    {
        let simLatDelta = Float64 (simulator.maxLat - simulator.minLat)
        let simLongDelta = Float64(simulator.maxLong - simulator.minLong)
        
        let newLat = Float64(simulator.minLat) + simLatDelta * Float64(((theEvent.locationInWindow.x - nodeLayerSize/2) / (theEvent.window!.contentView.frame.width - nodeLayerSize)))
        let newLong = Float64(simulator.minLong) + simLongDelta * Float64(((theEvent.locationInWindow.y - nodeLayerSize/2) / (theEvent.window!.contentView.frame.height - nodeLayerSize)))
        
        let newAlt = simulator.maxAlt
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: UInt64(newLat), inputLongitude: UInt64(newLong), inputAltitude: UInt64(newAlt)))
        
    }
    
    func processSelectMove(theEvent:NSEvent)
    {
        if let sublayers = self.window!.contentView.layer!!.sublayers
        {
            for aLayer in sublayers
            {
                if aLayer is NodeLayer{
                    if let hitlayer = (aLayer as! NodeLayer).hitTest(CGPoint(x: theEvent.locationInWindow.x, y: theEvent.locationInWindow.y))
                    {
                        (hitlayer as! NodeLayer).getClick()
                        
                        break
                    }
                }
            }
        }
        
        
        
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        
        var selectedNodes = Set<NodeLayer>()
        
        if let sublayers = self.window!.contentView.layer!!.sublayers
        {
            for aLayer in sublayers
            {
                if aLayer is NodeLayer{
                    if ((aLayer as! NodeLayer).clicked)
                    {
                        
                        selectedNodes.insert(aLayer as! NodeLayer)
                        
                        
                    }
                }
            }
        }
        
        
        let mask:Int = Int( NSEventMask.LeftMouseDraggedMask.rawValue | NSEventMask.LeftMouseUpMask.rawValue | NSEventMask.LeftMouseDownMask.rawValue)
        var done = false
        var previous:NSPoint
        var local:NSPoint
        
        previous = theEvent.locationInWindow
        
        while(!done)
        {
            var event = self.window!.nextEventMatchingMask(mask, untilDate: NSDate.distantFuture() as? NSDate, inMode: "NSEventTrackingRunLoopMode", dequeue: true)
            self.window!.discardEventsMatchingMask(mask, beforeEvent: event)
            
            local = event!.locationInWindow
            
            let delta = NSMakePoint(local.x - previous.x, local.y - previous.y)
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            for layerToMove in selectedNodes
            {
                var pos = layerToMove.position
                pos.x += delta.x
                pos.y += delta.y
                
                layerToMove.position = pos
                
            }
            
            previous.x += delta.x
            previous.y += delta.y
            
            CATransaction.commit()
            
            if (event!.type == NSEventType.LeftMouseUp)
            {
                done = true
                let simLatDelta = Float64 (simulator.maxLat - simulator.minLat)
                let simLongDelta = Float64(simulator.maxLong - simulator.minLong)
                
                for layerToMove in selectedNodes
                {
                    
                    
                    let newLat = Float64(simulator.minLat) + simLatDelta * Float64(((layerToMove.position.x - nodeLayerSize/2) / (theEvent.window!.contentView.frame.width - nodeLayerSize)))
                    let newLong = Float64(simulator.minLong) + simLongDelta * Float64(((layerToMove.position.y - nodeLayerSize/2) / (theEvent.window!.contentView.frame.height - nodeLayerSize)))
                    
                    let newAlt = simulator.maxAlt   // take previous value
                    
                    
                    let newRealLocation = USimulationRealLocation(inputLatitude: UInt64(newLat), inputLongitude: UInt64(newLong), inputAltitude: UInt64(newAlt))
                    
                    let newAddress = UNodeAddress(inputLatitude: UInt64(newLat), inputLongitude: UInt64(newLong), inputAltitude: UInt64(newAlt))  // this should be updated by node itself from interfaces or peers
                    
                    
                    if var simulationNodeToUpdate = simulator.simulationNodes[layerToMove.forNode]
                    {
                        
                        if simulationNodeToUpdate.nodeConfiguration.simulationWirelessInterfeces.count > 0
                        {
                            
                            simulationNodeToUpdate.nodeConfiguration.simulationWirelessInterfeces[0].location = newRealLocation
                        }
                        simulationNodeToUpdate.node.address = newAddress
                        
                        if var nodeWirelessInterface = simulator.simulationNodes[layerToMove.forNode]!.node.interfaces[0] as? UNetworkInterfaceSimulationWireless
                        {
                            
                            nodeWirelessInterface.realLocation = newRealLocation  
                        }
                    }
                    
                }
                
                
                
                
                
                
                // calculate new addresses for dragged nodes and update them in simulationNodes dictionery
                
            }
            
            
        }
        
        
    }
    
    
    func windowDidResize(notification: NSNotification) {
        refreshEverything()
    }
    
    func addNodeLayer(aNodeLayer:NodeLayer)
    {
        self.nodeViews[aNodeLayer.forNode] = aNodeLayer
        self.window?.contentView.layer!!.addSublayer(aNodeLayer)
    }
    
    
    func showConnection(fromId:UNodeID, toId:UNodeID, forWindow:NSWindow, packet:UPacket)
    {
        let packetColor = packetTypeInInt(packet)
        if visiblePackets[packetColor]
        {
            let rootLayer = self.window?.contentView.layer!!
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            
            fadeAnimation.fromValue = NSNumber(float: 1.0)
            fadeAnimation.toValue = NSNumber(float: 0.25)
            fadeAnimation.duration = 3.0
            let connectionViewHash = fromId.hashForView(toId)
            
            if let aConnectionView = connectionViews[connectionViewHash]
            {
                aConnectionView.color = packetColor
                aConnectionView.opacity = 0.25
                aConnectionView.strokeColor = packetColors[packetColor]
                aConnectionView.addAnimation(fadeAnimation, forKey: "")
            }
            else
            {
                var newConnectionView = createConnectionLayer(nodes: fromId, toId, packet)
                connectionViews[connectionViewHash] = newConnectionView
                newConnectionView.opacity = 0.25
                newConnectionView.addAnimation(fadeAnimation, forKey: "")
                rootLayer!.addSublayer(newConnectionView)
            }
        }
    }
    
    
    func refreshEverything()
    {
        if let visWinContentLayer = self.window?.contentView.layer
            
        {
            if simulator.simulationNodes.count > 1
            {
                updateScaleForLayer(visWinContentLayer!)
            }
            
            visWinContentLayer?.sublayers = nil
            self.connectionViews = [UInt64:ConnectionLayer]()
            self.nodeViews = [UNodeID:NodeLayer]()
            
            for aSimulationNode in simulator.simulationNodes.values
            {
                self.addNodeLayer(aSimulationNode.node.visualistaionLayer(visWinContentLayer!))
            }
            
        }
    }
    
    func updateScaleForLayer (theLayer:CALayer)
    {
        let windowWidth = Float64(theLayer.bounds.width - nodeLayerSize)
        let windowHeight = Float64(theLayer.bounds.height  - nodeLayerSize)
        
        var deltaLat = Float64(simulator.maxLat - simulator.minLat)
        var deltaLong = Float64(simulator.maxLong - simulator.minLong)
        var deltaAlt = Float64(simulator.maxAlt - simulator.minAlt)
        
        if (deltaLat < 1) {deltaLat = 1}
        if (deltaLong < 1) {deltaLong = 1}
        if (deltaAlt < 1) {deltaAlt = 1}
        
        scaleLat = windowWidth / deltaLat
        scaleLong =  windowHeight / deltaLong
        scaleAlt = Float64(nodeLayerSize - minNodeLayerSize) / deltaAlt
        
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


