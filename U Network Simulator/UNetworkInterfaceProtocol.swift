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
    var node:UNode {get}
    
    var location:UNodeAddress? {get}

    func getPacketFromNetwork(incomingPacket:UPacket)
    
    func sendPacketToNetwork(packetToSend:UPacket)
    
    
}