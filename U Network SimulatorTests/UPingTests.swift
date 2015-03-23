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
        AppDelegate.sharedInstance.logClearText("")
        AppDelegate.sharedInstance.logLevel = 3
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        println(AppDelegate.sharedInstance.logText)
        let stats=simulationStats()
        
        println(stats.text)
        
        let pingSent = stats.values[StatsEvents.PingSent.rawValue]
        let pingRecieved = stats.values[StatsEvents.PingRecieved.rawValue]
        let pongRecieved = stats.values[StatsEvents.PongRecieved.rawValue]
        let returned = stats.values[StatsEvents.PacketReturnedToSender.rawValue]
        let dropped = stats.values[StatsEvents.PacketDropped.rawValue]


        XCTAssert(pingSent - returned - dropped == pingRecieved && pingRecieved == pongRecieved, "ping or pong lost")

        
        

    }
    
    func testPingSimple()
    {
        AppDelegate.sharedInstance.logLevel = 2

        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: exampleNodeAddress.latitude, inputLongitude: exampleNodeAddress.longitude, inputAltitude: exampleNodeAddress.altitude))
        
        simulator.addWirelessNode(USimulationRealLocation(inputLatitude: closeToExampleNodeAddress.latitude, inputLongitude: closeToExampleNodeAddress.longitude, inputAltitude: closeToExampleNodeAddress.altitude))
        
        simulator.simulationNodes[0].node.setupAndStart()
        simulator.simulationNodes[1].node.setupAndStart()
        
        sleep(1)
        let firstNode=simulator.simulationNodes[0].node
        let lastNode=simulator.simulationNodes[simulator.simulationNodes.count - 1].node
        firstNode.pingApp.sendPing(lastNode.id, address: lastNode.address)
        sleep(1)

        
        XCTAssert(firstNode.nodeStats.nodeStats[StatsEvents.PingHadAPongWithProperSerial.rawValue] == 1, "no pong")

    }
    
    func testPingMedium()
    {
        AppDelegate.sharedInstance.logLevel = 2

        
        // network size
        
        let k:UInt32 = 4
        let i:UInt32 = 1
        let j:UInt32 = 1
        
        // distance between nodes
        
        let distance:UInt64=570
        
        createNodeMesh(k, i, j, distance, exampleNodeAddress, false)
        
        sleep(1)
        
        
        
        let firstNode=simulator.simulationNodes[0].node
        let lastNode=simulator.simulationNodes[simulator.simulationNodes.count - 1].node
        
        firstNode.pingApp.sendPing(lastNode.id, address: lastNode.address)
    //    lastNode.pingApp.sendPing(firstNode.id, address: firstNode.address)
        
        sleep(1) // this must be adjusted to pass test on brute force routing to about k*i*j/12
        
        
        XCTAssert(firstNode.nodeStats.nodeStats[StatsEvents.PingHadAPongWithProperSerial.rawValue] == 1, "no pong")
      //  XCTAssert(lastNode.nodeStats.nodeStats[StatsEvents.PingHadAPongWithProperSerial.rawValue] == 1, "no pong")
    }
    
    func testPingHard()
    {
        // network size
        AppDelegate.sharedInstance.logLevel = 3

        
        let k:UInt32 = 30
        let i:UInt32 = 30
        let j:UInt32 = 5
        
        // distance between nodes
        
        let distance:UInt64=600
        
        processingMode = ProcessingType.Serial
        
        let delay = k*i*j/80
        
        createNodeMesh(k, i, j, distance, exampleNodeAddress, true)
        log(5, "entering  \(delay) nap during initialisation ")

       // sleep(delay)
        log(5, "slepinig while netwoek setup in ping testing FINISHED")
        AppDelegate.sharedInstance.logLevel = 4
  
        let numberOfNodes=simulator.simulationNodes.count
        let repetitions = 1000
        
        processingMode = ProcessingType.Serial
        useCache = true

        for i in 1...repetitions
            
            
        {
            
            var index = Int (arc4random_uniform(UInt32(numberOfNodes)))
            let nodeOne = simulator.simulationNodes[index].node
            index = Int (arc4random_uniform(UInt32(numberOfNodes)))
            let nodeTwo = simulator.simulationNodes[index].node
            
            nodeOne.pingApp.sendPing(nodeTwo.id, address: nodeTwo.address)
        }
        
        
log(5,"loop finished entering nap")
        
        sleep(450) // this must be adjusted to pass test on brute force routing to about k*i*j/12
        
/*
        XCTAssert(firstNode.nodeStats.nodeStats[StatsEvents.PingHadAPongWithProperSerial.rawValue] == 1, "no pong")
        XCTAssert(lastNode.nodeStats.nodeStats[StatsEvents.PingHadAPongWithProperSerial.rawValue] == 1, "no pong")

*/
    }
}
