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
    
    func getReceptionConfirmation(interface:UNetworkInterfaceProtocol, packet:UPacket)
    
    func getReplyForNetworkLookupRequest(interface:UNetworkInterfaceProtocol, packet:UPacket)

    // This function is called by Node to process the tresspassing packet
    func getPacketToRouteFromNode(interface:UNetworkInterfaceProtocol, packet:UPacket)
    
    func getPacketToRouteFromNode(envelope:UPacketEnvelope, cargo:UPacketType)
    
    func sendPacketDeliveryConfirmation(interface:UNetworkInterfaceProtocol, packet:UPacket, rejected:Bool)

    
    func reset()
        
    func maintenanceLoop()
    
    // for access to stack on runtime
    
     func status() -> [(String, String, String, String, String)]
    
}