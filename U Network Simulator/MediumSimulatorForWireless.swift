//
//  MediumSimulatorForWireless.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/24/15.
//

import Foundation

let range=UInt64(1000000)

class MediumSimulatorForWireless:MediumProtocol
{
    init()
    {
    }
   
    func getPacketFromInterface (interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
        var wirelessInterface = interface as! UNetworkInterfaceSimulationWireless
        
        // find wireless interfaces in range
        var interfacesForDelivery = findInterfacesInRange(wirelessInterface)
     
        // deliver
        for (_, interfaceForDelivery) in enumerate(interfacesForDelivery)
        {
            interfaceForDelivery.getPacketFromNetwork(packet)
        }

    }
    
    
    // ------------------- HELPER FUNCTIONS
    
    
    
    
    func findInterfacesInRange(interface:UNetworkInterfaceSimulationWireless) -> [UNetworkInterfaceSimulationWireless]
    {
        var result=[UNetworkInterfaceSimulationWireless]()
        
        // iterate over global list of nodes in simulator
        
        for (_, simulationNode) in enumerate(simulator.simulationNodes)
        {
            for (_, interfaceToCheck) in enumerate(simulationNode.node.interfaces)
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
        return result
    }
    
    
    func checkIfWirelessInterfacesAreInRange(interface1:UNetworkInterfaceSimulationWireless, interface2:UNetworkInterfaceSimulationWireless) -> Bool
    {
        let location1=interface1.realLocation
        let location2=interface2.realLocation
        
        let latitudeDelta=unsignedDifference(location1.latitude, location2.latitude)
        let longitudeDelta=unsignedDifference(location1.longitude, location2.longitude)
        let altitudeDelta=unsignedDifference(location1.altitude, location2.altitude)
        
        
        // the "distance" check function :)
        if ((latitudeDelta + longitudeDelta + altitudeDelta) < range)
        {
            return true
        }
        
        return false
    }
    
    
    

}




