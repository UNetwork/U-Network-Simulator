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
        var testVariable1=UNodeID(lenght: 1)
        var testVariable1a=UNodeID(lenght: 1)
        var testVariable1c=testVariable1

        var testVariable2=UNodeID(lenght: 2)
        var testVariable2a=UNodeID(lenght: 2)
        var testVariable2c=testVariable2
        
        
        var testVariable3=UNodeID(lenght: 3)
        var testVariable3a=UNodeID(lenght: 3)
        var testVariable3c=testVariable3
        
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




    }
    

}
