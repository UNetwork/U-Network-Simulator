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
        AppDelegate.sharedInstance.logClearText()
        logLevel = 3
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
        
        logLevel = 3
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: exampleNodeAddress.latitude, inputLongitude: exampleNodeAddress.longitude, inputAltitude: exampleNodeAddress.altitude))
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: closeToExampleNodeAddress.latitude, inputLongitude: closeToExampleNodeAddress.longitude, inputAltitude: closeToExampleNodeAddress.altitude))
        
 
        
        
    }
    
    func testAddressSearchMedium()
    {
        // network size
        
        let k:UInt32 = 4
        let i:UInt32 = 4
        let j:UInt32 = 4
        
        // distance between nodes
        
        let distance:UInt64=570
        
  //      createNodeMesh(k, i, j, distance, exampleNodeAddress, false)
        
        sleep(5)
      

    }

}
