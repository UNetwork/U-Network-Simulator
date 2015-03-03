//
//  UAppProtocol.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/3/15.
//

import Foundation

// this protocol must be implemented by app to run on node


protocol UAppProtocol
{
    var appID:UInt64 {get}
    func start()
    func getPacket(from:UNodeID, data:[UInt64])
}