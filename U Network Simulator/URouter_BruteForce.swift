//
//  URouter_BruteForce.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/21/15.
//

import Foundation

class URouter_BruteForceRouting:URouterProtocol {
    
    var node:UNode
    var packetStack=[BruteForcePacketStackRecord]()

    func getReply(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    func   getPacketToRouteFromNode(packet:UPacket)
    {
     // get peer list from node
        // pick any
        // 
    }
    
    init(node:UNode)
    {
        self.node=node
    }


}


struct BruteForcePacketStackRecord {
    
    var packet:UPacket
    
    
    
}