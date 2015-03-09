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
    var location:UNodeAddress?


    
    // Interface - specific
    
    var realLocation:USimulationRealLocation
    
    init (node:UNode, location:USimulationRealLocation)
    {
        self.node=node
        self.realLocation = location
        self.location = UNodeAddress(inputLatitude: location.latitude, inputLongitude: location.longitude, inputAltitude: location.altitude)
    }
    
    
    func getPacketFromNetwork(incomingPacket:UPacket)
        
    {
        // check packet integrity
        
        // is it to me
        if(incomingPacket.header.transmitedToUID.isEqual(node.id) || incomingPacket.header.transmitedToUID.isBroadcast()){
        
        node.getPacketFromInterface(self, packet: incomingPacket)
        }
        else
        {
            // drop packet add hook to stats app
        }
    }
    
    
    func sendPacketToNetwork(packetToSend:UPacket)
    {
        simulator.wirelessMedium.getPacketFromInterface(self, packet:packetToSend)
    }
    
    

    
    
}