//
//  UNAppPing.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/10/15.
//

import Foundation

class UNAppPing
{
    
    let node:UNode
    
    var sentPingSerialTable=[UInt64]()
    
    init (node:UNode)
    {
        self.node=node
    }
    
    func sendPing(uID:UNodeID, address:UNodeAddress)
    {
        let pingEnvelope = UPacketEnvelope(fromId: self.node.id, fromAddress: self.node.address, toId: uID, toAddress: address)
        let pingCargo = UPacketPing()
        let pingPacketCargo=UPacketType.Ping(pingCargo)
        
        self.sentPingSerialTable.append(pingCargo.serial)
        node.nodeStats.addNodeStatsEvent(StatsEvents.PingSent)
        
        node.router.getPacketToRouteFromNode(pingEnvelope, cargo: pingPacketCargo)
    }
    
    func recievedPong(serial:UInt64)
    {
        if(findSerialInSentPingTable(serial))
        {
            
            // ok
            node.nodeStats.addNodeStatsEvent(StatsEvents.PingHadAPongWithProperSerial)
        }
        else
        {
            node.nodeStats.addNodeStatsEvent(StatsEvents.PongSerialError)
            // wrong serial
        }
    }
    
    func findSerialInSentPingTable(serial:UInt64) -> Bool
    {
        for(_, serialFromTable) in enumerate(sentPingSerialTable)
        {
            if(serialFromTable == serial)
            {
                return true
            }
        }
        return false
    }
    
}