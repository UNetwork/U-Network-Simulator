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
        AppDelegate.sharedInstance.logClearText()
    
    }
    
    override func tearDown() {
        super.tearDown()
        
        println(simulationStats())
        println(AppDelegate.sharedInstance.logText)
    }
    
    func testBroadcastSimple()
    {
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: exampleNodeAddress.latitude, inputLongitude: exampleNodeAddress.longitude, inputAltitude: exampleNodeAddress.altitude))
        
          }
    
    
    func testBroadcastTwoNodes()
    {
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: exampleNodeAddress.latitude, inputLongitude: exampleNodeAddress.longitude, inputAltitude: exampleNodeAddress.altitude))
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: closeToExampleNodeAddress.latitude, inputLongitude: closeToExampleNodeAddress.longitude, inputAltitude: closeToExampleNodeAddress.altitude))
        
              sleep(1)
        
        
                
    }

}
