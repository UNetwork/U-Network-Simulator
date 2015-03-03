//
//  URouting Protocol.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/21/15.
//

import Foundation

protocol URouterProtocol
{
   
    var node:UNode {get}
    func   getPacketToRouteFromNode(packet:UPacket)



}