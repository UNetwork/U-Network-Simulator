//
//  UAddressStoreSearchTests.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/25/15.
//

import Cocoa
import XCTest

class UAddressStoreSearchTests: XCTestCase {

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

    
    
    
    func testAddressSearchSimple()
    {
        
        AppDelegate.sharedInstance.logLevel = 3
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: exampleNodeAddress.latitude, inputLongitude: exampleNodeAddress.longitude, inputAltitude: exampleNodeAddress.altitude))
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: closeToExampleNodeAddress.latitude, inputLongitude: closeToExampleNodeAddress.longitude, inputAltitude: closeToExampleNodeAddress.altitude))
        
        simulator.simulationNodes[0].node.setupAndStart()
        simulator.simulationNodes[1].node.setupAndStart()
        
        sleep(1)
        let firstNode=simulator.simulationNodes[0].node
        let lastNode=simulator.simulationNodes[simulator.simulationNodes.count - 1].node
        
        firstNode.searchApp.storeAddress()
        lastNode.searchApp.storeAddress()
        
        sleep(1)
        
        AppDelegate.sharedInstance.logLevel = 2

        
        firstNode.searchApp.findAddressForId(lastNode.id)
        lastNode.searchApp.findAddressForId(firstNode.id)
        
        sleep(1)
        
        
        XCTAssert(firstNode.nodeStats.nodeStats[StatsEvents.AddressSearchResultRecieved.rawValue] == 8, "name not found")
        XCTAssert(lastNode.nodeStats.nodeStats[StatsEvents.AddressSearchResultRecieved.rawValue] == 8, "name not found")
        
        
    }
    
    func testAddressSearchMedium()
    {
        // network size
        
        let k:UInt32 = 4
        let i:UInt32 = 4
        let j:UInt32 = 4
        
        // distance between nodes
        
        let distance:UInt64=570
        
        createNodeMesh(k, i, j, distance, exampleNodeAddress, false)
        
        sleep(5)
        
        let firstNode=simulator.simulationNodes[0].node
        let lastNode=simulator.simulationNodes[simulator.simulationNodes.count - 1].node
        
        AppDelegate.sharedInstance.logLevel = 3

        
        firstNode.searchApp.findAddressForId(lastNode.id)
        lastNode.searchApp.findAddressForId(firstNode.id)
        
        sleep(1)
        
        
        XCTAssert(firstNode.nodeStats.nodeStats[StatsEvents.AddressSearchResultRecieved.rawValue] == 8, "name not found")
        XCTAssert(lastNode.nodeStats.nodeStats[StatsEvents.AddressSearchResultRecieved.rawValue] == 8, "name not found")


    }

}
