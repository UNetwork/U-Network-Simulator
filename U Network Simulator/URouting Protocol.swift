//
//  URouting Protocol.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/21/15.
//

import Foundation

/*
Router is responsible for getting a packet form the node, selecting peer for transmission (and the interface).
After assembling the packet the router calls
sendPacketToNetwork(packetToSend:UPacket) method of the interface on witch selected peer is available.
Router is responsible for holding the packet until is sure that it is successfully delivered to another peer.
*/


protocol URouterProtocol
{
    var node:UNode {get}
    
    func getReply(interface:UNetworkInterfaceProtocol, packet:UPacket)

    func   getPacketToRouteFromNode(packet:UPacket)
}