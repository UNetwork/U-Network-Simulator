//
//  UNode.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/19/15.
//

import Foundation

/*
This is basic class of the U Network. U Node communicates with interfaces to the networks.
Node has a router responsible for choosing the next currently connected node (peer)
to transmit the trespassing packet. Node is servicing user application with U Network Services.
*/

class UNode {
    
    
    let id:UNodeID                                  // Unique Id
    var address:UNodeAddress?                       // Current Address - geographical position
    var time:UInt64 = 0                             // Local "time"
    
    var interfaces=[UNetworkInterfaceProtocol]()    // Array of network interfaces
    var router:URouterProtocol!                     // Handler for router
    var peers = [UPeerDataRecord]()                 // Currently available connected nodes
    var knownAddresses = [UMemoryIdAddressRecord]() // Memory of search for address service
    var knownNames  = [UMemoryNameIdRecord]()       // Memory of search for name service
    
    var contacts = [UNodeContacts] ()               // Commonly contacted noods, contacts

    //  Init
    
    init ()
    {
        id=UNodeID(lenght: uIDlengh)
        router = CurrentRouter(node:self)
    }
 
    func getPacketFromInterface(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        if(packet.header.transmitedToUID.isBroadcast())
        {
            processBroadcastPacket(interface, packet: packet)
        }
        else
        {
            processRegularPacket(interface, packet: packet)
        }
    }
    

    
    func processBroadcastPacket(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        switch packet.packetCargo
        {
        case .DiscoveryBroadcast(let _): processDiscoveryBroadcast(interface, packet: packet)
        case .SearchIdForName(let _): processSearchIdForName(interface, packet: packet)
        case .StoreIdForName(let _): processStoreIdForName(interface, packet: packet)
        case .SearchAddressForID(let _): processSearchAddressForID(interface, packet: packet)
        case .StoreAddressForId(let _): processStoreAddressForId(interface, packet:packet)
        default: errorInPacketProcessing("Wrong broadcast packet type", packet: packet)
        }
    }
    
    func processRegularPacket(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        switch packet.packetCargo
        {
        case .ReceptionConfirmation(let receptionConfirmationCargo) where receptionConfirmationCargo.envelope.destinationUID.isEqual(self.id): router.getReply(interface, packet: packet) // this is router staff
        case .DiscoveryBroadcastReplay(let discoveryBroadcastCargo) where discoveryBroadcastCargo.envelope.destinationUID.isEqual(self.id): processDiscoveryBroadcastReplay(interface, packet: packet)
        case .ReplyForNetworkLookupRequest(let replayForNLRCargo) where replayForNLRCargo.envelope.destinationUID.isEqual(self.id): router.getReply(interface, packet: packet) // router staff
        case .ReplyForIdSearch(let replayForIdSearchCargo) where replayForIdSearchCargo.envelope.destinationUID.isEqual(self.id): processIdSearchResults(packet)
        case .ReplyForAddressSearch(let replayForAddressSearchCargo) where replayForAddressSearchCargo.envelope.destinationUID.isEqual(self.id): processAddressSearchResults(packet)
        case .Ping(let pingCargo) where pingCargo.envelope.destinationUID.isEqual(self.id): processPing(packet)
        case .Pong(let pongCargo) where pongCargo.envelope.destinationUID.isEqual(self.id): processPong(packet)
        case .Data(let dataCargo) where dataCargo.envelope.destinationUID.isEqual(self.id): processData(packet)
        case .DataDeliveryConfirmation(let dataDeliveryConfirmationCargo) where dataDeliveryConfirmationCargo.envelope.destinationUID.isEqual(self.id): processDataDeliveryConfirmation(packet)
            
            
            
        default: processTrespassingPacket(interface, packet:packet)
            
        }
    }
    
    // Broadcast packet processing
    
    func processDiscoveryBroadcast(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    func processSearchIdForName(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    func processStoreIdForName(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    
    func processSearchAddressForID(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    func processStoreAddressForId(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    // Regular packet processing
    
    func processDiscoveryBroadcastReplay(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
    }
    
    func processIdSearchResults(packet:UPacket)
    {
        
    }
    
    func processAddressSearchResults(packet:UPacket)
    {
        
    }
    
    func processPing(packet:UPacket)
    {
        
    }
    
    func processPong(packet:UPacket)
    {
        
    }
    
    func processData(packet:UPacket)
    {
        
    }
    
    func processDataDeliveryConfirmation(packet:UPacket)
    {
        
    }
    
    


    // Trespassing packet processing
    
    func processTrespassingPacket(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        router.getPacketToRouteFromNode(packet)
    }
    
    
    // Error handling
    func errorInPacketProcessing (message:String, packet:UPacket)
    {
     
        log(7,message)
        
    }
    
    
    
    
    
    
    
    
    func refreshPeers()
    {
        // assemble packet and deliver to all interfaces
    }
    
    func ping(uID:UNodeID, address:UNodeAddress)
    {
        
    }
    
 
    
    
    
    
}


