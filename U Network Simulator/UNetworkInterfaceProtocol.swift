//
//  UNetworkInterfaceProtocol.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/22/15.
//

import Foundation

protocol UNetworkInterfaceProtocol
{
    var node:UNode {get}
    
    

    


    func getPacketFromNetwork(incomingPacket:UPacket)
    
    func sendPacketToNetwork(packetToSend:UPacket)
    
    
}