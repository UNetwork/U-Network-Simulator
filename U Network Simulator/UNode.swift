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
    var userName:String?                            // User name of node if defined
    var time:UInt64=0                               // Local "time"
    
    var interfaces=[UNetworkInterfaceProtocol]()    // Network interfaces
    var router:URouterProtocol!                     // Handler for router
    var peers = [UPeerDataRecord]()                 // Currently available connected nodes
    var knownAddresses = [UMemoryIdAddressRecord]() // Memory of search for address service
    var knownNames  = [UMemoryNameIdRecord]()       // Memory of search for name service
    
    var contacts = [UNodeContacts] ()               // Commonly contacted noods, contacts
    var apps = [UAppProtocol] ()                    // Handler for all "installed" apps
    
    
    // helper apps - node will work without them
    let nodeStats = UNAppNodeStats()
    let nodeCurrentState = UNAppNodeCurrentState()
    

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
            processDiscoveryBroadcast(interface, packet: packet)
        }
        else
        {
            if(packet.envelope.destinationUID.isEqual(self.id))
            {
                switch packet.packetCargo
                {
                case .ReceptionConfirmation(let _): router.getReply(interface, packet: packet) // this is router staff
                case .DiscoveryBroadcastReplay(let _): processDiscoveryBroadcastReplay(interface, packet: packet)
                case .ReplyForNetworkLookupRequest(let _): router.getReply(interface, packet: packet) // router staff
                case .SearchIdForName(let _): processSearchIdForName(interface, packet: packet)
                case .StoreIdForName(let _): processStoreIdForName(interface, packet: packet)
                case .SearchAddressForID(let _): processSearchAddressForID(interface, packet: packet)
                case .StoreAddressForId(let _): processStoreAddressForId(interface, packet:packet)
                case .ReplyForIdSearch(let _): processIdSearchResults(packet)
                case .ReplyForAddressSearch(let _) : processAddressSearchResults(packet)
                case .Ping(let _): processPing(packet)
                case .Pong(let _): processPong(packet)
                case .Data(let _): processData(packet)
                case .DataDeliveryConfirmation(let _): processDataDeliveryConfirmation(packet)
                default: log(7, "Unknown packet type???")
                }
            }
            else
            {
                processTrespassingPacket(interface, packet: packet)
            }
        }
    }
    
    
    // Trespassing packet processing
    
    func processTrespassingPacket(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        router.getPacketToRouteFromNode(packet)
    }
    
    
    
    // Packet processing
    
    func processDiscoveryBroadcast(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        // replay
        // if packet couter > 0 resend to all nodes. If packet counter>discovery limit >>> drop mtfker
        // check on peers list, add if needed
        
        
    }
    
    func processSearchIdForName(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        // check memory
        // replay if found
        // if not forward to peer
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
    
    




    
    
    
    
    
    
    
    
    func refreshPeers()
    {
        // assemble packet and deliver to all interfaces
    }
    
    func ping(uID:UNodeID, address:UNodeAddress)
    {
        
    }
    
 
    
    
    
    
}


