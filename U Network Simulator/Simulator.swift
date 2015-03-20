//
//  Simulator.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/27/15.

//

import Foundation


class UNetworkSimulator {
    
    var simulationNodes = [SimulationNode]()
    
    var wirelessMedium = MediumSimulatorForWireless()
    var internetMedium = MediumSimulatorForInternet()
    var ethernetMedium = MediumSimulatorArbitraryGroup()
    var bridgeMedium = MediumSimulatorArbitraryGroup()

    init(){}
    
    func addNodes(configurations:[SimulationNodeConfiguration])
    {
        
        for (index, configurationData) in enumerate(configurations)
        {
        var node=UNode()
            
           for (index, wirelessInterfaceConfiguration) in enumerate(configurationData.simulationWirelessInterfeces)
           {
            var wirelessInterface=UNetworkInterfaceSimulationWireless(node: node, location: wirelessInterfaceConfiguration.location)
            node.interfaces.append(wirelessInterface)
            }
            
            for (index, internetInterfaceConfiguration) in enumerate(configurationData.simulationInternetInterfaces)
            {
                var internetInterface=UNetworkInterfaceSimulationInternet(node: node, tCPAddress: internetInterfaceConfiguration.tCPIPAddress)
                node.interfaces.append(internetInterface)
            }
            
            for (index, ethernetInterfaceConfiguration) in enumerate(configurationData.simulationEthernetInterfaces)
            {
                var ethernetInterface=UNetworkInterfaceSimulationEthernet(node: node, hub: ethernetInterfaceConfiguration.hubNumber)
                node.interfaces.append(ethernetInterface)
            }
            
            for (index, bridgeInterfaceConfiguration) in enumerate(configurationData.simulationBridgeInterfaces)
            {
                var bridgeInterface=UNetworkInterfaceSimulationBridge(node: node, bridge: bridgeInterfaceConfiguration.bridgeNumber)
                node.interfaces.append(bridgeInterface)
            }
            
            let simulationNode=SimulationNode(node:node, nodeConfiguration:configurationData)
            self.simulationNodes.append(simulationNode)
        }

    }
    
    func addWirelessNode(wirelessInterfaceLocation:USimulationRealLocation)
    {
        var configuration=SimulationNodeConfiguration()
        configuration.simulationWirelessInterfeces.append(InterfaceSimulationWirelessConfiguration(location: wirelessInterfaceLocation))
        
        var configurations=[SimulationNodeConfiguration]()
        configurations.append(configuration)
        
        self.addNodes(configurations)

    }
    // Some god options
    
    func findNodeWithName(name:String) -> UNode?
    {
        var result:UNode?
        
        for (_, aNode) in enumerate(self.simulationNodes)
        {
            if(aNode.node.userName == name)
            {
                result = aNode.node
                break
            }
        }
        
        return result
    }
    
    func findNameForId(id:UNodeID) -> String
    {
        for (_, aNode) in enumerate(self.simulationNodes)
        {
            if(aNode.node.id.isEqual(id))
            {
                return aNode.node.userName
            }
        }
        return "Unknown!"
    }
    
}



