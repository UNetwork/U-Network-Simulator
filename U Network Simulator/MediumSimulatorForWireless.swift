//
//  MediumSimulatorForWireless.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/24/15.
//

import Foundation
import Cocoa

class MediumSimulatorForWireless:MediumProtocol
{
    var interfacesInRangeCache = [UNodeID: [UNetworkInterfaceSimulationWireless]]()

    
    init()
    {
    }
    
    func getPacketFromInterface (interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        var wirelessInterface = interface as! UNetworkInterfaceSimulationWireless
        
        
        let appdel = NSApplication.sharedApplication().delegate as! AppDelegate
        
        
        var interfacesForDelivery = findInterfacesInRange(wirelessInterface)
        
        // deliver stright
        func deliverStright(){
            for (_, interfaceForDelivery) in interfacesForDelivery.enumerate()
            {
                
                if let visWindowController = appdel.visualisationWindow
                {
                    let toNodeId = interfaceForDelivery.node.id
                    visWindowController.showConnection(interface.node.id, toId: toNodeId, forWindow: visWindowController.window!, packet: packet)
                }
                
            }
        }
        
        
        // deliver serial
        func deliverSerial(){
            for (_, interfaceForDelivery) in interfacesForDelivery.enumerate()
            {
                
                dispatch_async(dispatch_get_main_queue(), {
                    if let visWindowController = appdel.visualisationWindow
                    {
                        let toNodeId = interfaceForDelivery.node.id
                        
                        if (packet.header.transmitedByUID.isBroadcast() || toNodeId.isEqual(packet.header.transmitedToUID))
                        {
                            
                            visWindowController.showConnection(interface.node.id, toId: toNodeId, forWindow: visWindowController.window!, packet: packet)
                        }
                    }
                    
                })

                
                
                
                dispatch_async(queueSerial, {
                    interfaceForDelivery.getPacketFromNetwork(packet)
                })
                
                
            }
        }
        
        // deliver paralel;
        func deliverpParalel(){
            for (_, interfaceForDelivery) in interfacesForDelivery.enumerate()
            {
                if let visWindowController = appdel.visualisationWindow
                {
                dispatch_async(dispatch_get_main_queue(), {
                 
                        let toNodeId = interfaceForDelivery.node.id
                        if (packet.header.transmitedByUID.isBroadcast() || toNodeId.isEqual(packet.header.transmitedToUID))
                        {
                            
                            visWindowController.showConnection(interface.node.id, toId: toNodeId, forWindow: visWindowController.window!, packet: packet)
                        }
                    
                })
                }
                
                dispatch_async(queueConcurrent, {
                    interfaceForDelivery.getPacketFromNetwork(packet)
                    
                    
                    
                })
                
            }
        }
        
        
        
        log(2, text: ">> \(packet.txt)")
        
        
 
        
        if(packet.header.transmitedToUID.isBroadcast())
        {
            for (_, interfaceForDelivery) in interfacesForDelivery.enumerate()
            {
                interfaceForDelivery.getPacketFromNetwork(packet)
            }
        }
        else
        {
            switch processingMode
            {
            case .Serial: deliverSerial()
            case .Stright: deliverStright()
            case .Paralel: deliverpParalel()
            default: log(7, text: "Wrong processing type")
            }
            
        }
        
        
        
        
        // visualisation
        
        
        
    }
    
    
    // ------------------- HELPER FUNCTIONS
    
    
    
    
    func findInterfacesInRange(interface:UNetworkInterfaceSimulationWireless) -> [UNetworkInterfaceSimulationWireless]
    {
        // check cache
        if useCache
        {
            
            if let resultsFromCache = checkCacheForNodeInterfaces(interface.node.id)
            {
                return resultsFromCache
            }
        }
        
        
        var result=[UNetworkInterfaceSimulationWireless]()
        
        // iterate over global list of nodes in simulator
        
        for  simulationNode in simulator.simulationNodes.values
        {
            for (_, interfaceToCheck) in simulationNode.node.interfaces.enumerate()
            {
                if let wirelessInterfaceToCheck = interfaceToCheck as? UNetworkInterfaceSimulationWireless
                {
                    if (checkIfWirelessInterfacesAreInRange(interface, interface2: wirelessInterfaceToCheck))
                    {
                        if (!(wirelessInterfaceToCheck === interface))
                        {
                            result.append(wirelessInterfaceToCheck)
                        }
                    }
                }
            }
        }
        
        // add results to cache
        if useCache
        {
            
            interfacesInRangeCache[interface.node.id] = result
        }
        return result
        
    }
    
    
    func checkIfWirelessInterfacesAreInRange(interface1:UNetworkInterfaceSimulationWireless, interface2:UNetworkInterfaceSimulationWireless) -> Bool
    {
        let location1=interface1.realLocation
        let location2=interface2.realLocation
        
        let latitudeDelta=unsignedDifference(location1.latitude, b: location2.latitude)
        let longitudeDelta=unsignedDifference(location1.longitude, b: location2.longitude)
        let altitudeDelta=unsignedDifference(location1.altitude, b: location2.altitude)
        
        
        // the "distance" check function :)
        if ((latitudeDelta + longitudeDelta + altitudeDelta) <  wirelessInterfaceRange )
        {
            return true
        }
        
        return false
    }
    
    func checkCacheForNodeInterfaces (nodeId:UNodeID) -> [UNetworkInterfaceSimulationWireless]?
        
    {
        return interfacesInRangeCache[nodeId]
    }
    
    
    
}





