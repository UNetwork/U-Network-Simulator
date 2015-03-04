//
//  UPacketCargo.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/28/15.

//

import Foundation

struct UPacketData {
    var envelope:UPacketEnvelope
    var load = [UInt64]()
}