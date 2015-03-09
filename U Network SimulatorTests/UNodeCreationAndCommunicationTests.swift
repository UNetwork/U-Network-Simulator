//
//  UNodeCreationAndCommunicationTests.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/9/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Cocoa
import XCTest

class UNodeCreationAndCommunicationTests: XCTestCase {
    
    func  testNodeCreation()
    {
        
        let networkLat=UInt64(65365)
        let networkLong=UInt64(65365)
        let networkAlt=UInt64(65365)
        let meshSize=UInt64(5)
        
        for var lat:UInt64 = networkLat; lat < networkLat+(meshSize * wirelessInterfaceRange); lat = lat + wirelessInterfaceRange >> 1
        {
            for var long:UInt64 = networkLong; long < networkLong+(meshSize * wirelessInterfaceRange); long = long + wirelessInterfaceRange >> 1
            {
                for var alt:UInt64 = networkAlt; alt < networkAlt+(meshSize * wirelessInterfaceRange); alt = alt + wirelessInterfaceRange >> 1
                {
                    simulator.addWirelessNode(USimulationRealLocation(inputLatitude: lat, inputLongitude: long, inputAltitude: alt))
                }
                
            }
        }
        
        for (_, aNode) in enumerate(simulator.simulationNodes)
        {
            aNode.node.setupAndStart()
            
        }
        
        for (_, aNode) in enumerate(simulator.simulationNodes)
        {
            XCTAssert(aNode.node.peers.count > 0, "There are lonley peers")
            
        }
        
        
        
        
        
        
        
    }
    
}
