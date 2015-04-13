//
//  NodeView.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/9/15.
//

import Foundation
import Cocoa

extension UNode {
    func view (forWindow:NSWindow) -> NodeView
    {
        
        let windowWidth = Float64(forWindow.contentView.bounds!.width)
        let windowHeight = Float64(forWindow.contentView.bounds!.height)
        
        let deltaLat = Float64(simulator.maxLat - simulator.minLat)
        let deltaLong = Float64(simulator.maxLong - simulator.minLong)
        let deltaAlt = Float64(simulator.maxAlt - simulator.minAlt)
        
        let scaleLat = windowWidth / deltaLat
        let scaleLong =  windowHeight / deltaLong
        let scaleAlt = 25.0 / deltaAlt
        
        
        let viewX = Float64(self.address.latitude - simulator.minLat) * scaleLat
        let viewY = Float64(self.address.longitude - simulator.minLong) * scaleLong
        let viewA = Float64(self.address.altitude - simulator.minAlt) * scaleAlt
        
        let result = NodeView(frameAndPosition: NSRect(x: viewX, y: viewY, width: viewA, height: viewA), id: self.id)

        
        return result
        
        
    }
}




class NodeView:NSView {
    
    var forNode:UNodeID!

    
    convenience init (frameAndPosition frameRect: NSRect, id:UNodeID)
    {
        
        
        
        
        
        self.init(frame: frameRect)
        
        forNode = id

        
    }
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func mouseDown(theEvent: NSEvent)
    {
        
        if let clickedNode = simulator.simulationNodes[forNode]
        {
            log(7, "clicked name: \(clickedNode.node.userName)")
        }
    }
    
    override func drawRect(dirtyRect: NSRect)
    {
        
        
        
        
        var bPath:NSBezierPath = NSBezierPath()
        bPath.appendBezierPathWithRoundedRect(dirtyRect, xRadius: 10.0, yRadius: 10.0)
        
        var gradient:NSGradient = NSGradient(colorsAndLocations:
            (NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),0.0),
            (NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),0.25),
            (NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),0.50),
            (NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),0.75),
            (NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),1.0))
        
        gradient.drawInBezierPath(bPath, angle: 0.0)
        
        
        
        
        
    }
    
    
    
    
    
}