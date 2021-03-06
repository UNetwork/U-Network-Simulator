//
//  Simulator.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/27/15.

//

import Foundation
import Cocoa


class UNetworkSimulator:NSObject
{
    
    var simulationNodes = [UNodeID:SimulationNode]()
    
    var simulationNodeIdCache = [UNodeID]()
    
    var wirelessMedium = MediumSimulatorForWireless()
    var internetMedium = MediumSimulatorForInternet()
    var ethernetMedium = MediumSimulatorArbitraryGroup()
    var bridgeMedium = MediumSimulatorArbitraryGroup()
    
    // current space bondaries maxLat: 143864997596557 minLat:143864988096557 maxLong: 143864997596557 minLong: 143864988096557
    
    
    var minLat=UInt64.max
    var maxLat=UInt64(0)
    var minLong=UInt64.max
    var maxLong=UInt64(0)
    var minAlt=UInt64.max
    var maxAlt=UInt64(0)
    
    // heartbeatloop
    
    var heartBeatTimer:NSTimer?
    
    
    
    
    override init(){
        super.init()
        
    }
    
    func addNodes(configurations:[SimulationNodeConfiguration])
    {
        
        for (_, configurationData) in configurations.enumerate()
        {
            let node=UNode()
            
            for (_, wirelessInterfaceConfiguration) in configurationData.simulationWirelessInterfeces.enumerate()
            {
                let wirelessInterface=UNetworkInterfaceSimulationWireless(node: node, location: wirelessInterfaceConfiguration.location)
                node.interfaces.append(wirelessInterface)
            }
            
            for (_, internetInterfaceConfiguration) in configurationData.simulationInternetInterfaces.enumerate()
            {
                let internetInterface=UNetworkInterfaceSimulationInternet(node: node, tCPAddress: internetInterfaceConfiguration.tCPIPAddress)
                node.interfaces.append(internetInterface)
            }
            
            for (_, ethernetInterfaceConfiguration) in configurationData.simulationEthernetInterfaces.enumerate()
            {
                let ethernetInterface=UNetworkInterfaceSimulationEthernet(node: node, hub: ethernetInterfaceConfiguration.hubNumber)
                node.interfaces.append(ethernetInterface)
            }
            
            for (_, bridgeInterfaceConfiguration) in configurationData.simulationBridgeInterfaces.enumerate()
            {
                let bridgeInterface=UNetworkInterfaceSimulationBridge(node: node, bridge: bridgeInterfaceConfiguration.bridgeNumber)
                node.interfaces.append(bridgeInterface)
            }
            
            node.setupAndStart()
            
            let simulationNode=SimulationNode(node:node, nodeConfiguration:configurationData)
            self.simulationNodes[node.id] = simulationNode
            self.simulationNodeIdCache.append(node.id)
            
            
            if (heartBeatTimer != nil )
            {
                heartBeatTimer!.invalidate()
                heartBeatTimer = nil
            }
            
            let timeInterval = 1 / Float64(simulationNodeIdCache.count)
            
            
            heartBeatTimer=NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("heartBeatLoop"), userInfo: nil, repeats: true)
            
            
            
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
            
            
            if let visWin = appdel.visualisationWindow
            {
                if spaceChanged
                {
                    visWin.refreshEverything()
                }
                else
                {
                    visWin.addNodeLayer(node.visualistaionLayer(visWin.window!.contentView!.layer!))
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
    
    func heartBeatLoop()
    {
        if simulationNodes.count > 0
        {
            let randomIndex = arc4random_uniform(UInt32(simulationNodeIdCache.count))
            let randomId=simulationNodeIdCache[Int(randomIndex)]
            
            if let choosenNode=simulationNodes[randomId]
            {
                choosenNode.node.heartBeat()
            }
        }
    }
    
    // open save data
    
    func openNodeMap()
    {
        
        let panel=NSOpenPanel()
        
        let panelhandler = panel.runModal()
        
        if (panelhandler==NSModalResponseOK)
        {
            
            let fileContent=NSArray(contentsOfURL: panel.URL!)

            log(7,text: "wireless in file: \(fileContent![0].count)")
            
            for index in 0 ..< fileContent![0].count
            {
                let lat = fileContent![0][index][0] as! NSNumber
                let long = fileContent![0][index][1] as! NSNumber
                let alt = fileContent![0][index][2] as! NSNumber
                
                let position = USimulationRealLocation(inputLatitude: lat.unsignedLongLongValue, inputLongitude: long.unsignedLongLongValue, inputAltitude: alt.unsignedLongLongValue)
                
                addWirelessNode(position)
                
                
            }
            
            
            
            
        }
        else if (panelhandler==NSModalResponseCancel)
        {
            
            return
        }

    }
    
    
    
    func saveCurrentNodeMap()
    {
        var dataForSave = [AnyObject]()

        let panel = NSSavePanel()
        let panelHandler = panel.runModal()
        if (panelHandler == NSModalResponseOK)
        {
            var wireless = [[NSNumber]]()
            var internets = [NSNumber]()    // :)
            var bridges = [NSNumber]()
            var ethernets = [NSNumber]()
            
            for simNode in simulationNodes.values
            {
                let configurationToSave = simNode.nodeConfiguration
                
                // array of 3 element nsnumber array
                // array of nsnumbers for tcpip
                // array of nsnumbers for bridge
                // array of nsnumbers for ethernet
                
                
                
                for (_, wirelessInterfaceConfiguration) in configurationToSave.simulationWirelessInterfeces.enumerate()
                {
                    
                    var nsposition = [NSNumber]()
                    
                    let lat = NSNumber(unsignedLongLong: wirelessInterfaceConfiguration.location.latitude)
                    nsposition.append(lat)
                    let long = NSNumber(unsignedLongLong: wirelessInterfaceConfiguration.location.longitude)
                    nsposition.append(long)
                    let alt = NSNumber(unsignedLongLong: wirelessInterfaceConfiguration.location.altitude)
                    nsposition.append(alt)
                    
                    wireless.append(nsposition)
                    
                    
                }
                
                for (_, internetInterfaceConfiguration) in configurationToSave.simulationInternetInterfaces.enumerate()
                {
                    internets.append(NSNumber(unsignedInt: internetInterfaceConfiguration.tCPIPAddress))
                }
                
                for (_, ethernetInterfaceConfiguration) in configurationToSave.simulationEthernetInterfaces.enumerate()
                {
                    ethernets.append(NSNumber(unsignedLong: ethernetInterfaceConfiguration.hubNumber))
                    
                }
                
                for (_, bridgeInterfaceConfiguration) in configurationToSave.simulationBridgeInterfaces.enumerate()
                {
                    bridges.append(NSNumber(unsignedLong: bridgeInterfaceConfiguration.bridgeNumber))
                }
                
                
            }
            var error:NSString?
            
            
            dataForSave.append(wireless)
            dataForSave.append(internets)
            dataForSave.append(ethernets)
            dataForSave.append(bridges)
            
            
            
            
            let plist = NSPropertyListSerialization.dataFromPropertyList(dataForSave, format:NSPropertyListFormat.XMLFormat_v1_0, errorDescription: &error)
            
            
            plist?.writeToURL(panel.URL!, atomically: true)
            
            //  currentFilePath=panel.URL
        }
        else if (panelHandler == NSModalResponseCancel)
        {
            return
        }
        
    }
    
    
    
    
    
    
    // Some god options
    
    func findNodeWithName(name:String) -> UNode?
    {
        var result:UNode?
        
        for aNode in self.simulationNodes.values
        {
            if(aNode.node.ownerName == name)
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
                return aNode.node.ownerName
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



