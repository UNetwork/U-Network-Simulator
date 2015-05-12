//
//  Constants Definitions.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/20/15.
//

import Foundation


// Parameters - to be eliminated

var uIDlengh:Int=2

var standardPacketLifeTime:UInt32 = 2048

var maxDiscoveryBroadcastDeepth:Int = 5

var defaultStoreSearchDepth:UInt32 = 32

var logLevel:Int=3

var delayInPacketResend:Int = 2

var sendDroppedPackets = false


// Simulation - to be elimineted

var wirelessInterfaceRange = UInt64(1000_000)



// aliases

let broadcastNodeId=UNodeID()

let unknownNodeAddress = UNodeAddress()

 typealias CurrentRouter = URouterSimpleDirection

// typealias CurrentRouter = URouter_BruteForceRouting










