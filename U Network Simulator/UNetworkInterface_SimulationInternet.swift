//
//  UNetworkInterface_SimulationInternet.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/25/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Foundation

class UNetworkInterfaceSimulationInternet:UNetworkInterfaceProtocol {
    
    
    var node:UNode
    
    
    var tCPAddress:UInt32
    

    
    func getPacketFromNetwork(incomingPacket:UPacket)
    {
        node.getPacketFromInterface(self,packet: incomingPacket)
        
    }
    
    func sendPacketToNetwork(packetToSend:UPacket)
    {
        
    }
    
    
    init (node:UNode, tCPAddress:UInt32)
    {
        self.node=node
        self.tCPAddress=tCPAddress
    }
    
    
    
}