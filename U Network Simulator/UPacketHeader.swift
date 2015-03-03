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



}
struct UPacketEnvelopeLenghtAndChecksum {
    
    var data:UInt64
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
    
    
}

struct UPacketHeaderLifeCounterAndFlags {

    var data:UInt64
    
/*
    
   lower 32 bits for life counter

  middle  16 bits for packet type
    
    
   highest 16 bits for network signaling
    1 bit - lookup request attached after header
    
    */
    
    
    func lifeCounter() -> UInt64
    {
        return (self.data & 0x00000000FFFFFFFF)
    }
    
    mutating  func increaseLifeCounter()
    {
        if(self.data & 0x00000000FFFFFFFF <  0x00000000FFFFFFFF)
        {
            self.data++
        }
    }
    
    func isLookUpRequestAttachedFlag () -> Bool
    {
        if (self.data & uPacketHeaderLookUpRequestBitMask > 0)
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
            self.data = self.data | uPacketHeaderLookUpRequestBitMask
        }
        else
        {
            self.data = self.data & (~uPacketHeaderLookUpRequestBitMask)
        }
    
    
    }
    
    
    

}


let uPacketHeaderLookUpRequestBitMask:UInt64 = 1<<63



