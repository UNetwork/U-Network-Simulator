//
//  UDiscoveryProtocolTests.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/17/15.
//

import Cocoa
import XCTest

class UDiscoveryProtocolTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        simulator=UNetworkSimulator()
        AppDelegate.sharedInstance.logClearText("")
    
    }
    
    override func tearDown() {
        super.tearDown()
        
        println(simulationStats())
        println(AppDelegate.sharedInstance.logText)
    }
    
    func testBroadcastSimple()
    {
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: exampleNodeAddress.latitude, inputLongitude: exampleNodeAddress.longitude, inputAltitude: exampleNodeAddress.altitude))
        
        simulator.simulationNodes[0].node.setupAndStart()
        
        XCTAssert(simulator.simulationNodes[0].node.peers.count == 0, "Single node can't have a peer")
    }
    
    
    func testBroadcastTwoNodes()
    {
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: exampleNodeAddress.latitude, inputLongitude: exampleNodeAddress.longitude, inputAltitude: exampleNodeAddress.altitude))
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: closeToExampleNodeAddress.latitude, inputLongitude: closeToExampleNodeAddress.longitude, inputAltitude: closeToExampleNodeAddress.altitude))
        
        simulator.simulationNodes[0].node.setupAndStart()
        simulator.simulationNodes[1].node.setupAndStart()
        
        sleep(1)
        
        
        
        XCTAssert(simulator.simulationNodes[0].node.peers.count == 1, "No successful peer recognition")
        
        XCTAssert(simulator.simulationNodes[1].node.peers.count == 1, "No successful peer recognition")
        
    }

}
