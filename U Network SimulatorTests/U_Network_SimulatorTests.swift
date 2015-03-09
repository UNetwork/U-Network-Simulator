//
//  U_Network_SimulatorTests.swift
//  U Network SimulatorTests
//
//  Created by Andrzej Parszuto on 2/10/15.
//

import Cocoa
import XCTest

class U_Network_SimulatorTests:XCTestCase {
    
    func testWirelessNode()
    {
        simulator=UNetworkSimulator() // reset world
       
        
        // simple creation
        
        let loc1=USimulationRealLocation(inputLatitude:UInt64(100), inputLongitude:UInt64(100), inputAltitude:UInt64(100))
        
        let loc2=USimulationRealLocation(inputLatitude:UInt64(200), inputLongitude:UInt64(200), inputAltitude:UInt64(200))
        let loc3=USimulationRealLocation(inputLatitude:UInt64(30000000), inputLongitude:UInt64(30000000), inputAltitude:UInt64(30000000))
        
        
        simulator.addWirelessNode(loc1)
        simulator.addWirelessNode(loc2)
        
        simulator.addWirelessNode(loc3)
        
        XCTAssert(simulator.simulationNodes.count == 3, "Adding wireless node fail")
        
        var someWirelessInterfaces = simulator.wirelessMedium.findInterfacesInRange(simulator.simulationNodes[0].node.interfaces[0] as! UNetworkInterfaceSimulationWireless)
        
        XCTAssert(someWirelessInterfaces.count == 1, "Cant locate wireless interface nearby")
        
        someWirelessInterfaces = simulator.wirelessMedium.findInterfacesInRange(simulator.simulationNodes[2].node.interfaces[0] as! UNetworkInterfaceSimulationWireless)
        
        XCTAssert(someWirelessInterfaces.count == 0, "Cant locate wireless interface nearby")

        // range
        
    }
    
    
    
    
    


    
}
