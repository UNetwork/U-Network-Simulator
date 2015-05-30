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
    // Router's Node
    var node:UNode {get}
    
    // This function is called when confirmation of the packet reception is received by node
    func getReceptionConfirmation(interface:UNetworkInterfaceProtocol, packet:UPacket)
    
    // This function processes the anwser for NetworkLookupRequwst attached to an tresspasing packet
    func getReplyForNetworkLookupRequest(interface:UNetworkInterfaceProtocol, packet:UPacket)

    // This function is called by Node to process the tresspassing packet
    func getPacketToRouteFromNode(interface:UNetworkInterfaceProtocol, packet:UPacket)
    
    // this function is called if new packet is send. There is no packet header - it is assembeld by the function
    func getPacketToRouteFromNode(envelope:UPacketEnvelope, cargo:UPacketType)
    
    // This function confirms the reception and sucessfull procrssing of a packet. It send a Reception confirmation.
    // If rejected is true, sender must send packet to other node
    func sendPacketDeliveryConfirmation(interface:UNetworkInterfaceProtocol, packet:UPacket, rejected:Bool)

    // Delete all stack and data
    func reset()
    
    // This function must be called periodicaly to allow router maitenence and packet resend if necessery
    func maintenanceLoop()
    
    // for access to stack on runtime
     func status() -> [(String, String, String, String, String)]
    
}