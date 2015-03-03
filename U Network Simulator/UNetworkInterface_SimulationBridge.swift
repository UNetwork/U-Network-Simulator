//
//  UNetworkInterface_SimulationBridge.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/27/15.
//

import Foundation

class UNetworkInterfaceSimulationBridge: UNetworkInterfaceProtocol {
    
    var node:UNode
    
    
    var bridge:UInt
    
    func getPacketFromNetwork(incomingPacket:UPacket)
    {
        node.getPacketFromInterface(self,packet: incomingPacket)
        
    }
    
    func sendPacketToNetwork(packetToSend:UPacket)
    {
        
    }
    
    
    init (node:UNode, bridge:UInt)
    {
        self.node=node

        
        self.bridge=bridge
    }
}