//
//  USimulationRealLocation.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/10/15.
//

import Foundation


struct USimulationRealLocation
{
    
    private    var privateLatitude:UInt64
    private    var privateLongitude:UInt64
    private    var privateAltitude:UInt64
    
    init(inputLatitude:UInt64, inputLongitude:UInt64, inputAltitude:UInt64)
    {
        
        
        privateLatitude=inputLatitude
        privateLongitude=inputLongitude
        privateAltitude=inputAltitude
        
        
        log(0, "A URealLocation has been created with three UInt64s as argument. The data is:  \(self.privateLatitude) \(self.privateLongitude) \(self.privateAltitude)")
        
        if(!(inputLatitude < 1 << 48 && inputLongitude < 1 << 48 && inputAltitude < 1 << 32))
            
        {
            log(7,"URealLocation tree UInt64s init data correction occured")
            
            if(inputLatitude >= 1 << 48)
            {
                privateLatitude=UInt64((1 << 48) - 1)
            }
            if(inputLongitude >= 1 << 48)
            {
                privateLongitude = inputLongitude % (1 << 48)
            }
            if(inputAltitude >= 1 << 32)
            {
                privateAltitude=UInt64(( 1 << 32) - 1)
            }
        }
        
    }
    
    mutating func moveBy(moveLatitude:Int64, moveLongitude: Int64, moveAltitude: Int64)
    {
        if(moveLatitude < 0)
        {
            if(UInt64(abs(moveLatitude)) > self.privateLatitude)
            {
                self.privateLatitude = 0
            }
            else
            {
                self.privateLatitude = self.privateLatitude - UInt64(abs(moveLatitude))
            }
        }
        else
        {
            self.privateLatitude = self.privateLatitude + UInt64(moveLatitude)
            if(self.privateLatitude >= 1 >> 48)
            {
                self.privateLatitude = (1 << 48) - 1
            }
        }
        
        if(moveLongitude < 0)
        {
            if(UInt64(abs(moveLongitude)) > self.privateLongitude)
            {
                self.privateLongitude = (1 << 48) - (UInt64(abs(moveLongitude)) - self.privateLongitude)
            }
            else
            {
                self.privateLongitude = self.privateLongitude - UInt64(abs(moveLongitude))
            }
        }
        else
        {
            self.privateLongitude = self.privateLatitude + UInt64(moveLongitude)
            if(self.privateLongitude >= 1 >> 48)
            {
                self.privateLongitude = self.privateLongitude % (1 << 48)
            }
            
        }
        
        
        if(moveAltitude < 0)
        {
            if(UInt64(abs(moveAltitude)) > self.privateAltitude)
            {
                self.privateAltitude = 0
            }
            else
            {
                self.privateAltitude = self.privateLatitude - UInt64(abs(moveAltitude))
            }
        }
        else
        {
            self.privateAltitude = self.privateAltitude + UInt64(moveAltitude)
            if(self.privateAltitude >= 1 >> 32)
            {
                self.privateAltitude = (1 << 32) - 1
            }
        }
        
        
        
        
    }
    
    var latitude:UInt64 {return privateLatitude}
    
    var longitude:UInt64{return privateLongitude}
    
    var altitude:UInt64{return privateAltitude}
    
    
}