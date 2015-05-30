//
//  UPingTests.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/10/15.
//

import Cocoa
import XCTest

class UPingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        simulator=UNetworkSimulator()
        AppDelegate.sharedInstance.logClearText()
        logLevel = 3
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        println(AppDelegate.sharedInstance.logText)
        let stats=simulationStats()
        
        println(stats.text)
        
        let pingSent = stats.values[StatsEvents.PingSent.rawValue]
        let pingReceived = stats.values[StatsEvents.PingReceived.rawValue]
        let pongReceived = stats.values[StatsEvents.PongReceived.rawValue]
        let returned = stats.values[StatsEvents.PacketReturnedToSender.rawValue]
        let dropped = stats.values[StatsEvents.PacketDropped.rawValue]


        XCTAssert(pingReceived == pongReceived, "ping or pong lost")

        
        

    }
    
    func testPingSimple()
    {
        logLevel = 2

        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: exampleNodeAddress.latitude, inputLongitude: exampleNodeAddress.longitude, inputAltitude: exampleNodeAddress.altitude))
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: closeToExampleNodeAddress.latitude, inputLongitude: closeToExampleNodeAddress.longitude, inputAltitude: closeToExampleNodeAddress.altitude))
        
       
    }
    
    func testPingMedium()
    {
        logLevel = 2

        
        // network size
        
        let k:UInt32 = 4
        let i:UInt32 = 1
        let j:UInt32 = 1
        
        // distance between nodes
        
        let distance:UInt64=570
        
    //    createNodeMesh(k, i, j, distance, exampleNodeAddress, false)
        
        sleep(1)
           }
    
    func testPingHard()
    {
        // network size
        logLevel = 4

        
        let k:UInt32 = 30
        let i:UInt32 = 30
        let j:UInt32 = 5
        
        // distance between nodes
        
        let distance:UInt64=600
        
        processingMode = ProcessingType.Serial
        
        let delay = k*i*j/80
        
   //     createNodeMesh(k, i, j, distance, exampleNodeAddress, true)
        log(5, "entering  \(delay) nap during initialisation ")

       // sleep(delay)
        log(5, "slepinig while netwoek setup in ping testing FINISHED")
        logLevel = 4
  
        let numberOfNodes=simulator.simulationNodes.count
        let repetitions = 100
        
        processingMode = ProcessingType.Serial
        useCache = true

        for i in 1...repetitions
            
            
        {
            
                   }
        
        
log(5,"loop finished entering nap")
        
        sleep(25) // this must be adjusted to pass test on brute force routing to about k*i*j/12
        
/*
        XCTAssert(firstNode.nodeStats.nodeStats[StatsEvents.PingHadAPongWithProperSerial.rawValue] == 1, "no pong")
        XCTAssert(lastNode.nodeStats.nodeStats[StatsEvents.PingHadAPongWithProperSerial.rawValue] == 1, "no pong")

*/
    }
}
