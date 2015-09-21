//
//  VisualisationLayers.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/21/15.
//

import Foundation
import Cocoa


let nodeLayerSize = CGFloat(10)
let minNodeLayerSize = CGFloat(5)


extension UNode {
    func visualistaionLayer(forLayer:CALayer) -> NodeLayer
    {
        let result = NodeLayer()
        
        result.forNode = self.id
        
        
        let viewX = Float64(self.address.latitude - simulator.minLat) * scaleLat
        let viewY = Float64(self.address.longitude - simulator.minLong) * scaleLong
        let viewA = Float64(self.address.altitude - simulator.minAlt) * scaleAlt + Float64(minNodeLayerSize)
        
        result.frame = CGRect(x: viewX, y: viewY, width: viewA, height: viewA)
        
        result.backgroundColor = packetColors[0]
        
        return result
    }
}


class NodeLayer:CAShapeLayer
{
    
    var forNode:UNodeID!
    var clicked = false
    
    func getClick()
    {
        if clicked {clicked = false}else{clicked = true}
        
        
        self.backgroundColor = clicked ? packetColors[12] : packetColors[0]
    }
}

class ConnectionLayer:CAShapeLayer
{
    
    var color = Int(0)
    
}



func createConnectionLayer(nodes fromId:UNodeID, toId:UNodeID, packet:UPacket) -> ConnectionLayer
{
    let result = ConnectionLayer()
    
    
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

        fX = Float64(fromNode.node.address.latitude - simulator.minLat) * scaleLat + (Float64(minNodeLayerSize) + fA)/2
        fY = Float64(fromNode.node.address.longitude - simulator.minLong) * scaleLong + (Float64(minNodeLayerSize) + fA)/2
    }
    
    if let toNode = simulator.simulationNodes[toId]
    {
        tA = Float64(toNode.node.address.altitude - simulator.minAlt) * scaleAlt
        tX = Float64(toNode.node.address.latitude - simulator.minLat) * scaleLat + (Float64(minNodeLayerSize) + tA)/2
        tY = Float64(toNode.node.address.longitude - simulator.minLong) * scaleLong + (Float64(minNodeLayerSize) + tA)/2
    }
    
    var viewX=Float64(0)
    var viewY=Float64(0)
    
    let aPath = CGPathCreateMutable()

    if (fX < tX)
    {
        dX = tX - fX
        if (dX < 1){dX=1}
        viewX = fX
    }
    else
    {
        dX = fX - tX
        if (dX < 1){dX=1}
        viewX = tX
        prototype += 1
    }
    
    if (fY < tY)
    {
        dY = tY - fY
        if (dY < 1){dY=1}
        viewY = fY
    }
    else
    {
        dY = fY - tY
        if (dY < 1){dY=1}
        viewY = tY
        prototype += 2
    }
    
    result.frame = NSRect(x: viewX, y: viewY, width: dX , height: dY)
    
    if (prototype == 0)
    {
        CGPathMoveToPoint(aPath,nil,0,0)
        CGPathAddLineToPoint(aPath, nil, result.bounds.width, result.bounds.height)
    }
    if (prototype == 1)
    {
        CGPathMoveToPoint(aPath,nil,result.bounds.width,0)
        CGPathAddLineToPoint(aPath,nil, 0, result.bounds.height)
    }
    if (prototype == 2)
    {
        CGPathMoveToPoint(aPath,nil,0,result.bounds.height)
        CGPathAddLineToPoint(aPath, nil, result.bounds.width, 0)
    }
    if (prototype == 3)
    {
        CGPathMoveToPoint(aPath,nil,result.bounds.width, result.bounds.height)
        CGPathAddLineToPoint(aPath, nil, 0, 0)
    }
    
    result.path = aPath
    
    result.strokeColor = packetColors[packetTypeInInt(packet)]
    result.lineWidth = 3.0
    
    
    return result
}





// helper functions


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
        
    default: log(7, text: "Unknown packet type???")
    }
    return result
}