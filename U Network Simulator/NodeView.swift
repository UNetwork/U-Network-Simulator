//
//  NodeView.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/9/15.
//

import Foundation
import Cocoa


let nodeViewSize = CGFloat(30)
let minViewSize = CGFloat(10)

extension UNode {
    func view (forWindow:NSWindow) -> NodeView
    {
        
        let windowWidth = Float64(forWindow.contentView.bounds!.width - nodeViewSize)
        let windowHeight = Float64(forWindow.contentView.bounds!.height  - nodeViewSize)
        
        let deltaLat = Float64(simulator.maxLat - simulator.minLat)
        let deltaLong = Float64(simulator.maxLong - simulator.minLong)
        let deltaAlt = Float64(simulator.maxAlt - simulator.minAlt)
        
        let scaleLat = windowWidth / deltaLat
        let scaleLong =  windowHeight / deltaLong
        let scaleAlt = Float64(nodeViewSize + minViewSize) / deltaAlt
        
        
        let viewX = Float64(self.address.latitude - simulator.minLat) * scaleLat
        let viewY = Float64(self.address.longitude - simulator.minLong) * scaleLong
        let viewA = Float64(self.address.altitude - simulator.minAlt) * scaleAlt + Float64(minViewSize)
        
        let result = NodeView(frameAndPosition: NSRect(x: viewX, y: viewY, width: viewA, height: viewA), id: self.id)

        
        return result
        
        
    }
}

func packetTypeInInt (packet:UPacket) -> Int
{
    var result = Int(0)
    
    switch packet.packetCargo
    {
    case .DiscoveryBroadcast(let _): result = 1
    case .ReceptionConfirmation(let _): result = 2
    case .ReplyForDiscovery(let _):result = 3
    case .ReplyForNetworkLookupRequest(let _): result = 4
    case .SearchIdForName(let _): result = 5
    case .StoreIdForName(let _): result = 6
    case .StoreNamereply(let _): result = 7
    case .SearchAddressForID(let _): result = 8
    case .StoreAddressForId(let _): result = 9
    case .ReplyForIdSearch(let _):result = 10
    case .ReplyForAddressSearch(let _) : result = 11
    case .Ping(let _): result = 12
    case .Pong(let _): result = 13
    case .Data(let _): result = 14
    case .DataDeliveryConfirmation(let _): result = 15
    case .Dropped(let _): result = 16
        
    default: log(7, "Unknown packet type???")
    }
return result
}



class ConnectionView:NSView {
    
    var type = Int(0)
    var color = Int(0)
    
    convenience init (nodes fromId:UNodeID, toId:UNodeID, forWindow:NSWindow, packet:UPacket)
    {
        let windowWidth = Float64(forWindow.contentView.bounds!.width - nodeViewSize)
        let windowHeight = Float64(forWindow.contentView.bounds!.height  - nodeViewSize)
        
        let deltaLat = Float64(simulator.maxLat - simulator.minLat)
        let deltaLong = Float64(simulator.maxLong - simulator.minLong)
        let deltaAlt = Float64(simulator.maxAlt - simulator.minAlt)
        
        let scaleLat = windowWidth / deltaLat
        let scaleLong =  windowHeight / deltaLong
        let scaleAlt = Float64(nodeViewSize + minViewSize) / deltaAlt
        
        var fX = Float64(0)
        var fY = Float64(0)
        var tX = Float64(0)
        var tY = Float64(0)
        var dX = Float64(0)
        var dY = Float64(0)
        
        var tA = Float64(0)
        var fA = Float64(0)
        
        var prototype = Int(0)
        
        
        if let fromNode = simulator.simulationNodes[fromId]
        {
            fA = Float64(fromNode.node.address.altitude - simulator.minAlt) * scaleAlt
            
            fX = Float64(fromNode.node.address.latitude - simulator.minLat) * scaleLat + (Float64(minViewSize) + fA)/2
            fY = Float64(fromNode.node.address.longitude - simulator.minLong) * scaleLong + (Float64(minViewSize) + fA)/2
        }
        
        if let toNode = simulator.simulationNodes[toId]
        {
            tA = Float64(toNode.node.address.altitude - simulator.minAlt) * scaleAlt
            
            tX = Float64(toNode.node.address.latitude - simulator.minLat) * scaleLat + (Float64(minViewSize) + tA)/2
            tY = Float64(toNode.node.address.longitude - simulator.minLong) * scaleLong + (Float64(minViewSize) + tA)/2
        }
        
        var viewX:Float64
        var viewY:Float64
        
        
        if (fX < tX)
        {
            dX = tX - fX
            viewX = fX
        }
        else
        {
            dX = fX - tX
            viewX = tX
            prototype += 1
        }
        
        if (fY < tY)
        {
            dY = tY - fY
            viewY = fY
        }
        else
        {
            dY = fY - tY
            viewY = tY
            prototype += 2
            
        }
        
        
        
        
        let frameRect=NSRect(x: viewX, y: viewY, width: dX , height: dY)
        
        self.init(frame: frameRect)
        
        

        self.type = prototype
        self.activate(packet)

        
        
        
    }
    
