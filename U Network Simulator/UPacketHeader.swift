//
//  UPacketHeader.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/20/15.
//

import Foundation

struct UPacketHeader
{
    var lenghtAndChecksum:UPacketHeaderLenghtAndChecksum
    var transmitedToUID:UNodeID
    var transmitedByUID:UNodeID
    var lifeCounterAndFlags:UPacketHeaderLifeCounterAndFlags
    
    
    init (from:UNodeID, to: UNodeID, lifeTime:UInt32)
    {
        
        transmitedToUID = to
        transmitedByUID = from
        lenghtAndChecksum = UPacketHeaderLenghtAndChecksum(fromId: from, toId: to)
        lifeCounterAndFlags = UPacketHeaderLifeCounterAndFlags(lifeCounter: lifeTime)
        
    }
    
    func replyHeader() -> UPacketHeader
    {
        return UPacketHeader(from: transmitedToUID, to: transmitedByUID, lifeTime: standardPacketLifeTime)
    }
    
    
}

struct UNetworkLookUpRequest
{
    var requester:UNodeID
    var requesterAddress:UNodeAddress
    var counter:UNetworkLookUpRequestTypeAndCounter
    
    
}

struct UNetworkLookUpRequestTypeAndCounter
{

    var data:UInt64
    
    /*
    
    hoop counter 8 bit
    request type 8 bit
    serial 48 bits
    
    
    */
    
}

struct UPacketEnvelope {

    var lenghtAndChecksum:UPacketEnvelopeLenghtAndChecksum
    var orginatedByUID:UNodeID
    var destinationUID:UNodeID
    var originAddress:UNodeAddress
    var destinationAddress:UNodeAddress
    var serial:UInt64
    
    init(fromId:UNodeID, fromAddress:UNodeAddress, toId:UNodeID, toAddress:UNodeAddress)
    {
        self.orginatedByUID=fromId
        self.originAddress=fromAddress
        self.destinationUID=toId
        self.destinationAddress=toAddress
        self.serial=random64()
        self.lenghtAndChecksum=UPacketEnvelopeLenghtAndChecksum(fromId: orginatedByUID, toId: destinationUID)
    }
    

    func replyEnvelope() -> UPacketEnvelope
    {
        var result=UPacketEnvelope(fromId: self.destinationUID, fromAddress: destinationAddress, toId: orginatedByUID, toAddress: originAddress)
        
        
               return result
    }

}


struct UPacketEnvelopeLenghtAndChecksum {
    
    var data:UInt64
    
    init (fromId:UNodeID, toId:UNodeID){
    
    data = UInt64((fromId.lenght - 1) + (toId.lenght - 1) * 4)
        
    
    
    }
    
    /*
    
    2 bits TransmitedToUID lenght (1-4)
    2 bits TransmitedByUID lenght (1-4)
    
    60 bit for checksum of following header bytes
    
    */
    
    
}



struct UPacketHeaderLenghtAndChecksum {
    
    var data:UInt64
    /*
    
    2 bits TransmitedToUID lenght (1-4)
    2 bits TransmitedByUID lenght (1-4)
    
    60 bit for checksum of following header bytes
    
    */
    init (fromId:UNodeID, toId:UNodeID){
        
        data = UInt64((fromId.lenght - 1) + (toId.lenght - 1) * 4)
        
        
        
    }
    
    
}

struct UPacketHeaderLifeCounterAndFlags {

    var data:UInt64
    
/*
    
   lower 32 bits for life counter

  middle  16 bits for packet type
    
    
   highest 16 bits for network signaling
    
    */
    
    let uPacketHeaderLookUpRequestBitmask:UInt64 = 1 << 63
    let uPacketHeaderGiveUpFlagBitmask:UInt64 = 1 << 62
    let uPacketHeaderConfirmationDeliveryBitmask:UInt64 = 1 << 61   // rejected delivery if true
    // some link quality here???
    
    init(lifeCounter:UInt32)
    {
        self.data=UInt64(lifeCounter)
    }
    
    
    func lifeCounter() -> UInt64
    {
        return (self.data & 0x00000000FFFFFFFF)
    }
    
    mutating  func decreaseLifeCounter()
    {
        if(self.data & 0x00000000FFFFFFFF >  0)
        {
            self.data--
        }
    }
    


    
    func isLookUpRequestAttached () -> Bool
    {
        if (self.data & uPacketHeaderLookUpRequestBitmask > 0)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    mutating func setLookUpRequestAttachedFlag (to: Bool)
    
    {
        if(to == true)
        {
            self.data = self.data | uPacketHeaderLookUpRequestBitmask
        }
        else
        {
            self.data = self.data & (~uPacketHeaderLookUpRequestBitmask)
        }
    
    
    }
    
    var isGiveUp: Bool
    {
        if(self.data & uPacketHeaderGiveUpFlagBitmask > 0)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    mutating func setGiveUpFlag (to:Bool)
    {
        
        if(to == true)
        {
            self.data = self.data | uPacketHeaderGiveUpFlagBitmask
        }
        else
        {
            self.data = self.data & (~uPacketHeaderGiveUpFlagBitmask)
        }

    }
    
    var replyConfirmationType:Bool
        {
            if(self.data & uPacketHeaderConfirmationDeliveryBitmask > 0)
            {
                return true
            }
            else
            {
                return false
            }

    }
    
    mutating func setConfirmationType (to:Bool)
    {
        if(to == true)
        {
            self.data = self.data | uPacketHeaderConfirmationDeliveryBitmask
        }
        else
        {
            self.data = self.data & (~uPacketHeaderConfirmationDeliveryBitmask)
        }

    }
    
    
    

}


let uPacketHeaderLookUpRequestBitmask:UInt64 = 1 << 63
let uPacketHeaderGiveUpFlagBitmask:UInt64 = 1 << 62
let uPacketHeaderConfirmationDeliveryBitmask:UInt64 = 1 << 61   // rejected delivery if true



