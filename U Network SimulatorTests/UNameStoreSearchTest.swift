//
//  UNameStoreSearchTest.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/24/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Cocoa
import XCTest

class UNameStoreSearchTest: XCTestCase {
    
    
    override func setUp()
    {
        super.setUp()
        
        simulator=UNetworkSimulator()
        AppDelegate.sharedInstance.logClearText()
        logLevel = 3
    }
    
    override func tearDown()
    {
        super.tearDown()
        
        print(AppDelegate.sharedInstance.logText)
        let stats=simulationStats()
        
        print(stats.text)
        
    }
    
    
    
    func testNameStoreSimple() {
        
        logLevel = 2
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: exampleNodeAddress.latitude, inputLongitude: exampleNodeAddress.longitude, inputAltitude: exampleNodeAddress.altitude))
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: closeToExampleNodeAddress.latitude, inputLongitude: closeToExampleNodeAddress.longitude, inputAltitude: closeToExampleNodeAddress.altitude))
        

        
    }

    
    func testNameStoreMedium()
    {
        
        logLevel = 2
        
        // network size
        
        let k:UInt32 = 4
        let i:UInt32 = 1
        let j:UInt32 = 1
        
        // distance between nodes
        
        let distance:UInt64=570
        
   //     createNodeMesh(k, i, j, distance, exampleNodeAddress, false)
        
        sleep(1)
        
    //    let firstNode=simulator.simulationNodes[0].node
   //     let lastNode=simulator.simulationNodes[simulator.simulationNodes.count - 1].node
        

        
        sleep(1)
        
   //     firstNode.searchApp.findIdForName(firstNode.ownerName, serial:random64())
     //   lastNode.searchApp.findIdForName(firstNode.ownerName, serial:random64())
        
        sleep(1)
        
        
    //    XCTAssert(firstNode.nodeStats.nodeStats[StatsEvents.SearchForNameSucess.rawValue] == 8, "name not found")
   //     XCTAssert(lastNode.nodeStats.nodeStats[StatsEvents.SearchForNameSucess.rawValue] == 8, "name not found")
        
    }
    
    func testNameStoreABitMore()
    {
        logLevel = 3
        
        // network size
        
        let k:UInt32 = 8
        let i:UInt32 = 8
        let j:UInt32 = 8
        
        // distance between nodes
        
        let distance:UInt64=570
        
      //  createNodeMesh(k, i, j, distance, exampleNodeAddress, false)
        
        sleep(135)
        
        
    //    let firstNode=simulator.simulationNodes[0].node
  //      let lastNode=simulator.simulationNodes[simulator.simulationNodes.count - 1].node
        
        
   //     firstNode.searchApp.findIdForName(firstNode.ownerName, serial:random64())
  //      lastNode.searchApp.findIdForName(firstNode.ownerName, serial:random64())
        
        sleep(160)
        
        
    //    XCTAssert(firstNode.nodeStats.nodeStats[StatsEvents.SearchForNameSucess.rawValue] > 0, "name not found")
  //      XCTAssert(lastNode.nodeStats.nodeStats[StatsEvents.SearchForNameSucess.rawValue] >  0, "name not found")

    }
    
    
}





























