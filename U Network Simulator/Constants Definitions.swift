//
//  Constants Definitions.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/20/15.
//

import Foundation


// Parameters - to be eliminated

let uIDlengh:Int=2

let standardPacketLifeTime:UInt32 = 512

let maxDiscoveryBroadcastDeepth:Int = 5

var defaultStoreSearchDepth:UInt32 = 32

var logLevel:Int=3



// Simulation - to be elimineted

let wirelessInterfaceRange = UInt64(100_000_000_000)



// aliases

let broadcastNodeId=UNodeID()

let unknownNodeAddress = UNodeAddress()

 typealias CurrentRouter = URouterSimpleDirection

// typealias CurrentRouter = URouter_BruteForceRouting







