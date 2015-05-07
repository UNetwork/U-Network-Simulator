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
    
    
    let id:UNodeID                                          // Unique Id
    var address:UNodeAddress                                // Current Address - geographical position
    var userName:String                                     // User name of node if defined
    var timeCounter:UInt64=0                                // Local "time"
    
    var interfaces=[UNetworkInterfaceProtocol]()            // Network interfaces
    var router:URouterProtocol!                             // Handler for packet router

    var peers = [UNodeID:UPeerDataRecord]()                         // Currently available connected nodes
    var knownAddresses = [UNodeID:UMemoryIdAddressRecord]() // Memory of search for address service
    var knownIDs  = [String:UMemoryNameIdRecord]()          // Memory of search for name service
    
    var appsAPI: UNodeAPI!                                  // Handler for all API of apps
    
    var lastPeerRefresh = UInt64(0)
    var lastNameStore = UInt64(0)
    var lastAddressStore = UInt64(0)
    
    //Node apps required
    
    var pingApp:UNAppPing!
    var searchApp:UNAppSearch!
    var dataApp:UNAppDataTransfer!
    
    
    
    // helper apps - node will work without them
    let nodeStats = UNAppNodeStats()
    let nodeCurrentState = UNAppNodeCurrentState()
    

    //  Init
    
    init ()
    {
        id=UNodeID(lenght: uIDlengh)
        userName = randomUserName(6)
        address = unknownNodeAddress
        self.appsAPI=UNodeAPI(node: self)
        
        log(0,"node for owner: \(userName) created")
    }
    
    func setupAndStart()
    {
        // setup router
        router = CurrentRouter(node:self)
        
        //set up node apps
        pingApp = UNAppPing(node: self)
        searchApp = UNAppSearch(node: self)
        dataApp = UNAppDataTransfer(node: self)
        
        // add self data to search tables
        
        knownIDs[self.userName] = UMemoryNameIdRecord(anId: self.id, aTime: self.nodeTime)

        // find addres from interfaces
        for (_, interface) in enumerate(self.interfaces)
        {
            if let interfacePosition=interface.location
            {
                self.address=interfacePosition
                break
                // we take first avaliable location form interface
            }
        }
        
        
       // refreshPeers()
        
        // if failed to find address in interfaces take the avarge address from peers
        
        if(self.address.isUnknown)
        {
            findAddressFromConnectedPeers()
        }

        
        knownAddresses[self.id] = UMemoryIdAddressRecord(anAddress: self.address, aTime: self.nodeTime)
        
        // start apps
        

        // set up node maintenance loop
    }
    
    func populateOwnData()
    {
        searchApp.storeName()
        searchApp.storeAddress()    
    }
    
    func heartBeat()
    {
        router.maintenanceLoop()
       
        if heartBeatPeersValue > 0
        {
            if ((rand() % Int32(heartBeatPeersValue)) == 0)
            {
                refreshPeers()
            }
        }
        if heartBeatNameStoreValue > 0
        {
            if ((rand() % Int32(heartBeatNameStoreValue)) == 0)
            {
                self.searchApp.storeName()
            }
        }
        if heartBeatAddressStoreValue > 0
        {
            if ((rand() % Int32(heartBeatAddressStoreValue)) == 0)
            {
               self.searchApp.storeAddress()
            }
        }
        

 
    }
    

    func getPacketFromInterface(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        if(packet.header.transmitedToUID.isBroadcast())
        {
            processDiscoveryBroadcast(interface, packet: packet)
        }
        else
        {
      
            if(packet.envelope.destinationUID.isEqual(self.id) || packet.envelope.destinationUID.isBroadcast())
            {
            
                
                switch packet.packetCargo
                {
                case .ReceptionConfirmation(let _): router.getReceptionConfirmation(interface, packet: packet) // this is router staff
                
                case .ReplyForDiscovery(let _): processDiscoveryBroadcastreply(interface, packet: packet)
                
                case .ReplyForNetworkLookupRequest(let _): router.getReplyForNetworkLookupRequest(interface, packet: packet); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false) // router staff - future implementation for another sense of neighberhood
                
                case .SearchIdForName(let searchForIdRequest): processSearchIdForName(interface, header:packet.header, envelope:packet.envelope, request: searchForIdRequest); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)

                case .StoreIdForName(let storeIdRequest): processStoreIdForName(interface, header:packet.header, envelope:packet.envelope, request: storeIdRequest); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                case .StoreNamereply(let replyCargo): processStoreNamereply(packet.envelope, reply:replyCargo); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                
                case .SearchAddressForID(let searchForAddressRequest): processSearchAddressForID(interface, header:packet.header, envelope:packet.envelope, request: searchForAddressRequest); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                
                case .StoreAddressForId(let searchForAddressRequest): processStoreAddressForId(interface, header:packet.header, envelope:packet.envelope, request: searchForAddressRequest); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                
                case .ReplyForIdSearch(let searchForIdResultCargo): processIdSearchResults(packet.envelope,  searchResult: searchForIdResultCargo); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                
                case .ReplyForAddressSearch(let searchForAddressResultCargo) : processAddressSearchResults(packet.envelope, searchResult: searchForAddressResultCargo); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                
                case .Ping(let pingCargo): processPing(packet.envelope, ping: pingCargo); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)

                
                case .Pong(let pongCargo): processPong(packet.envelope, pong: pongCargo); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                
                case .Data(let _): processData(packet); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                
                case .DataDeliveryConfirmation(let _): processDataDeliveryConfirmation(packet); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                case .Dropped(let droppedCargo): processDrop(packet.envelope, droppedPacket:droppedCargo); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                
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
        if(packet.header.lifeCounterAndFlags.lifeCounter > 0)
        {
        nodeStats.addNodeStatsEvent(StatsEvents.TrespassingPacketProcessedByNode)  // STATS
        
        router.getPacketToRouteFromNode(interface, packet:packet)
        }
        else
        {
            switch packet.packetCargo
            {
            case .Dropped(let _): log(5, "N: \(self.txt) lifetime of dropped packet excedded - dropping dropped with no notification \(packet.txt)")
            default: sendDropped(packet.envelope)
            }
            
        }
    }
    
    func sendDropped(envelope:UPacketEnvelope)
    {
       self.nodeStats.addNodeStatsEvent(StatsEvents.PacketDropped)
        // create dropped packet and send to the originator (if dropped packet type is not dropped - to check ealier)
        let dropCargo = UPacketDropped(serial: envelope.serial)
        let drop=UPacketType.Dropped(dropCargo)
        let dropEnvelope=UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: envelope.orginatedByUID, toAddress: envelope.originAddress)
        router.getPacketToRouteFromNode(dropEnvelope, cargo: drop)
        
    }
    
    
    
    // Packet processing
    
    func processDiscoveryBroadcast(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        // reply
        
        let replyPacketHeader = UPacketHeader(from: self.id, to: packet.envelope.orginatedByUID, lifeTime: standardPacketLifeTime)
        var replyEnvelope = UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: packet.envelope.orginatedByUID, toAddress: packet.envelope.originAddress)
  
        var replyForDiscovery=UPacketyReplyForDiscovery()
        var replyCargo = UPacketType.ReplyForDiscovery(replyForDiscovery)
        var replyPacket=UPacket(inputHeader: replyPacketHeader, inputEnvelope: replyEnvelope, inputCargo: replyCargo)
        
        nodeStats.addNodeStatsEvent(StatsEvents.DiscoveryBroadcastPacketProcessed)
        log(2, "N: \(self.txt) replyed for \(packet.txt) with \(replyPacket.txt) ")
        
     //   processDiscoveryBroadcastreply(interface, packet: packet)   // hack to add a peer from "passive" information
        
        
        interface.sendPacketToNetwork(replyPacket)

    }
    
    func processDiscoveryBroadcastreply(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        // check if replyer is already on peers list, add if not
        
        
        
        
        
        if let peerRecord = peers[packet.header.transmitedByUID]
        {
            peers[packet.header.transmitedByUID]?.active = true
        }
        else
        {
            let newPeerRecord=UPeerDataRecord(nodeId:packet.header.transmitedByUID, address:packet.envelope.originAddress, interface:interface)
            self.peers[packet.header.transmitedByUID] = newPeerRecord
            log(3,"\(self.userName) added a peer")
            
        }
        
    }
    
    
    
    
    func processSearchIdForName(interface:UNetworkInterfaceProtocol, header:UPacketHeader, envelope:UPacketEnvelope, request:UPacketSearchIdForName)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.SearchIdForNameProcessed)
        log(2, "\(self.txt) Searching Id for name: \(request.name)")
        
        if let foundId=knownIDs[request.name]
        {
            
            // name found reply data
            
            
            let newEnvelope=UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: envelope.orginatedByUID, toAddress: envelope.originAddress)
            
            let searchreplyCargo = UPacketType.ReplyForIdSearch(UPacketReplyForIdSearch(id: foundId.id, serial: request.searchSerial))
            
            router.getPacketToRouteFromNode(newEnvelope, cargo: searchreplyCargo)
            
        }
        else
        {
           
            let packet = UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: UPacketType.SearchIdForName(request))
            
            processTrespassingPacket(interface, packet: packet)
            
            
        }
        
        
        
    }
    
    func processStoreIdForName(interface:UNetworkInterfaceProtocol, header:UPacketHeader, envelope:UPacketEnvelope, request:UPacketStoreIdForName)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.StoreIdForNameProcessed)
        
        
        if let searchedIdRecord=knownIDs[request.name]
        {
            if(searchedIdRecord.id.isEqual(request.id))
            {
                // reply with positive anwser
            }
            else
            {
                // reply with negative anwser
            }
        }
        else
        {
            // add record
            self.knownIDs[request.name] = UMemoryNameIdRecord(anId: envelope.orginatedByUID, aTime: nodeTime)
        }
        
        let packet = UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: UPacketType.StoreIdForName(request))
        
        processTrespassingPacket(interface, packet: packet)

    }
    
    
    func processStoreNamereply(envelope:UPacketEnvelope, reply:UPacketStoreNamereply)
    {
        
    }
    
    
    func processSearchAddressForID(interface:UNetworkInterfaceProtocol, header:UPacketHeader, envelope:UPacketEnvelope, request:UPacketSearchAddressForID)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.SearchAddressForIdProcessed)
        if let searchResult = knownAddresses[request.id]
 {
        let address = searchResult.address
       
           // if time is later in request send reply
            if (searchResult.time >= request.time)
            {
             let newEnvelope=UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: envelope.orginatedByUID, toAddress: envelope.originAddress)
                let cargo=UPacketType.ReplyForAddressSearch(UPacketReplyForAddressSearch(anId: request.id, anAddress: address, aTime: searchResult.time, forSerial:request.searchSerial))
                router.getPacketToRouteFromNode(newEnvelope, cargo: cargo)
                
            }
            else
            {
                
                // delete obstolate record or do nothing
                
            }
        }
        else
        {
            let packet = UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: UPacketType.SearchAddressForID(request))
            
            processTrespassingPacket(interface, packet: packet)
        }

        
        
    }
    
    
    
    
    
    func processStoreAddressForId(interface:UNetworkInterfaceProtocol, header:UPacketHeader, envelope:UPacketEnvelope, request:UPacketStoreAddressForId)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.StoreAddressForIdProcessed)
        
        if let searchResult = knownAddresses[request.id]
        
        
        {
           // check for time if newer then stored and update if necessery
        // delete packet if older, but tresspass if equal time
        
        
        
        
        }
        else
        {
            // add record
            self.knownAddresses[request.id] = UMemoryIdAddressRecord(anAddress: request.address, aTime: request.time)
        }
        
        
        // this should be inside if twice later on
        
        let packet = UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: UPacketType.StoreAddressForId(request))
        
        processTrespassingPacket(interface, packet: packet)

        
        
        
    }
    
    
    
    
    

    func processIdSearchResults(envelope:UPacketEnvelope, searchResult:UPacketReplyForIdSearch)
    {
     nodeStats.addNodeStatsEvent(StatsEvents.IdSearchResultRecieved)
        self.searchApp.idFound(searchResult)
        
    }
    
    func processAddressSearchResults(envelope:UPacketEnvelope, searchResult:UPacketReplyForAddressSearch)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.AddressSearchResultRecieved)
        self.searchApp.addressFound(searchResult)
    }
    
    func processPing(envelope:UPacketEnvelope, ping:UPacketPing)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.PingRecieved)

        let newEnvelope = UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: envelope.orginatedByUID, toAddress: envelope.originAddress)

        let pongCargo=UPacketType.Pong(UPacketPong(serialOfPing: ping.serial))
        
        nodeStats.addNodeStatsEvent(StatsEvents.PongSent)
        
        router.getPacketToRouteFromNode(newEnvelope, cargo: pongCargo)
        

    }
    
    func processPong(envelope:UPacketEnvelope, pong:UPacketPong)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.PongRecieved)
   
        
        pingApp.recievedPong(pong.serialOfPing)
    }
    
    func processData(packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.DataRecieved)
    }
    
    func processDataDeliveryConfirmation(packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.DataConfirmationRecieved)
    }
    
    func processDrop(envelope:UPacketEnvelope, droppedPacket:UPacketDropped)
    {
        
    }
    
    

    
 // Other API
    func refreshPeers()
    {
        lastPeerRefresh = nodeTime
        for peer in peers
        {
          
                peers[peer.0]?.active = false
            
            
        }
        
        
        
        
         // assemble packet and
        let discoveryBroadcastPacketHeader = UPacketHeader(from: self.id, to: broadcastNodeId, lifeTime: standardPacketLifeTime)
        let discoveryBroadcastPacketEnvelope = UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: broadcastNodeId, toAddress: unknownNodeAddress)
        let broadcastDiscovery=UPacketDiscoveryBroadcast()
        let broadcastDiscovetyCargo=UPacketType.DiscoveryBroadcast(broadcastDiscovery)
        let broadcastDiscoveryPacket=UPacket(inputHeader: discoveryBroadcastPacketHeader, inputEnvelope: discoveryBroadcastPacketEnvelope, inputCargo: broadcastDiscovetyCargo)
 
        
        //deliver to all interfaces
        
        for(_, interface) in enumerate(self.interfaces)
        {
            self.nodeStats.addNodeStatsEvent(StatsEvents.DiscoveryBroadcastSent)
            
            
            interface.sendPacketToNetwork(broadcastDiscoveryPacket)
        }
        
    }
    
    func resetInternalData()
    {
        timeCounter=0
        peers = [UNodeID:UPeerDataRecord]()
        knownAddresses = [UNodeID:UMemoryIdAddressRecord]()
        knownIDs  = [String:UMemoryNameIdRecord]()
        router.reset()
    }
    
    
    // Processing functions
    
    // Other Utility
    
    func findAddressFromConnectedPeers()
    {
        if (peers.count > 0){
        var latitudeSum:UInt64 = 0
        var longitudeSum:UInt64 = 0
        var altitudeSum:UInt64 = 0
        
        
        for (_, peer) in enumerate(self.peers.values)
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
    
    var nodeTime:UInt64
    {
        get {
        return    ++self.timeCounter
            }
        
    }
    
    var txt:String
    {
        return "Node \(self.id.txt) "
    }
    
    
    
}



