//
//  Simulation Constants and Global Objects.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/21/15.
//

import Foundation



 var simulator=UNetworkSimulator()


struct SimulationNode {
    var node:UNode
    var nodeConfiguration:SimulationNodeConfiguration
}


struct SimulationNodeConfiguration {
    var simulationWirelessInterfeces=[InterfaceSimulationWirelessConfiguration]()
    var simulationInternetInterfaces=[InterfaceSimulationInternetConfiguration]()
    var simulationEthernetInterfaces=[InterfaceSimulationEthernetConfiguration]()
    var simulationBridgeInterfaces=[InterfaceSimulationBridgeConfiguration]()
    
}



struct InterfaceSimulationWirelessConfiguration
{
    var location:USimulationRealLocation
}

struct InterfaceSimulationInternetConfiguration
{
    var tCPIPAddress:UInt32
}

struct InterfaceSimulationEthernetConfiguration
{
    var hubNumber:UInt
    
}

struct InterfaceSimulationBridgeConfiguration
{
    var bridgeNumber:UInt
}
