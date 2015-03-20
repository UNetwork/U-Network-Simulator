//
//  UNameStoreAndSearchTest.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/14/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Cocoa
import XCTest

class UNameStoreAndSearchTest: XCTestCase {

    override func setUp() {
        super.setUp()
       
        simulator=UNetworkSimulator()
        let networkLat=UInt64(65365)
        let networkLong=UInt64(65365)
        let networkAlt=UInt64(65365)
        let meshSizeLat=UInt64(6)
        let meshSizeLong=UInt64(6)
        let meshSizeLAlt=UInt64(6)

        
        
        for var lat:UInt64 = networkLat; lat < networkLat+(meshSizeLat * wirelessInterfaceRange); lat = lat + wirelessInterfaceRange - 100
        {
            for var long:UInt64 = networkLong; long < networkLong+(meshSizeLong * wirelessInterfaceRange); long = long + wirelessInterfaceRange - 100
            {
                for var alt:UInt64 = networkAlt; alt < networkAlt+(meshSizeLAlt * wirelessInterfaceRange); alt = alt + wirelessInterfaceRange - 100
                {
                    simulator.addWirelessNode(USimulationRealLocation(inputLatitude: lat, inputLongitude: long, inputAltitude: alt))
                }
                
            }
        }
        
        for (_, aNode) in enumerate(simulator.simulationNodes)
        {
            
            aNode.node.setupAndStart()
            
        }

        sleep(2)
        for (_, aNode) in enumerate(simulator.simulationNodes)
        {
            
            aNode.node.storeAndSearchRouter.storeName(10)
            
        }
    
    
    }
    

    func testNameSearch() {

        simulator.simulationNodes[0].node.searchApp.findIdForName(simulator.simulationNodes[simulator.simulationNodes.count - 1].node.userName, depth: UInt32(600))
        let sim=simulator
        sleep(1)
        
     
        
   

           XCTAssert(simulator.simulationNodes[0].node.nodeStats.nodeStats[StatsEvents.SearchForNameSucess.rawValue] > 0, "Name not found")
    }


    

}
