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
        
        
        simulator.simulationNodes[0].node.pingApp.sendPing(simulator.simulationNodes[simulator.simulationNodes.count - 1].node.id, address: simulator.simulationNodes[simulator.simulationNodes.count-1].node.address)
        sleep(125)

        
        
        XCTAssert(simulator.simulationNodes[0].node.nodeStats.nodeStats[StatsEvents.PingHadAPongWithProperSerial.rawValue] == 1, "no pong")

        
        
        
    }
    
    
}
