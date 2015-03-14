//
//  UStoreAndSearch.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/13/15.
//

import Foundation

protocol UStoreAndSearchRoutingProtocol
{
    var node:UNode {get}
    func getStoreOrSearchPacket(packet:UPacket)
    
    func storeName(depth:UInt32)
    
    func storeAddress()
}