//
//  UNetworkInterface_SimulationEthernet.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/27/15.
//

import Foundation

class UNetworkInterfaceSimulationEthernet:UNetworkInterfaceProtocol {
    
    
    var node:UNode
    
    
    var hub:UInt
    

    
    func getPacketFromNetwork(incomingPacket:UPacket)
    {
        node.getPacketFromInterface(self,packet: incomingPacket)
        
    }
    
    func sendPacketToNetwork(packetToSend:UPacket)
    {
        
    }
    
    
    init (node:UNode, hub:UInt)
    {
        self.node=node

        
        self.hub=hub
    }
    
}