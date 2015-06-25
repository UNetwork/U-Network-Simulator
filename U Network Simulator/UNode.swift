//
//  UNode.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/19/15.
//

import Foundation

/*
Welcome!

UNode communicates with other UNodes via interfaces to the networks. Transmition is done in packets.
Node has a router responsible for choosing the next currently connected node (peer) to transmit the trespassing packet.
Node is servicing user applications via UNodeAPI.
*/

class UNode {
    
    /*
    UNode properties
    */
    
    // Unique ID: 64 - 256 bits
    let id:UNodeID
    
    // Current Address - geographical position (latitude, longitude, altitude) encoded in 128 bits
    var address:UNodeAddress
    
    // Node owner name if defined
    var ownerName:String!
    
    /*
    Objects responsible for UNode conectivity
    */
    
    /*
    Interface (protocol UNetworkInterfaceProtocol)
    
    Interface is connection between UNode and the shared Medium (protocol MediumProtocol).
    Medium allows to transmit data between interfaces of different UNodes.
    There are 4 types of mediums avaliable: wireless, internet, hub, bridge.
    UNode may have arbitrary combination of any types of interfaces.
    */
    var interfaces=[UNetworkInterfaceProtocol]()
    
    /*
    Router (protocol URouterProtocol)
    
    Router is responsible for:
    - processsing all packets received by Node, but not addressed to it.
    - keeping and managing the pocket stack.
    - selecting for each packet one of currently connected UNodes on all interfaces to transmit the packet to.
    - transmition confirmation send/recieve for each packet
    - resending packet if lack of transmition confirmation or packet rejection
    */
    var router:URouterProtocol!
    
    /*
    UNode memory
    */
    
    // Peers dictionaty keeps in the record currently connected nodes on all interfaces
    var peers = [UNodeID:UPeerDataRecord]()
    
    // knownAddresses and knownIDs stores the information about the other nodes
    // You need owner name to find ID and you need an ID to find an address
    var knownAddresses = [UNodeID:UMemoryIdAddressRecord]()
    var knownIDs  = [String:UMemoryNameIdRecord]()
    
    
    /*
    UNode Internal Apps
    */
    
    // pingApp sends a ping and recieves a pong. UNodeID and UNodeAddress are needed to send a ping here
    var pingApp:UNAppPing!
    
    // searchApp allows to find ID for given owner name, and address for given ID.
    // This app also propagates owners name and node address to the network
    var searchApp:UNAppSearch!
    
    // dataApp transfers a packet of data with owners name and requesting app as an argument
    var dataApp:UNAppDataTransfer!
    
    // appsAPI is high level API avaliable for all UNode Apps
    var appsAPI: UNodeAPI!
    
    
    /*
    UNode Optional Internal Apps - for simulation needs
    */
    let nodeStats = UNAppNodeStats()
    let nodeCurrentState = UNAppNodeCurrentState()
    
    /*
    Other
    */
    
    // Timer for precedence of events in node scope
    var timeCounter:UInt64=0
    
    // Helper vars
    var lastPeerRefresh = UInt64(0)
    var lastNameStore = UInt64(0)
    var lastAddressStore = UInt64(0)
    
    // for avoiding crahes ???
    let queue = dispatch_queue_create("Serial Queue", DISPATCH_QUEUE_SERIAL)
    
    /*
    UNode Initialisation
    
    The UNode object initialisation is done in three steps:
    - The init() is called by simulation layer
    - The simulation layer adds interfeces with appropriate data to the object created in init()
    - The setupAndStart() is called by simulation layer
    */
    init ()
    {
        // UNodeID is 1 - 4 UInt64s, random at initialisation
        id=UNodeID(lenght: uIDlengh)
        
        // random name given lenght
        ownerName = randomUserName(6)
        
        // address property initilised with special address considered as unknown address
        address = unknownNodeAddress
        
        log(0,"UNode for owner: \(ownerName) created")
    }
    
    
    func setupAndStart()
    {
        // Setup node router
        router = CurrentRouter(node:self)
        
        // Set up node internal apps
        pingApp = UNAppPing(node: self)
        searchApp = UNAppSearch(node: self)
        dataApp = UNAppDataTransfer(node: self)
        
        // API for UNode apps
        self.appsAPI=UNodeAPI(node: self)
        
        // Add own data to knownIDs table
        knownIDs[self.ownerName] = UMemoryNameIdRecord(anId: self.id, aTime: self.nodeTime)
        
        // Find address (location) from avaliable interfaces.
        // Some interfaces has it (wirelless) if found is taken as current node address
        for (_, interface) in enumerate(self.interfaces)
        {
            if let interfacePosition=interface.location
            {
                self.address=interfacePosition
                break
                // we take first avaliable location form interface
            }
        }
        
        // If failed to find address in interfaces take the avarge location of peers
        if(self.address.isUnknown)
        {
            refreshPeers()
            sleep(1)
            findAddressFromConnectedPeers()
        }
        
        // Add own address data to knownAddresses table
        knownAddresses[self.id] = UMemoryIdAddressRecord(anAddress: self.address, aTime: self.nodeTime)
        
        log(0,"UNode for owner: \(ownerName) initilised with address: \(address.txt)")
    }
    
