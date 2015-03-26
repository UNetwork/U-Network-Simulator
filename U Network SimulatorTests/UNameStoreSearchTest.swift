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
        AppDelegate.sharedInstance.logClearText("")
        AppDelegate.sharedInstance.logLevel = 3
    }
    
    override func tearDown()
    {
        super.tearDown()
        
        println(AppDelegate.sharedInstance.logText)
        let stats=simulationStats()
        
        println(stats.text)
        
    }
    
    
    
    func testNameStoreSimple() {
        
        AppDelegate.sharedInstance.logLevel = 2
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: exampleNodeAddress.latitude, inputLongitude: exampleNodeAddress.longitude, inputAltitude: exampleNodeAddress.altitude))
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: closeToExampleNodeAddress.latitude, inputLongitude: closeToExampleNodeAddress.longitude, inputAltitude: closeToExampleNodeAddress.altitude))
        
        simulator.simulationNodes[0].node.setupAndStart()
        simulator.simulationNodes[1].node.setupAndStart()
        
        sleep(1)
        let firstNode=simulator.simulationNodes[0].node
        let lastNode=simulator.simulationNodes[simulator.simulationNodes.count - 1].node
        
        firstNode.searchApp.storeName()
        lastNode.searchApp.storeName()
        
        sleep(1)
        
        XCTAssert(firstNode.knownNames.count == 2, "Wrong number of names")
        XCTAssert(lastNode.knownNames.count == 2, "Wrong number of names")
        
        firstNode.searchApp.findIdForName(firstNode.userName)
        lastNode.searchApp.findIdForName(firstNode.userName)
        
        sleep(1)
        
        
        XCTAssert(firstNode.nodeStats.nodeStats[StatsEvents.SearchForNameSucess.rawValue] == 8, "name not found")
        XCTAssert(lastNode.nodeStats.nodeStats[StatsEvents.SearchForNameSucess.rawValue] == 8, "name not found")
        
    }

    
    func testNameStoreMedium()
    {
        
        AppDelegate.sharedInstance.logLevel = 2
        
        // network size
        
        let k:UInt32 = 4
        let i:UInt32 = 1
        let j:UInt32 = 1
        
        // distance between nodes
        
        let distance:UInt64=570
        
        createNodeMesh(k, i, j, distance, exampleNodeAddress, false)
        
        sleep(1)
        
        let firstNode=simulator.simulationNodes[0].node
        let lastNode=simulator.simulationNodes[simulator.simulationNodes.count - 1].node
        
        firstNode.searchApp.storeName()
        lastNode.searchApp.storeName()
        
        sleep(1)
        
        firstNode.searchApp.findIdForName(firstNode.userName)
        lastNode.searchApp.findIdForName(firstNode.userName)
        
        sleep(1)
        
        
        XCTAssert(firstNode.nodeStats.nodeStats[StatsEvents.SearchForNameSucess.rawValue] == 8, "name not found")
        XCTAssert(lastNode.nodeStats.nodeStats[StatsEvents.SearchForNameSucess.rawValue] == 8, "name not found")
        
    }
    
    func testNameStoreABitMore()
    {
        AppDelegate.sharedInstance.logLevel = 3
        
        // network size
        
        let k:UInt32 = 8
        let i:UInt32 = 8
        let j:UInt32 = 8
        
        // distance between nodes
        
        let distance:UInt64=570
        
        createNodeMesh(k, i, j, distance, exampleNodeAddress, false)
        
        sleep(5)
        
        
        let firstNode=simulator.simulationNodes[0].node
        let lastNode=simulator.simulationNodes[simulator.simulationNodes.count - 1].node
        
        firstNode.searchApp.storeName()
        lastNode.searchApp.storeName()
        
        sleep(3)
        
        firstNode.searchApp.findIdForName(firstNode.userName)
        lastNode.searchApp.findIdForName(firstNode.userName)
        
        sleep(3)
        
        
        XCTAssert(firstNode.nodeStats.nodeStats[StatsEvents.SearchForNameSucess.rawValue] == 8, "name not found")
        XCTAssert(lastNode.nodeStats.nodeStats[StatsEvents.SearchForNameSucess.rawValue] == 8, "name not found")

    }
    
    
}





























