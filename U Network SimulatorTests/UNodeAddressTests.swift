//
//  UNodeAddressTests.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/19/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Cocoa
import XCTest

class UNodeAddressTests: XCTestCase {
    
    func testUNodeAddress(){
        
        var a1=UNodeAddress(inputLatitude: 3, inputLongitude: 4, inputAltitude: 5)
        
        XCTAssert( a1.latitude == 3 && a1.longitude == 4 && a1.altitude == 5, "345 not OK")
        
        
        
        
    }


    func testInit()
    {
        
        var testVariable=UNodeAddress(inputLatitude: 1, inputLongitude: 2, inputAltitude: 3)
        
        XCTAssert(testVariable.latitude == 1, "Data OK fail")
        XCTAssert(testVariable.longitude == 2, "Data OK fail")
        XCTAssert(testVariable.altitude == 3, "Data OK fail")
        
        var testVariable2=UNodeAddress(address: testVariable)
        
        var test = (testVariable.latitude == testVariable2.latitude) && (testVariable.longitude == testVariable2.longitude ) && (testVariable.altitude == testVariable2.altitude)
        
        XCTAssert(test, "Copy failed" )
        
        var latint = random64() &  0x0000ffffffffffff
        var longint = random64() & 0x0000ffffffffffff
        var altint = random64() &  0x00000000ffffffff
        
        var testlat:UInt64
        var testlong:UInt64
        var testalt:UInt64
        
        for i in 1...1000
        {
            
            latint = random64() &  0x0000ffffffffffff
            longint = random64() & 0x0000ffffffffffff
            altint = random64() &  0x00000000ffffffff
            
            testVariable=UNodeAddress(inputLatitude: latint, inputLongitude: longint, inputAltitude: altint)
            
            XCTAssert(testVariable.latitude == latint, "Random Data OK fail")
            XCTAssert(testVariable.longitude == longint, "Random Data OK fail")
            XCTAssert(testVariable.altitude == altint, "Random Data OK fail")
            
            
        }
        
        for i in 1...1000
        {
            latint = random64() &  0x0007ffffffffffff
            longint = random64() & 0x0007ffffffffffff
            altint = random64() &  0x00000007ffffffff
            
            testVariable=UNodeAddress(inputLatitude: latint, inputLongitude: longint, inputAltitude: altint)
            
            testlat = testVariable.latitude
            testlong = testVariable.longitude
            testalt = testVariable.altitude
            
            XCTAssert(testlat <=  0x0000ffffffffffff, "Random Data Out of range fail")
            XCTAssert(testlong <= 0x0000ffffffffffff, "Random Data Out of range fail")
            XCTAssert(testalt <=  0x00000000ffffffff, "Random Data Out of range fail")
            
            
        }
    }
}
