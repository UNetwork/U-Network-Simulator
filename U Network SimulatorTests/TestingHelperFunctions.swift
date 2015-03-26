//
//  TestingHelperFunctions.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/15/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Foundation

func simulationStats() -> (text:String, values:[Int])
{
   
    
    var result="\nSimulation Report\n\n"
    
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
    
    for (_, simNode) in enumerate(simulator.simulationNodes)
    {
        for(i, value)in enumerate(simNode.node.nodeStats.nodeStats)
        {
            globalStats[i]+=value
        }
        
        avgPeers += simNode.node.peers.count
        avgNames += simNode.node.knownNames.count
        avgAddresses += simNode.node.knownNames.count
        
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
    
    avgPeers /= numberOfNodes
    avgNames /= numberOfNodes
    avgAddresses /= numberOfNodes
    
    for index in  0..<StatsEvents.allValues.count
    {
        result+="\(StatsEvents.allValues[index]) : \(globalStats[index]) \n"
        result += (index == 1 || index == 7 || index == 13 ? "\n":"")
    }
    
    result+="\nNetwork summary:\n\n"
    result+="Number of nodes: \(numberOfNodes)\n"
    result+="Average peers: \(avgPeers) names: \(avgNames) addresses: \(avgAddresses)\n"
    result+="Space:\n"
    
    let minCoordinates=convertUInt64CoordinatesToFlotingPoint(minLat, minLong, minAlt)
    let maxCoordinates=convertUInt64CoordinatesToFlotingPoint(maxLat, maxLong, maxAlt)
    
    result+="MIN lat: \(minCoordinates.latitude.value) long: \(minCoordinates.longitude.value) alt: \(minCoordinates.altitude.value) m\n"
    result+="MAX lat: \(maxCoordinates.latitude.value) long: \(maxCoordinates.longitude.value) alt: \(maxCoordinates.altitude.value) m\n"

    result+="\nNumber of peers distribution:\n"
    for (index, data) in enumerate(numberOfPeersDistribution)
    {
        result+="\(index) : \(data)\n"
    }
    

    
    
    
    
    
    
    return (result, globalStats)
}

func createNodeMesh(rows:UInt32, columns:UInt32, layers:UInt32, distance:UInt64,  position:UNodeAddress, random:Bool)
{
     simulator=UNetworkSimulator()
    
    let dist=UInt32(distance)
    var distLat:UInt32 = 0
    var distLong:UInt32 = 0
    var distAlt:UInt32 = 0
    
    for r in 1...rows
    {
        for c in 1...columns
        {
            for l in 1...layers
            {
                if(random)
                {
                    distLat = arc4random_uniform(dist)
                    distLong = arc4random_uniform(dist)
                    distAlt = arc4random_uniform(dist)
                }
            let nodePosition=USimulationRealLocation(inputLatitude: (UInt64(r-1) * distance) + position.latitude + UInt64(distLat), inputLongitude: (UInt64(c-1) * distance) + position.longitude + UInt64(distLong), inputAltitude: (UInt64(l-1) * distance) + position.altitude + UInt64(distAlt))
              
                simulator.addWirelessNode(nodePosition)
            }
        }
    }
    
    for (_, aNode) in enumerate(simulator.simulationNodes)
    {
        aNode.node.setupAndStart()
    }
    log (5,"Initial setup done")

    for (_, aNode) in enumerate(simulator.simulationNodes)
        {
        aNode.node.populateOwnData()
        }
    
    log (5,"Data populated")
 
}


var exampleNodeAddress:UNodeAddress
{
    let addressF=CoordinatesFloatDegreesAndAltitude(inputLatitude: 51.0, inputLongitude: 17.0, inputAltitude: 130.0)
    
    let addressU=convertFlotingPointCoordinatesToUInt64(addressF)
    
    let nodeAddress=UNodeAddress(inputLatitude: addressU.latitude, inputLongitude: addressU.longitude, inputAltitude: addressU.altitude)
    
    return nodeAddress
}

var closeToExampleNodeAddress:UNodeAddress
{
    let lat = exampleNodeAddress.latitude + wirelessInterfaceRange / 8
    let long = exampleNodeAddress.longitude + wirelessInterfaceRange / 8
    let alt = exampleNodeAddress.altitude + wirelessInterfaceRange / 8
    return(UNodeAddress(inputLatitude: lat, inputLongitude: long, inputAltitude: alt))
}















