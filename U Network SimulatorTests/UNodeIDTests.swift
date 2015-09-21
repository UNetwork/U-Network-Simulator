//
//  UNodeIDTests.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/19/15.

//

import Cocoa
import XCTest

class UNodeIDTests: XCTestCase {


    
    func testUNodeID()
    {
        let testVariable1=UNodeID(lenght: 1)
        let testVariable1a=UNodeID(lenght: 1)
        let testVariable1c=testVariable1
        
        let testVariable2=UNodeID(lenght: 2)
        let testVariable2a=UNodeID(lenght: 2)
        let testVariable2c=testVariable2
        
        
        let testVariable3=UNodeID(lenght: 3)
        let testVariable3a=UNodeID(lenght: 3)
        let testVariable3c=testVariable3
        
        //FALSE
        XCTAssert(!testVariable1.isEqual(testVariable1a), "Equal function error")
        XCTAssert(!testVariable2.isEqual(testVariable2a), "Equal function error")
        XCTAssert(!testVariable3.isEqual(testVariable3a), "Equal function error")
        XCTAssert(!testVariable1.isEqual(testVariable2), "Equal function error")
        XCTAssert(!testVariable2.isEqual(testVariable3), "Equal function error")
        XCTAssert(!testVariable3.isEqual(testVariable1), "Equal function error")
        
        
        //TRUE
        XCTAssert(testVariable1.isEqual(testVariable1c), "Equal function error")
        XCTAssert(testVariable2.isEqual(testVariable2c), "Equal function error")
        XCTAssert(testVariable3.isEqual(testVariable3c), "Equal function error")
        
        // broadcast id testing
        let broadcatPacketId=UNodeID()

        XCTAssert(broadcatPacketId.isBroadcast(), "Broadcast not detected")
        XCTAssert(!testVariable1.isBroadcast(), "Broadcast false positive")
        XCTAssert(!testVariable1a.isBroadcast(), "Broadcast false positive")
        XCTAssert(!testVariable1c.isBroadcast(), "Broadcast false positive")
        XCTAssert(!testVariable2.isBroadcast(), "Broadcast false positive")
        XCTAssert(!testVariable2a.isBroadcast(), "Broadcast false positive")
        XCTAssert(!testVariable2c.isBroadcast(), "Broadcast false positive")
        XCTAssert(!testVariable3.isBroadcast(), "Broadcast false positive")
        XCTAssert(!testVariable3a.isBroadcast(), "Broadcast false positive")
        XCTAssert(!testVariable3c.isBroadcast(), "Broadcast false positive")
    }
}
