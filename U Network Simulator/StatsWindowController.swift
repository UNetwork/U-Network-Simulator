//
//  File.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/4/15.
//

import Foundation
import Cocoa

class StatsWindowController:NSWindowController
{

    @IBOutlet weak var statsText: NSTextField!
    
    @IBAction func update(sender: AnyObject)
    {
        self.statsText.stringValue = simulationStats().text
    }
    
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
        self.statsText.stringValue=simulationStats().text
    }
}


func simulationStats() -> (text:String, values:[Int])
{    
    var result=""
    
    var globalStats=Array(count: StatsEvents.allValues.count, repeatedValue: 0)
    
    var avgPeers=0
    var avgNames=0
    var avgAddresses=0
    var minLat:UInt64=maxLatitude
    var minLong:UInt64=maxLongitude
    var minAlt:UInt64=maxAltitude
    var maxLat:UInt64=0
    var maxLong:UInt64=0
    var maxAlt:UInt64=0
    var numberOfNodes=simulator.simulationNodes.count
    
    var numberOfPeersDistribution=Array(count: 16, repeatedValue: 0)
    
    for  simNode in simulator.simulationNodes.values
    {
        for(i, value)in simNode.node.nodeStats.nodeStats.enumerate()
        {
            globalStats[i]+=value
        }
        
        avgPeers += simNode.node.peers.count
        avgNames += simNode.node.knownIDs.count
        avgAddresses += simNode.node.knownIDs.count
        
        if(simNode.node.address.latitude<minLat)
        {
            minLat=simNode.node.address.latitude
        }
        if(simNode.node.address.longitude<minLong)
        {
            minLong=simNode.node.address.longitude
        }
        if(simNode.node.address.altitude<minAlt)
        {
            minAlt=simNode.node.address.altitude
        }
        
        if(simNode.node.address.latitude>maxLat)
        {
            maxLat=simNode.node.address.latitude
        }
        if(simNode.node.address.longitude>maxLong)
        {
            maxLong=simNode.node.address.longitude
        }
        if(simNode.node.address.altitude>maxAlt)
        {
            maxAlt=simNode.node.address.altitude
        }
        
        if (simNode.node.peers.count<16)
        {
            numberOfPeersDistribution[simNode.node.peers.count]++
        }
        else
        {
            numberOfPeersDistribution[15]++
        }
        
    }
    
    if(numberOfNodes > 0)
    {
    avgPeers /= numberOfNodes
    avgNames /= numberOfNodes
    avgAddresses /= numberOfNodes
    }
    
    for index in  0..<StatsEvents.allValues.count
    {
        result+="\(StatsEvents.allValues[index]) : \(globalStats[index]) \n"
        result += (index == 1 || index == 7 || index == 13 ? "\n":"")
    }
    
    result+="\n"
    result+="Number of nodes: \(numberOfNodes)\n"
    result+="Average peers: \(avgPeers) names: \(avgNames) addresses: \(avgAddresses)\n"
    
    let minCoordinates=convertUInt64CoordinatesToFlotingPoint(minLat, inputLongitude: minLong, inputAltitude: minAlt)
    let maxCoordinates=convertUInt64CoordinatesToFlotingPoint(maxLat, inputLongitude: maxLong, inputAltitude: maxAlt)
    
    result += "lat: \(minCoordinates.latitude.value) -  \(maxCoordinates.latitude.value)\n"
    result += "long: \(minCoordinates.longitude.value) - \(maxCoordinates.longitude.value)  \n"
    result += "alt: \(minCoordinates.altitude.value) - \(maxCoordinates.altitude.value) \n"
    
    result+="\nNumber of peers distribution:\n"
    for (index, data) in numberOfPeersDistribution.enumerate()
    {
        result+="\(index) : \(data)\n"
    }
    
    return (result, globalStats)
}
