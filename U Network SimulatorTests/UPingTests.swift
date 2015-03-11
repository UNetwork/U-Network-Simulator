//
//  UPingTests.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/10/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Cocoa
import XCTest

class UPingTests: XCTestCase {
    
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        simulator=UNetworkSimulator()
        
    }
    
    
    func testPingSimple()
    {
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: 2, inputLongitude: 3, inputAltitude: 4))
        

        
        simulator.simulationNodes[0].node.setupAndStart()
        
        XCTAssert(simulator.simulationNodes[0].node.peers.count == 0, "single node cant have a peer")
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: 200, inputLongitude: 300, inputAltitude: 400))
        
        simulator.simulationNodes[0].node.setupAndStart()
        simulator.simulationNodes[1].node.setupAndStart()
        
        sleep(1)

        
        XCTAssert(simulator.simulationNodes[0].node.peers.count == 1, "one peer only")

        XCTAssert(simulator.simulationNodes[1].node.peers.count == 1, "one peer only")

        
        let asdf=simulator.simulationNodes[0].node
        let dsfs=simulator.simulationNodes[1].node

        
        
    }
    
    func testPing()
    {
     
        
        let networkLat=UInt64(65365)
        let networkLong=UInt64(65365)
        let networkAlt=UInt64(65365)
        let meshSize=UInt64(30)
        
        
        for var lat:UInt64 = networkLat; lat < networkLat+(meshSize * wirelessInterfaceRange); lat = lat + wirelessInterfaceRange - 100
        {
            for var long:UInt64 = networkLong; long < networkLong+(meshSize * wirelessInterfaceRange); long = long + wirelessInterfaceRange - 100
            {
        
                    simulator.addWirelessNode(USimulationRealLocation(inputLatitude: lat, inputLongitude: long, inputAltitude: networkAlt))
                
                
            }
        }
        
        for (_, aNode) in enumerate(simulator.simulationNodes)
        {
            
            aNode.node.setupAndStart()
            
            
        }
        
        sleep(15)
        
        simulator.simulationNodes[0].node.pingApp.sendPing(simulator.simulationNodes[simulator.simulationNodes.count - 1].node.id, address: simulator.simulationNodes[simulator.simulationNodes.count-1].node.address)
        simulator.simulationNodes[simulator.simulationNodes.count - 1].node.pingApp.sendPing(simulator.simulationNodes[0].node.id, address: simulator.simulationNodes[0].node.address)
        
        sleep(30)

        
        
        XCTAssert(simulator.simulationNodes[0].node.nodeStats.nodeStats[StatsEvents.PingHadAPongWithProperSerial.rawValue] == 1, "no pong")

        var globalStats=Array(count: 64, repeatedValue: 0)
        
        for (_, simNode) in enumerate(simulator.simulationNodes)
        {
            for(i, value)in enumerate(simNode.node.nodeStats.nodeStats)
            {
            globalStats[i]+=value
            }
        }
        
        for(_, value) in enumerate(globalStats)
        {
            println(" \(value) ")
            
        }
    }
    
    
}
