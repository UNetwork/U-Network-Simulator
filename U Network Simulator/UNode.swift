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
    var timeCounter:UInt64=0                               // Local "time"
    
    var interfaces=[UNetworkInterfaceProtocol]()    // Network interfaces
    var router:URouterProtocol!                     // Handler for packet router
    var storeAndSearchRouter:UStoreAndSearchRoutingProtocol!
                                                    // The search and store packets are routed differently
    var peers = [UPeerDataRecord]()                 // Currently available connected nodes
    var knownAddresses = [UMemoryIdAddressRecord]() // Memory of search for address service
    var knownNames  = [UMemoryNameIdRecord]()       // Memory of search for name service
    
    var contacts = [UNodeContacts] ()               // Commonly contacted noods, contacts
    var apps = [UAppProtocol] ()                    // Handler for all "installed" apps
    
    
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
        
        
        // start node apps
        
  //      pingApp=UNAppPing(node:self)

        
    }
    
    func setupAndStart()
    {
        
        //Avoid logging during initialisation
        let geniueLogLevel = AppDelegate.sharedInstance.logLevel
        AppDelegate.sharedInstance.logLevel=3

        
        // setup router
        router = CurrentRouter(node:self)
        storeAndSearchRouter = UStoreAndSearchRouterSimple(node: self)
        
        //set up node apps
        pingApp = UNAppPing(node: self)
        searchApp = UNAppSearch(node: self)
        dataApp = UNAppDataTransfer(node: self)
        
        // add self data to search tables
        let ownNameRecord=UMemoryNameIdRecord(name: self.userName, id: self.id, time: nodeTime)
        knownNames.append(ownNameRecord)
        
        
        
        

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
        refreshPeers()

        AppDelegate.sharedInstance.logLevel=geniueLogLevel
        
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
                
                case .ReplyForDiscovery(let _): processDiscoveryBroadcastreply(interface, packet: packet)
                
                case .ReplyForNetworkLookupRequest(let _): router.getReplyForNetworkLookupRequest(interface, packet: packet) // router staff - future implementation for another sense of neighberhood
                
                case .SearchIdForName(let searchForIdRequest): processSearchIdForName(packet.header, envelope:packet.envelope, request: searchForIdRequest)

                case .StoreIdForName(let storeIdRequest): processStoreIdForName(packet.header, envelope:packet.envelope, request: storeIdRequest)
                    
                case .StoreNamereply(let replyCargo): processStoreNamereply(packet.envelope, reply:replyCargo)
                
                case .SearchAddressForID(let _): processSearchAddressForID(interface, packet: packet)
                
                case .StoreAddressForId(let _): processStoreAddressForId(interface, packet:packet)
                
                case .ReplyForIdSearch(let searchForIdResultCargo): processIdSearchResults(packet.envelope,  searchResult: searchForIdResultCargo)
                
                case .ReplyForAddressSearch(let _) : processAddressSearchResults(packet)
                
                case .Ping(let pingCargo): processPing(packet.envelope, ping: pingCargo)
                
                case .Pong(let pongCargo): processPong(packet.envelope, pong: pongCargo)
                
                case .Data(let _): processData(packet)
                
                case .DataDeliveryConfirmation(let _): processDataDeliveryConfirmation(packet)
                    
                case .Dropped(let droppedCargo): processDrop(packet.envelope, droppedPacket:droppedCargo)
                
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
            case .Dropped(let _): log(5, "\(self.txt) lifetime of dropped packet excedded - dropping dropped with no notification \(packet.txt)")
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
        log(2, "\(self.txt) replyed for \(packet.txt) with \(replyPacket.txt) ")
        
        interface.sendPacketToNetwork(replyPacket)
        
     //   router.getPacketToRouteFromNode(nil, packet:replyPacket) // - we cannot do it here becouse the sender may be not on our peer list yet
        
        
        
        // if packet couter > 0 resend to all nodes. If packet counter>discovery limit >>> drop mtfker
        // check on peers list, add if needed
        
        
    }
    
    func processDiscoveryBroadcastreply(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        // check if replyer is already on peers list, add if not

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
    
    
    
    
    func processSearchIdForName(header:UPacketHeader, envelope:UPacketEnvelope, request:UPacketSearchIdForName)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.SearchIdForNameProcessed)
        
        if let foundId=findIdForName(request.name) where request.name != self.userName
        {
            
            // name found reply data
            
            nodeStats.addNodeStatsEvent(StatsEvents.SearchForNameSucess)
            
            let newEnvelope=UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: envelope.orginatedByUID, toAddress: envelope.originAddress)
            
            let searchreplyCargo = UPacketType.ReplyForIdSearch(UPacketReplyForIdSearch(id: foundId, serial: request.searchSerial))
            
            router.getPacketToRouteFromNode(newEnvelope, cargo: searchreplyCargo)
            
        }
        else
        {
            if(envelope.orginatedByUID.isEqual(self.id))
            {
                // send 8 packets
                storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: UPacketType.SearchIdForName(request)))
                var modifiedEnevelope=envelope
                modifiedEnevelope.destinationAddress=aboveNorthPoleLeft
                storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.SearchIdForName(request)))
                modifiedEnevelope.destinationAddress=belowNorthPoleRight
                storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.SearchIdForName(request)))
                modifiedEnevelope.destinationAddress=belowNorthPoleLeft
                storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.SearchIdForName(request)))
                modifiedEnevelope.destinationAddress=aboveSouthPoleRight
                storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.SearchIdForName(request)))
                modifiedEnevelope.destinationAddress=aboveSouthPoleLeft
                storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.SearchIdForName(request)))
                modifiedEnevelope.destinationAddress=belowSouthPoleRight
                storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.SearchIdForName(request)))
                modifiedEnevelope.destinationAddress=belowSouthPoleLeft
                storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.SearchIdForName(request)))
                
            }
            else if(envelope.destinationUID.isBroadcast())
            {
                storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: UPacketType.SearchIdForName(request)))
            }
            
        }
        
        
        
    }
    
    func processStoreIdForName(header:UPacketHeader, envelope:UPacketEnvelope, request:UPacketStoreIdForName)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.StoreIdForNameProcessed)

        
        
        
        if(envelope.orginatedByUID.isEqual(self.id))
        {
            // send 8 packets
            storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: UPacketType.StoreIdForName(request)))
            var modifiedEnevelope=envelope
            modifiedEnevelope.destinationAddress=aboveNorthPoleLeft
            storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.StoreIdForName(request)))
            modifiedEnevelope.destinationAddress=belowNorthPoleRight
            storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.StoreIdForName(request)))
            modifiedEnevelope.destinationAddress=belowNorthPoleLeft
            storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.StoreIdForName(request)))
            modifiedEnevelope.destinationAddress=aboveSouthPoleRight
            storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.StoreIdForName(request)))
            modifiedEnevelope.destinationAddress=aboveSouthPoleLeft
            storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.StoreIdForName(request)))
            modifiedEnevelope.destinationAddress=belowSouthPoleRight
            storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.StoreIdForName(request)))
            modifiedEnevelope.destinationAddress=belowSouthPoleLeft
            storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: modifiedEnevelope, inputCargo: UPacketType.StoreIdForName(request)))

        }
        else
        {
            
            if let id=findIdForName(request.name)
            {
                if(id.isEqual(request.id))
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
                self.knownNames.append(UMemoryNameIdRecord(name: request.name, id: envelope.orginatedByUID, time: nodeTime))
                
            }
            
            // chceck the broadcast in envelope is set and
            // forward packet to StoreAndSearch Routing
            
            if(envelope.destinationUID.isBroadcast())
            {
                storeAndSearchRouter.getStoreOrSearchPacket(UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: UPacketType.StoreIdForName(request)))
            }
            
        }
        
    }
    
    func processStoreNamereply(envelope:UPacketEnvelope, reply:UPacketStoreNamereply)
    {
        
    }
    
    
    func processSearchAddressForID(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.SearchAddressForIdProcessed)
    }
    
    func processStoreAddressForId(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.StoreAddressForIdProcessed)
    }
    
    

    func processIdSearchResults(envelope:UPacketEnvelope, searchResult:UPacketReplyForIdSearch)
    {
     nodeStats.addNodeStatsEvent(StatsEvents.IdSearchResultRecieved)
        self.searchApp.nameFound(searchResult)
        
    }
    
    func processAddressSearchResults(packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.AddressSearchResultRecieved)
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
    
    func findIdForName(nameToFind:String) -> UNodeID?
    {
        var result:UNodeID?
        
        for(_, nameRecord) in enumerate(self.knownNames)
        {
            if(nameRecord.name == nameToFind)
            {
                result = nameRecord.id
            }
        }
        
        
        return result
    }
    
    // Other Utility
    
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
    
    var nodeTime:UInt64
    {
        get {
        return    ++self.timeCounter
            }
        
    }
    
    var txt:String
    {
        return "NODE \(self.id.txt) PEERS: \(self.peers.count) "
    }
    
    
    
}