    func activate(packet:UPacket)
    {
        self.color=packetTypeInInt(packet)

        self.setNeedsDisplayInRect(self.bounds)
    }
    
    
    
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    
    
    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func drawRect(dirtyRect: NSRect)
    {
        
        
        
        
        var bPath:NSBezierPath = NSBezierPath()
        
        if (self.type == 0)
        {
            bPath.moveToPoint(CGPoint(x: 0, y: 0))
            bPath.lineToPoint(CGPoint(x: self.bounds.width, y: self.bounds.height))
        }
        if (self.type == 1)
        {
            bPath.moveToPoint(CGPoint(x: self.bounds.width, y: 0))
            bPath.lineToPoint(CGPoint(x: 0, y: self.bounds.height))
        }
        if (self.type == 2)
        {
            bPath.moveToPoint(CGPoint(x: 0, y: self.bounds.height))
            bPath.lineToPoint(CGPoint(x: self.bounds.width, y: 0))
        }
        if (self.type == 3)
        {
            bPath.moveToPoint(CGPoint(x: self.bounds.width, y: self.bounds.height))
            bPath.lineToPoint(CGPoint(x: 0, y: 0))
        }
        
        let aColor=packetColors[self.color]
        aColor.setStroke()
        
        bPath.stroke()
    }
    
    
}




class NodeView:NSView {
    
    var forNode:UNodeID!
    var clicked = false

    
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
        if clicked {clicked = false}else{clicked = true}
        
        self.setNeedsDisplayInRect(self.bounds)
        
        if let clickedNode = simulator.simulationNodes[forNode]
        {
            log(6, "clicked name: \(clickedNode.node.userName)")
            
            let appdel = NSApplication.sharedApplication().delegate as! AppDelegate
            
            if let nodeWindow = appdel.nodeWindow
            {
                nodeWindow.showNode(clickedNode.node.id)
                
                
            }

        }
    }
    
    override func drawRect(dirtyRect: NSRect)
    {
        
        
        
        
        var bPath:NSBezierPath = NSBezierPath()
        bPath.appendBezierPathWithRoundedRect(self.bounds, xRadius: 10.0, yRadius: 10.0)
        
        let aColor = NSColor(calibratedRed:(clicked ? 1.0 : 0.75), green:clicked ? 0.0 : 0.85, blue: clicked ? 1.0 : 0.75, alpha: clicked ? 1.0 : 0.5)
        aColor.set()
        bPath.fill()
        
        

        
        
        
    }
    
}



let packetColors = [
    NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0),
    NSColor(calibratedRed: 0.25, green: 0, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0.25, green: 0.25, blue: 0, alpha: 1),
    NSColor(calibratedRed: 1, green: 0.75, blue: 0.25, alpha: 1),
    NSColor(calibratedRed: 0, green: 0.25, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0, green: 0, blue: 0.25, alpha: 1),
    NSColor(calibratedRed: 0.0, green: 0.25, blue: 0.25, alpha: 1),
    NSColor(calibratedRed: 0.25, green: 0.5, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0.25, green: 0, blue: 0.5, alpha: 1),
    NSColor(calibratedRed: 0.5, green: 0, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0.5, green: 0.5, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0.5, green: 0, blue: 0.5, alpha: 1),
    NSColor(calibratedRed: 0.75, green: 0, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0.75, green: 0, blue: 0.5, alpha: 1),
    NSColor(calibratedRed: 0.75, green: 0.5, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0.75, green: 0.5, blue: 0.5, alpha: 1),
    NSColor(calibratedRed: 0.25, green: 0.75, blue: 0.75, alpha: 1)]



