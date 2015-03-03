//
//  UNetworkInterface_SimulationWireless.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/21/15.
//

import Foundation

class UNetworkInterfaceSimulationWireless:UNetworkInterfaceProtocol
{
    // Protocol
    var node:UNode

    
    // Interface - specific
    
    var realLocation:USimulationRealLocation
    
    init (node:UNode, location:USimulationRealLocation)
    {
        self.node=node
        self.realLocation = location
    }
    
    
    func getPacketFromNetwork(incomingPacket:UPacket)
        
    {
        // check packet integrity
        // header check for broadcast and target?
        
        node.getPacketFromInterface(self, packet: incomingPacket)
    }
    
    
    func sendPacketToNetwork(packetToSend:UPacket)
    {
        simulator.wirelessMedium.getPacketFromInterface(self, packet:packetToSend)
    }
    
    

    
    
}