    /*
    Packet processing
    
    UPacket consists of header, envelope and cargo. Header is used on interface level (direct) node communication, envelope for end-to-end transsimsion addressing, and cargo for stuff.
    Different packet have different data structures as cargo.
    */
    
    // This function is called every time any of UNodes interface recieves any packet from the medium.
    // The arguments are the interface which received the packet and the packet itself.
    func getPacketFromInterface(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        // First we check if packet address is broadcast type in packet's header
        if(packet.header.transmitedToUID.isBroadcast())
        {
            // If so we assume this must be a DiscoveryBroadcast packet and we call proper function
            // to respond to the request.
            processDiscoveryBroadcast(interface, packet: packet)
        }
        else
        {
            // If packet is not broadcast it must have an ID in envelope.
            // We check if it is nodes own ID and if so, the packet is diassembled and processed to proper processing function.
            // Envelope address may be also brodcast type, but here it is used to distribute or search information in the network.
            if(packet.envelope.destinationUID.isEqual(self.id) || packet.envelope.destinationUID.isBroadcast())
            {
                if (packet.lookUpRequest != nil)
                {
                    // Replay with Replay for NetworkLookup Request
                    let response=UPacketReplyForNetworkLookupRequest(replayerID:self.id, replayerAddress:self.address, serial:packet.envelope.serial)
                    let envelope=UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: packet.lookUpRequest!.requester, toAddress: packet.lookUpRequest!.requesterAddress)
                    let cargo=UPacketType.ReplyForNetworkLookupRequest(response)
                    
                    router.getPacketToRouteFromNode(envelope, cargo: cargo)

                }
                switch packet.packetCargo
                {
                    // ReceptionConfirmation packet is send when the packet is sucessfully received by other node.
                case .ReceptionConfirmation(let _): router.getReceptionConfirmation(interface, packet: packet)
                    
                    // ReplyForDiscovery packet is the anwser for the DiscoveryBroadcast packet
                case .ReplyForDiscovery(let _): processDiscoveryBroadcastreply(interface, packet: packet)
                    
                    // ReplyForNetworkLookupRequest is packet that is an anwser for lookUpRequest that maybe added to any tresspasing packet
                case .ReplyForNetworkLookupRequest(let _): router.getReplyForNetworkLookupRequest(interface, packet: packet); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // SearchIdForName the ID search packet
                case .SearchIdForName(let searchForIdRequest): processSearchIdForName(interface, header:packet.header, envelope:packet.envelope, request: searchForIdRequest); router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // StoreIdForName is a Name-ID store request packet
                case .StoreIdForName(let storeIdRequest): processStoreIdForName(interface, header:packet.header, envelope:packet.envelope, request: storeIdRequest); router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // StoreNamereply is a confirmation of storing the Name-ID data by the sender
                case .StoreNamereply(let replyCargo): processStoreNamereply(packet.envelope, reply:replyCargo); self.router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // SearchAddressForID is address search packet
                case .SearchAddressForID(let searchForAddressRequest): processSearchAddressForID(interface, header:packet.header, envelope:packet.envelope, request: searchForAddressRequest); router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // StoreAddressForId is ID-address data store request packet
                case .StoreAddressForId(let searchForAddressRequest): processStoreAddressForId(interface, header:packet.header, envelope:packet.envelope, request: searchForAddressRequest); router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // ReplyForIdSearch is anwser with found ID for SearchIdForName packet
                case .ReplyForIdSearch(let searchForIdResultCargo): processIdSearchResults(packet.envelope,  searchResult: searchForIdResultCargo); router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // ReplyForAddressSearch is anwser with found address for SearchAddressForID packet
                case .ReplyForAddressSearch(let searchForAddressResultCargo) : processAddressSearchResults(packet.envelope, searchResult: searchForAddressResultCargo); router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // Ping is ping packet
                case .Ping(let pingCargo): processPing(packet.envelope, ping: pingCargo); router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // Pong is anwser for ping
                case .Pong(let pongCargo): processPong(packet.envelope, pong: pongCargo); router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // Data is data trasfer packet between two UNodes
                case .Data(let dataCargo): processData(dataCargo, envelope: packet.envelope); router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // DataDeliveryConfirmation is the of delivery confirmation of Data packet
                case .DataDeliveryConfirmation(let _): processDataDeliveryConfirmation(packet); router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // If packet exeeds its lifetime the dropped packet is sent to the origin of the packet
                case .Dropped(let droppedCargo): processDrop(packet.envelope, droppedPacket:droppedCargo); router.sendPacketDeliveryConfirmation(interface, packet: packet, rejected: false)
                    
                    // This should never happen
                default: log(7, "Unknown packet type in UNode packet dispatch")
                    
                    // Note that router.sendPacketDeliveryConfirmation is called to confirm packet delivery. For the tresspassing packets this is done by router.
                }
            }
            else
            {
                // If the address id in nither node's ID or brodcast type we forward the packet to other node
                processTrespassingPacket(interface, packet: packet)
            }
        }
    }
    
    /*
    Packet Processing Functions
    */
    
    // Trespassing packet processing
    func processTrespassingPacket(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        
        // Check if packet lifetime is not exeeded
        if(packet.header.lifeCounterAndFlags.lifeCounter > 0)
        {
            // This is call to add an event in node stats by the nodeStats app
            nodeStats.addNodeStatsEvent(StatsEvents.TrespassingPacketProcessedByNode)  // STATS
            
            
            // Check for Network Lookup request attached to the packet header
            if(packet.lookUpRequest != nil)
            {
                nodeStats.addNodeStatsEvent(StatsEvents.LookupRequestProcessed)
                
                var modifiedPacket = packet
                modifiedPacket.lookUpRequest!.counter.data--
                if (modifiedPacket.lookUpRequest!.counter.data == 0)
                {
                    // Replay with Replay for NetworkLookup Request
                    let response=UPacketReplyForNetworkLookupRequest(replayerID:self.id, replayerAddress:self.address, serial:packet.envelope.serial)
                    let envelope=UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: modifiedPacket.lookUpRequest!.requester, toAddress: modifiedPacket.lookUpRequest!.requesterAddress)
                    let cargo=UPacketType.ReplyForNetworkLookupRequest(response)
                    
                    router.getPacketToRouteFromNode(envelope, cargo: cargo)
                    
                    // delete request from the packet
                    modifiedPacket.lookUpRequest=nil
                    
                    router.getPacketToRouteFromNode(interface, packet:modifiedPacket)
                }
                else
                {
                    router.getPacketToRouteFromNode(interface, packet:modifiedPacket)
                }
            }
            else
            {
                // The rest of the staff with tresspassing packet is done in router object. See the URouterProtocol for the details
                router.getPacketToRouteFromNode(interface, packet:packet)
            }
        }
        else
        {
            // Packet liftime exeeded, we need to send dropped packet unless the packet is dropped type itself
            switch packet.packetCargo
            {
            case .Dropped(let _): log(5, "N: \(self.txt) lifetime of dropped packet excedded - dropping dropped with no notification to origin \(packet.txt)")
            default: sendDropped(interface, packet:packet)
            }
        }
    }
    
    
    // Discovery Brodcast packet processing
    func processDiscoveryBroadcast(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        // If node recieves discover Discovery Brodcast packet, it sends the appropriate response of UPacketyReplyForDiscovery packet
        
        // Packet header creation
        let replyPacketHeader = UPacketHeader(from: self.id, to: packet.envelope.orginatedByUID, lifeTime: standardPacketLifeTime)
        
        // Packet envelope creation
        let replyEnvelope = UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: packet.envelope.orginatedByUID, toAddress: packet.envelope.originAddress)
        
        // Final cargo and packet assembly
        let replyForDiscovery=UPacketyReplyForDiscovery()
        let replyCargo = UPacketType.ReplyForDiscovery(replyForDiscovery)
        let replyPacket=UPacket(inputHeader: replyPacketHeader, inputEnvelope: replyEnvelope, inputCargo: replyCargo)
        
        // This is call to add an event in node stats by the nodeStats app
        nodeStats.addNodeStatsEvent(StatsEvents.DiscoveryBroadcastPacketProcessed)
        
        log(2, "N: \(self.txt) replyed for \(packet.txt) with \(replyPacket.txt) ")
        
        // Finaly we send the replay packet to the interface the discovery broadcast came from
        interface.sendPacketToNetwork(replyPacket)
    }
    
    // When node is sending Discovery Broadcast packet the reply, if received, is processed here
    func processDiscoveryBroadcastreply(interface:UNetworkInterfaceProtocol, packet:UPacket)
    {
        // Check if replaying node is already on peers list, add to memoty table if not
        dispatch_async(queue, {
            if let peerRecord = self.peers[packet.header.transmitedByUID]
            {
                // The node is already in memory, so only marked as active is needed
                self.peers[packet.header.transmitedByUID]?.active = true
            }
            else
            {
                // New peer discovered, adding to memory
                let newPeerRecord=UPeerDataRecord(nodeId:packet.header.transmitedByUID, address:packet.envelope.originAddress, interface:interface)
                self.peers[packet.header.transmitedByUID] = newPeerRecord
                log(3,"\(self.ownerName) added a peer")
            }
        })
    }
    
    // ID for name search routine
    func processSearchIdForName(interface:UNetworkInterfaceProtocol, header:UPacketHeader, envelope:UPacketEnvelope, request:UPacketSearchIdForName)
    {
        // Stats
        nodeStats.addNodeStatsEvent(StatsEvents.SearchIdForNameProcessed)
        log(2, "\(self.txt) Searching Id for name: \(request.name)")
        
        // Check if we have the ID for requested name in memory
        if let foundId=knownIDs[request.name]
        {
            // Name found in memory, replay with UPacketReplyForIdSearch packet
            let newEnvelope=UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: envelope.orginatedByUID, toAddress: envelope.originAddress)
            let searchreplyCargo = UPacketType.ReplyForIdSearch(UPacketReplyForIdSearch(id: foundId.id, serial: request.searchSerial))
            
            // New envelope and cargo data is send to router, router adds header and sends packet to the network
            router.getPacketToRouteFromNode(newEnvelope, cargo: searchreplyCargo)
        }
        else
        {
            // Requested data not found - the packet is reassembled and treated as tresspassing
            let packet = UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: UPacketType.SearchIdForName(request))
            processTrespassingPacket(interface, packet: packet)
        }
    }
    
    // Here we process the Name-ID store in memory request
    func processStoreIdForName(interface:UNetworkInterfaceProtocol, header:UPacketHeader, envelope:UPacketEnvelope, request:UPacketStoreIdForName)
    {
       // Stats
        nodeStats.addNodeStatsEvent(StatsEvents.StoreIdForNameProcessed)
        
        // First we check if we already have this name in memory
        if let searchedIdRecord=knownIDs[request.name]
        {
            // If we have it we check if ID for the name is the same
            if(searchedIdRecord.id.isEqual(request.id))
            {
                // todo
                // reply with positive anwser
            }
            else
            {
                // todo
                // reply with negative anwser
            }
        }
        else
        {
            // We don't have the id for the name in memory
            // Add a record to the memory with current node time
            self.knownIDs[request.name] = UMemoryNameIdRecord(anId: envelope.orginatedByUID, aTime: nodeTime)
        }
        
        // Regardless we have or have not the data in memory, the packet is tresspassed to another node
       
        // Packet reassembly
        let packet = UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: UPacketType.StoreIdForName(request))
        
        // Process tresspasing packet
        processTrespassingPacket(interface, packet: packet)
    }
    
    
    func processStoreNamereply(envelope:UPacketEnvelope, reply:UPacketStoreNamereply)
    {
        // todo
        // Here we should do something with the data, this is the proof that the name we have choosen is ours
    }
    
    // Here the search for address to given ID is processed
    func processSearchAddressForID(interface:UNetworkInterfaceProtocol, header:UPacketHeader, envelope:UPacketEnvelope, request:UPacketSearchAddressForID)
    {
        // Stats
        nodeStats.addNodeStatsEvent(StatsEvents.SearchAddressForIdProcessed)
        
        // First we check the knownAddresses dictionaty
        if let searchResult = knownAddresses[request.id]
        {
            // Address found
            let address = searchResult.address
            
            // W check here if time in request is ealier (ie: 0) than in  stored addres data record, and if so we send reply
            // Otherwise the data is obstolate - someone got addres newer than node has, but is still searching for newer address
            if (searchResult.time >= request.time)
            {
                // replay with address information packet creation
                let newEnvelope=UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: envelope.orginatedByUID, toAddress: envelope.originAddress)
                let cargo=UPacketType.ReplyForAddressSearch(UPacketReplyForAddressSearch(anId: request.id, anAddress: address, aTime: searchResult.time, forSerial:request.searchSerial))
                
                // Send envelope and cargo to router
                router.getPacketToRouteFromNode(newEnvelope, cargo: cargo)
            }
            else
            {
                // todiscuss
                // delete obstolate record or do nothing
            }
        }
        else
        {
            // Requested data not found, pass the packet to other node
            
            // Packet reassembly
            let packet = UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: UPacketType.SearchAddressForID(request))
            
            // Process tresspasing packet
            processTrespassingPacket(interface, packet: packet)
        }
    }
    
    // Here we store in memory received data from address store request
    func processStoreAddressForId(interface:UNetworkInterfaceProtocol, header:UPacketHeader, envelope:UPacketEnvelope, request:UPacketStoreAddressForId)
    {
        // Stats
        nodeStats.addNodeStatsEvent(StatsEvents.StoreAddressForIdProcessed)
        
        // Check if we already have an address for ID
        if let searchResult = knownAddresses[request.id]
        {
            // todo
            // check for time if later then stored and update if necessery
            // delete packet if older, but tresspass if equal time
        }
        else
        {
            // Node's memory does not have an ID
            // add record
            self.knownAddresses[request.id] = UMemoryIdAddressRecord(anAddress: request.address, aTime: request.time)
        }
        
        
        // Packet reassembly
        let packet = UPacket(inputHeader: header, inputEnvelope: envelope, inputCargo: UPacketType.StoreAddressForId(request))
        
        // Process tresspasing packet
        processTrespassingPacket(interface, packet: packet)
    }
    
    // This function passes the obtained ID for Name search result to the node's searchApp
    func processIdSearchResults(envelope:UPacketEnvelope, searchResult:UPacketReplyForIdSearch)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.IdSearchResultReceived)
        self.searchApp.idFound(searchResult)
    }
    
    // This function passes the obtained address for ID search result to the node's searchApp
    func processAddressSearchResults(envelope:UPacketEnvelope, searchResult:UPacketReplyForAddressSearch)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.AddressSearchResultReceived)
        self.searchApp.addressFound(searchResult)
    }
    
    // The node has been pinged by other node
    func processPing(envelope:UPacketEnvelope, ping:UPacketPing)
    {
        // Stats
        nodeStats.addNodeStatsEvent(StatsEvents.PingReceived)
        
        // Pong envelope and cargo creation
        let newEnvelope = UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: envelope.orginatedByUID, toAddress: envelope.originAddress)
        let pongCargo=UPacketType.Pong(UPacketPong(serialOfPing: ping.serial))
        
        // Stats
        nodeStats.addNodeStatsEvent(StatsEvents.PongSent)
        
        // New envelope and cargo data is send to router, router adds header and sends packet to the network
        router.getPacketToRouteFromNode(newEnvelope, cargo: pongCargo)
    }
    
    // Pong processing
    func processPong(envelope:UPacketEnvelope, pong:UPacketPong)
    {
        //Stats
        nodeStats.addNodeStatsEvent(StatsEvents.PongReceived)
        
        // This is ping app task
        pingApp.receivedPong(pong.serialOfPing)
    }
    
    // The received Data packet is processed here
    func processData(dataCargo:UPacketData, envelope:UPacketEnvelope)
    {
        // Stats
        nodeStats.addNodeStatsEvent(StatsEvents.DataReceived)
        var name = ""
        
        // Lets Check if we have a name for the ID
        // todo
        // This is so wrong here but its working, the reversed knownIDs dictionary should work
        for knownID in knownIDs
        {
            if knownID.1.id.isEqual(envelope.orginatedByUID)
            {
                name = knownID.0
            }
        }
        
        // The packet envelope and cargo is passed to node's dataApp
        self.dataApp.recieveDataPacketFromNetwork(name, dataCargo: dataCargo, envelope: envelope)
    }
    
    // Data delivery confirmation processing
    func processDataDeliveryConfirmation(packet:UPacket)
    {
        nodeStats.addNodeStatsEvent(StatsEvents.DataConfirmationReceived)
    }
    
    // Dropped packet processing
    func processDrop(envelope:UPacketEnvelope, droppedPacket:UPacketDropped)
    {
        // todo
    }
    
    /*
    Other UNode functions
    */
    
    // This function is called periodically by the simulation layer
    func heartBeat()
    {
        // First lets the router makes his maintenance
        router.maintenanceLoop()
        
        // If specified in settings, node will randomly refresh peers and send it's name and address broadcast packets to the network
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
    
    
    // If dropped packet needs to be send this function is called
    func sendDropped(interface:UNetworkInterfaceProtocol?, packet:UPacket)
    {
        // Add stats record
        nodeStats.addNodeStatsEvent(StatsEvents.PacketDropped)
        
        // Create Dropped packet and send to the originator
        
        // The cargo of the Dropped packet is the serial number of the packet that exeeded it's liftime
        let dropCargo = UPacketDropped(serial: packet.envelope.serial)
        let drop=UPacketType.Dropped(dropCargo)
        
        // Packet envelope is created
        let dropEnvelope=UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: packet.envelope.orginatedByUID, toAddress: packet.envelope.originAddress)
        
        // Regarless changing the the packet to Dropped we send the packet delivery confirmation to node that sent it to us
        if interface != nil
        {
            router.sendPacketDeliveryConfirmation(interface!, packet: packet, rejected: false)
        }
        
        // sending Dropped packet is important, but sometimes it is convinient to swith it off for testing purposses
        if sendDroppedPackets
        {
            // This function is always called if node (or router) creates new packet. Router adds header of the packet and sent it to the network
            router.getPacketToRouteFromNode(dropEnvelope, cargo: drop)
        }
    }
    
    // This is hepler function that broadcasts Node's name and address in the network
    func populateOwnData()
    {
        searchApp.storeName()
        searchApp.storeAddress()
    }
    
    // This function is called when peer list needs to be refreshed
    func refreshPeers()
    {
        lastPeerRefresh = nodeTime
        
        // To avoid deleting peers, all peers before refreshing peers are marked as inactive. Those who will responf wil be swithc to active BroadcastDiscoweryReplay function in UNode
        dispatch_async(queue, {
            for peer in self.peers
            {
                self.peers[peer.0]?.active = false
            }
        })
        
        // Assemble Discovery Brodcast packet
        let discoveryBroadcastPacketHeader = UPacketHeader(from: self.id, to: broadcastNodeId, lifeTime: standardPacketLifeTime)
        let discoveryBroadcastPacketEnvelope = UPacketEnvelope(fromId: self.id, fromAddress: self.address, toId: broadcastNodeId, toAddress: unknownNodeAddress)
        let broadcastDiscovery=UPacketDiscoveryBroadcast()
        let broadcastDiscovetyCargo=UPacketType.DiscoveryBroadcast(broadcastDiscovery)
        let broadcastDiscoveryPacket=UPacket(inputHeader: discoveryBroadcastPacketHeader, inputEnvelope: discoveryBroadcastPacketEnvelope, inputCargo: broadcastDiscovetyCargo)
        
        // Deliver the packet to all node's interfaces
        for(_, interface) in enumerate(self.interfaces)
        {
            self.nodeStats.addNodeStatsEvent(StatsEvents.DiscoveryBroadcastSent)
            interface.sendPacketToNetwork(broadcastDiscoveryPacket)
        }
        
    }
    
    // Memory wipe-out to the post-initialised state
    func resetInternalData()
    {
        timeCounter=0
        peers = [UNodeID:UPeerDataRecord]()
        knownAddresses = [UNodeID:UMemoryIdAddressRecord]()
        knownIDs  = [String:UMemoryNameIdRecord]()
        router.reset()
    }
    
    
    
    // Node adddress calculation as the avarge address of connected peers
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
    
    // Internal Node's timer
    var nodeTime:UInt64
        {
        get
        {
            return    ++self.timeCounter
        }
        
    }
    
    // Human readble object description
    var txt:String
        {
            return "Node \(self.id.txt) "
    }
    
    
    
}



