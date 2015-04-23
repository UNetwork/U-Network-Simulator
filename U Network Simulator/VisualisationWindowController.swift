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
        var layerWasHit=false
        
        if let sublayers = self.window!.contentView.layer!!.sublayers
        {
            for aLayer in sublayers
            {
                if aLayer is NodeLayer{
                    if let hitlayer = (aLayer as! NodeLayer).hitTest(CGPoint(x: theEvent.locationInWindow.x, y: theEvent.locationInWindow.y))
                    {
                        (hitlayer as! NodeLayer).getClick()
                        layerWasHit = true
                        break
                    }
                }
            }
        }
        if !layerWasHit
        {
            
            let simLatDelta = Float64 (simulator.maxLat - simulator.minLat)
            let simLongDelta = Float64(simulator.maxLong - simulator.minLong)
            
            log(7, "maxLat: \(simulator.maxLat) minLat:\(simulator.minLat) maxLong: \(simulator.maxLong) minLong: \(simulator.minLong)")
 
            
            let newLat = Float64(simulator.minLat) + simLatDelta * Float64((theEvent.locationInWindow.x / theEvent.window!.frame.width))
            let newLong = Float64(simulator.minLong) + simLongDelta * Float64((theEvent.locationInWindow.y / theEvent.window!.frame.height))

            
            
            
            
 
            let newAlt = simulator.maxAlt
            
            simulator.addWirelessNode(USimulationRealLocation(inputLatitude: UInt64(newLat), inputLongitude: UInt64(newLong), inputAltitude: UInt64(newAlt)))


            
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
            fadeAnimation.toValue = NSNumber(float: 0.1)
            fadeAnimation.duration = 3.0
            let connectionViewHash = fromId.hashForView(toId)
            
            if let aConnectionView = connectionViews[connectionViewHash]
            {
                aConnectionView.color = packetColor
                aConnectionView.opacity = 0.1
                aConnectionView.strokeColor = packetColors[packetColor]
                aConnectionView.addAnimation(fadeAnimation, forKey: "")
            }
            else
            {
                var newConnectionView = createConnectionLayer(nodes: fromId, toId, packet)
                connectionViews[connectionViewHash] = newConnectionView
                newConnectionView.opacity = 0.1
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


