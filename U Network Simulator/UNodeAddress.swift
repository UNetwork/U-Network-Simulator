//
//  UStationAddress.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/10/15.
//

import Foundation
import Cocoa


/*
This is structure for holding Node position in 3-d space. The position is encoded in 128 bits of data.

Latitude is encoded in lower 48 bits of data of low64Bits varble.

Longitude is encoded in lower 48 bits of data of high64Bits varble.

Altitude is encoded in 32 bits:
lower 16 bits are the highiest 16 bits of low64Bits,
higher 16 bits are the highiest 16 bits of high64Bits

The Longitude dimentions is wraped, latitude and altitude is not.

The beggining of coordinate system is:
latitude = 0 for 0°0'00''
longitude = 0 for 0°0'0''
altitude at sea level is 100 000

*/

let maxLatitude:UInt64 = 1<<48 - 1
let maxLongitude:UInt64 = 1<<48 - 1
let maxAltitude:UInt64 = 1<<32 - 1

struct UNodeAddress
{
    // Data
    
   private var low64Bits:UInt64
  private  var high64Bits:UInt64
    
    
    // Initalizers
    
    init(inputLatitude:UInt64, inputLongitude:UInt64, inputAltitude: UInt64)
    {
        
        if(inputLatitude < 1 << 48 && inputLongitude < 1 << 48 && inputAltitude < 1 << 32)
        {
            self.low64Bits=((0xFFFF & inputAltitude)<<48 ) | inputLatitude
            self.high64Bits=((0xFFFF0000 & inputAltitude)<<32 ) | inputLongitude
            log(0, "A UNodeAddress has been created with three UInt64s as argument. The data is:  \(self.latitude) \(self.longitude) \(self.altitude)")
        }
        else
        {
            log(7,"UNodeAddress tree UInt64s init data correction occured")
            var fixedLatitude = inputLatitude
            var fixedLongitude = inputLongitude
            var fixedAltitude = inputAltitude
            
            if(inputLatitude >= 1 << 48)
            {
                fixedLatitude=UInt64((1 << 48) - 1)
            }
            if(inputLongitude >= 1 << 48)
            {
                fixedLongitude = inputLongitude % (1 << 48)
            }
            if(inputAltitude >= 1 << 32)
            {
                fixedAltitude=UInt64(( 1 << 32) - 1)
            }
            
            self.low64Bits=((0xFFFF & fixedAltitude) << 48 ) | fixedLatitude
            self.high64Bits=((0xFFFF0000 & fixedAltitude) << 32 ) | fixedLongitude
        }

    }
    
    init ()  // unknown address
    {
        low64Bits=0
        high64Bits=0
        
    }
    
    init(address:UNodeAddress)
    {
        self.low64Bits=address.low64Bits
        self.high64Bits=address.high64Bits
        log(0, "A UNodeAddress has been created with UNodeAddress as argument. The data is:  \(self.latitude) \(self.longitude) \(self.altitude)")
    }
    
     
    
    // Data access functions
    
    var latitude: UInt64
    {
        return (self.low64Bits & latitudeAndLongitudeBitMask)
    }
    
    
    var longitude:UInt64
    {
        return (self.high64Bits & latitudeAndLongitudeBitMask)
    }
    
    
    var altitude:UInt64
    {
        let lowerAltBits = self.low64Bits >> 48
        let highAltBits = self.high64Bits >> 48
        let result = lowerAltBits | (highAltBits << 16)
        return (result)
    }
    
    var isUnknown:Bool
    {
            if(self.low64Bits == 0 && self.high64Bits == 0)
            {
                return true
            }
        return false
    }
    
    func positionToAddress(address:UNodeAddress) -> (deltaLat:Int64, deltaLong:Int64, deltaAlt:Int64)
    {
        var deltaLat = positionDifference(self.latitude, to: address.latitude)
        var deltaLong = positionDifference(self.longitude, to: address.longitude)
        var deltaAlt:Int64 = positionDifference(self.altitude, to: address.altitude)
        
        return(deltaLat, deltaLong, deltaAlt)
    }
    
    func positionDifference(from:UInt64, to:UInt64) -> Int64
    {
        var result:Int64
        
        if(from <= to)
        {
        result = Int64(to - from)
        }
        else
        {
            result = -(Int64(from - to))

        }
        
        
        return result
    }
    
}


let latitudeAndLongitudeBitMask:UInt64 = 0x0000ffffffffffff






































































