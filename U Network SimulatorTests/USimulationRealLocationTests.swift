//
//  TestUSimulationRealLocation.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/20/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Cocoa
import XCTest

class USimulationRealLocationTests: XCTestCase {

    
    func testRealLocation ()
    {
    
        var testVariable=USimulationRealLocation(inputLatitude: 123, inputLongitude: 456, inputAltitude: 789)
        
        XCTAssert(testVariable.latitude == 123 && testVariable.longitude == 456 && testVariable.altitude == 789, "Data OK Fail")
        
        for i in 1...1000
        {
        
        testVariable.moveBy(Int64(rand()), moveLongitude: Int64(rand()), moveAltitude: Int64(rand()))
            
            
            XCTAssert(testVariable.latitude < 1 << 48 && testVariable.longitude < 1 << 48 && testVariable.altitude < 1 << 32, "Random movment Fail")
        
        }
        
         
    }
    

    

}
