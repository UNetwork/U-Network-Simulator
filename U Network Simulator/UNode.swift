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
    var address:UNodeAddress                       // Current Address - geographical position
    var userName:String                            // User name of node if defined
    var time:UInt64=0                               // Local "time"
    
    var interfaces=[UNetworkInterfaceProtocol]()    // Network interfaces
    var router:URouterProtocol!                     // Handler for router
    var peers = [UPeerDataRecord]()                 // Currently available connected nodes
    var knownAddresses = [UMemoryIdAddressRecord]() // Memory of search for address service
    var knownNames  = [UMemoryNameIdRecord]()       // Memory of search for name service
    
    var contacts = [UNodeContacts] ()               // Commonly contacted noods, contacts
    var apps = [UAppProtocol] ()                    // Handler for all "installed" apps
    
    
    //Node apps required
    
 var pingApp:UNAppPing!
    
    
    // helper apps - node will work without them
    let nodeStats = UNAppNodeStats()
    let nodeCurrentState = UNAppNodeCurrentState()
    

    //  Init
    
    init ()
    {
        id=UNodeID(lenght: uIDlengh)
        userName = randomUserName(32)
        address = unknownNodeAddress
        
        
        // start node apps
        
  //      pingApp=UNAppPing(node:self)

        
    }
    
    func setupAndStart()
    {
        // setup router
        router = CurrentRouter(node:self)
        
        //set up node apps
        pingApp = UNAppPing(node: self)

        // find addres on interfaces
        for (_, interface) in enumerate(self.interfaces)
        {
            if let interfacePosition=interface.location
            {
                self.address=interfacePosition
                break
                // we take first avaliable location form interface
            }
        }
        refreshPeers()
        
        // if failed to find address in interfaces take the avarge address from peers

        
        if(self.address.isUnknown)
        {
            findAddressFromConnectedPeers()
        }
        
        
        
        // start apps
        
        
        
        
        
        
        
        // set up node maintenance loop
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
                case .ReceptionConfirmation(let _): router.getReceptionConfirmation(interface, packet: packet) // this is router staff
                case .ReplyForDiscovery(let _): processDiscoveryBroadcastReplay(interface, packet: packet)
                case .ReplyForNetworkLookupRequest(let _): router.getReplyForNetworkLookupRequest(interface, packet: packet) // router staff - future implementation for another sense of neighberhood
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
        router.getPacketToRouteFromNode(interface, packet:packet)
        nodeStats.addNodeStatsEvent(StatsEvents.TrespassingPacketProcessedByNode)  // STATS
    }
    
    
    
    // Packet processing
    
    func processDiscoveryBroadcast(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        // replay
        
        let replayPacketHeader = UPacketHeader(from: self.id, to: packet.envelope.orginatedByUID, lifeTime: standardPacketLifeTime)
        var replayEnvelope = UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: packet.envelope.orginatedByUID, toAddress: packet.envelope.originAddress)
  
        var replayForDiscovery=UPacketyReplyForDiscovery()
        var replayCargo = UPacketType.ReplyForDiscovery(replayForDiscovery)
        var replayPacket=UPacket(inputHeader: replayPacketHeader, inputEnvelope: replayEnvelope, inputCargo: replayCargo)
        
        interface.sendPacketToNetwork(replayPacket)
        
     //   router.getPacketToRouteFromNode(nil, packet:replayPacket) // - we cannot do it here becouse the sender may be not on our peer list yet
        nodeStats.addNodeStatsEvent(StatsEvents.DiscoveryBroadcastPacketProcessed)
        
        
        
        // if packet couter > 0 resend to all nodes. If packet counter>discovery limit >>> drop mtfker
        // check on peers list, add if needed
        
        
    }
    
    func processDiscoveryBroadcastReplay(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        // check if replayer is already on peers list, add if not

        if let peerIndex = findInPeers(packet.header.transmitedByUID)
        {
            // update data
        }
        else
        {
            let newPeerRecord=UPeerDataRecord(nodeId:packet.header.transmitedByUID, address:packet.envelope.originAddress, interface:interface)
            self.peers.append(newPeerRecord)
            
        }
        
    }
    
    
    
    
    func processSearchIdForName(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        // check memory
        // replay if found
        // if not forward to peer
        nodeStats.addNodeStatsEvent(StatsEvents.SearchIdForNameProcessed)
    }
    
    func processStoreIdForName(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.StoreIdForNameProcessed)
    }
    
    
    func processSearchAddressForID(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.SearchAddressForIdProcessed)
    }
    
    func processStoreAddressForId(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.StoreAddressForIdProcessed)
    }
    
    

    func processIdSearchResults(packet:UPacket)
    {
     nodeStats.addNodeStatsEvent(StatsEvents.IdSearchResultRecieved)
    }
    
    func processAddressSearchResults(packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.AddressSearchResultRecieved)
    }
    
    func processPing(packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.PingRecieved)

        let envelope = UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: packet.envelope.orginatedByUID, toAddress: packet.envelope.originAddress)
        var pingSerial:UInt64 = 0
        switch packet.packetCargo
        {
        case .Ping(let pingPacketCargo): pingSerial=pingPacketCargo.serial
        default: log(7, "Ping packet is not PING!")
        }
        let pongCargo=UPacketPong(serialOfPing: pingSerial)
        let pongPacketCargo=UPacketType.Pong(pongCargo)
        nodeStats.addNodeStatsEvent(StatsEvents.PongSent)
        router.getPacketToRouteFromNode(envelope, cargo: pongPacketCargo)
        

    }
    
    func processPong(packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.PongRecieved)
        var pingSerial:UInt64 = 0

        switch packet.packetCargo
        {
        case .Pong(let pongPacketCargo): pingSerial=pongPacketCargo.serialOfPing
        default: log(7, "Pong packet is not PoNG!")
        }
        
        pingApp.recievedPong(pingSerial)
    }
    
    func processData(packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.DataRecieved)
    }
    
    func processDataDeliveryConfirmation(packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.DataConfirmationRecieved)
    }
    
    

    
 // Other API
    func refreshPeers()
    {
         // assemble packet and
        let discoveryBroadcastPacketHeader = UPacketHeader(from: self.id, to: broadcastNodeId, lifeTime: standardPacketLifeTime)
        let discoveryBroadcastPacketEnvelope = UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: broadcastNodeId, toAddress: unknownNodeAddress)
        let broadcastDiscovery=UPacketDiscoveryBroadcast()
        let broadcastDiscovetyCargo=UPacketType.DiscoveryBroadcast(broadcastDiscovery)
        let broadcastDiscoveryPacket=UPacket(inputHeader: discoveryBroadcastPacketHeader, inputEnvelope: discoveryBroadcastPacketEnvelope, inputCargo: broadcastDiscovetyCargo)
 
        
        //deliver to all interfaces
        
        for(_, interface) in enumerate(self.interfaces)
        {
            interface.sendPacketToNetwork(broadcastDiscoveryPacket)
        }
        
    }
    
    
    // Processing functions
    
    func findInPeers(nodeId:UNodeID) -> Int?
    {
        var result:Int?
        for(i, peerRecord) in enumerate(self.peers)
        {
            if(peerRecord.id.isEqual(nodeId))
            {
            result = i
            }
        }
        return result
    }
    
    func findAddressFromConnectedPeers()
    {
        var latitudeSum:UInt64 = 0
        var longitudeSum:UInt64 = 0
        var altitudeSum:UInt64 = 0
        
        
        for (_, peer) in enumerate(self.peers)
        {
            latitudeSum+=peer.address.latitude
            longitudeSum+=peer.address.longitude
            altitudeSum+=peer.address.altitude
        }
        
        latitudeSum = latitudeSum / UInt64(peers.count)
        longitudeSum = longitudeSum / UInt64(peers.count)
        altitudeSum = altitudeSum / UInt64(peers.count)

        self.address=UNodeAddress(inputLatitude: latitudeSum, inputLongitude: longitudeSum, inputAltitude: altitudeSum)
        
        
    }
    
    
    
}



