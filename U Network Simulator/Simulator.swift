//
//  Simulator.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/27/15.

//

import Foundation
import Cocoa


class UNetworkSimulator {
    
    
    
    
    var simulationNodes = [UNodeID:SimulationNode]()
    
    var wirelessMedium = MediumSimulatorForWireless()
    var internetMedium = MediumSimulatorForInternet()
    var ethernetMedium = MediumSimulatorArbitraryGroup()
    var bridgeMedium = MediumSimulatorArbitraryGroup()
    
    // current space bondaries
    
    var minLat=UInt64.max
    var maxLat=UInt64(0)
    var minLong=UInt64.max
    var maxLong=UInt64(0)
    var minAlt=UInt64.max
    var maxAlt=UInt64(0)
    
    
    
    
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
            
            node.setupAndStart()
            
            let simulationNode=SimulationNode(node:node, nodeConfiguration:configurationData)
            self.simulationNodes[node.id] = simulationNode
            
            
            
            // space bounds check and update if needed
            
            var spaceChanged = false
            
            if (node.address.latitude < minLat) { minLat = node.address.latitude;  spaceChanged = true}
            if (node.address.longitude < minLong) { minLong = node.address.longitude;  spaceChanged = true }
            if (node.address.altitude < minAlt) { minAlt = node.address.altitude;  spaceChanged = true }
            
            if (node.address.latitude > maxLat) { maxLat = node.address.latitude;  spaceChanged = true }
            if (node.address.longitude > maxLong) { maxLong = node.address.longitude;  spaceChanged = true }
            if (node.address.altitude > maxAlt) { maxAlt = node.address.altitude;  spaceChanged = true }
            
            // add to simulation view
            
            
            let appdel = NSApplication.sharedApplication().delegate as! AppDelegate
            
            if let visWindow = appdel.visualisationWindow?.window
            {
                if spaceChanged
                {
                    appdel.visualisationWindow?.refreshEverything()
                }
                else
                {
                    let newView = node.view(visWindow)
                    visWindow.contentView.addSubview(newView)
                }
            }
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
        
        for aNode in self.simulationNodes.values
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
        for  aNode in self.simulationNodes.values
        {
            if(aNode.node.id.isEqual(id))
            {
                return aNode.node.userName
            }
        }
        return "Unknown!"
    }
    
}

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



