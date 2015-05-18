//
//  UNetworkInterfaceProtocol.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/22/15.
//

/*
The network interface sends and receives packets from the medium.
*/

import Foundation

protocol UNetworkInterfaceProtocol
{
    // The UNode of the Interface
    var node:UNode {get}
    
    var location:UNodeAddress? {get}
    
    // This function is called by a Medium object if a packet arrives to the interface
    func getPacketFromNetwork(incomingPacket:UPacket)
    
    // This function is called by Router or Node to transmit the packet to the network
    func sendPacketToNetwork(packetToSend:UPacket)
}