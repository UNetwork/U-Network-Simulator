//
//  UNodeCreationAndCommunicationTests.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/9/15.
//

import Cocoa
import XCTest

class UNodeCreationAndCommunicationTests: XCTestCase {
    
    func  testNodeCreation()
    {
        simulator=UNetworkSimulator()
        let networkLat=UInt64(65365)
        let networkLong=UInt64(65365)
        let networkAlt=UInt64(65365)
        let meshSize=UInt64(4)
        
        
        for var lat:UInt64 = networkLat; lat < networkLat+(meshSize * wirelessInterfaceRange); lat = lat + wirelessInterfaceRange - 100
        {
            for var long:UInt64 = networkLong; long < networkLong+(meshSize * wirelessInterfaceRange); long = long + wirelessInterfaceRange - 100
            {
                for var alt:UInt64 = networkAlt; alt < networkAlt+(meshSize * wirelessInterfaceRange); alt = alt + wirelessInterfaceRange - 100
                {
                    simulator.addWirelessNode(USimulationRealLocation(inputLatitude: lat, inputLongitude: long, inputAltitude: alt))
                }
                
            }
        }
        
        for (_, aNode) in enumerate(simulator.simulationNodes)
        {

            aNode.node.setupAndStart()
          
            
        }
         sleep(10)
        for (_, aNode) in enumerate(simulator.simulationNodes)
        {
            XCTAssert(aNode.node.peers.count > 0, "There are lonley peers")
            
        }
        
        
        
        
        
        
        
    }
    
}
