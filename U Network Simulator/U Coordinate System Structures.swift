//
//  U Coordinate System Structures.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/17/15.
//

import Foundation



// ULatitudeFloat is always -90 <= latitude <= 90 degrees in Float
struct ULatitudeFloat
{
    
    private var privateValue:Float64
    
    init (input:Float64)
    {
        
        if(input >= -90.0 && input <= 90 )
        {
            self.privateValue = input
        }
        else
        {
            log(7,text: "ULattitudeFloat input out of range: \(input) of -90...90. Closest value taken.")
            if(input < -90.0)
            {
                self.privateValue = -90.0
            }
            else
            {
                self.privateValue=90
                
            }
        }
    }
    
    var value:Float64
    {
        return(privateValue)
    }
}

// ULongitudeFloat is alwas -180 <= longitude <= 180 degrees in Float
struct ULongitudeFloat
{
  private   var privateValue:Float64
    
    init(input:Float64)
    {
        if(input >= -180.0 && input <= 180)
        {
            self.privateValue=input
        }
        else
        {
            log(7,text: "ULongitudeFloat input out of range: \(input) of -180...180. Value adjusted")
            if(input < -180.0)
            {
                self.privateValue = (input % 180.0) + 180.0
            }
            else
            {
                self.privateValue = (input % 180) - 180.0
            }
        }
    }
    
    var value:Float64
    {
        return(privateValue)
    }
}



// UAltitudeFloat is Float in meters above sea level. -100,000.00 <= altitude 400,000,000
struct UAltitudeFloat
{
   private  var privateValue:Float64
    
    init (input:Float64){
        if(input >= -100000.0 && input <= 400000000.0)
        {
            self.privateValue=input
        }
        else
        {
            log(7,text: "UAltitudeFloat input out of range: \(input) of -100,000.00...400,000,000. Closest value taken.")
            if(input < -100000.0)
            {
                self.privateValue = -100000.0
            }
            else
            {
                self.privateValue = 400000000.0
            }
        }
    }
    
    var value:Float64
    {
        return(privateValue)
    }
    
}

struct CoordinatesDDMMSSAndAltitude
{
    
   private  var privateLatitudeDD:Int
   private  var privateLatitudeMM:Int
 private    var privateLatitudeSS:Float64
    
  private   var privateLongitudeDD:Int
 private    var privateLongitudeMM:Int
 private    var privateLongitudeSS:Float64
    
    var altitude:UAltitudeFloat
    
    init (inputLatitudeDD:Int, inputLatitudeMM:Int, inputLatitudeSS:Float64, inputLongitudeDD:Int, inputLongitudeMM:Int, inputLongitudeSS:Float64, inputAltitude:UAltitudeFloat)
    {
  
        self.altitude=inputAltitude

        
        // Latitude data verification
        
        if(inputLatitudeMM >= 0 && inputLatitudeMM <= 59)
        {
            self.privateLatitudeMM = inputLatitudeMM
            
        }
        else
        {
            log(7,text: "CoordinatesDDMMSSAndAltitude latitudeMM input out of range: \(inputLatitudeMM) of 0...59. Zero value taken.")
            self.privateLatitudeMM = 0
        }
        
        if(inputLatitudeSS >= 0 && inputLatitudeSS < 60)
        {
            self.privateLatitudeSS=inputLatitudeSS
        }
        else
        {
            log(7,text: "CoordinatesDDMMSSAndAltitude latitudeSS input out of range: \(inputLatitudeSS) of 0.00..<60.0 Zero value taken.")
            self.privateLatitudeSS=0
            
        }


        if(inputLatitudeDD > -90 && inputLatitudeDD < 90)
        {
            self.privateLatitudeDD=inputLatitudeDD
        }
        else
        {
            log(7,text: "CoordinatesDDMMSSAndAltitude latitudeDD input out of range: \(inputLatitudeDD) of -90...90. Closest value taken.")
            if(inputLatitudeDD <= -90)
            {
                self.privateLatitudeDD = -90
                self.privateLatitudeMM = 0
                self.privateLatitudeSS = 0.0
            }
            else
            {
                self.privateLatitudeDD = 90
                self.privateLatitudeMM = 0
                self.privateLatitudeSS = 0.0
            }
        }
        
        if(inputLongitudeMM >= 0 && inputLongitudeMM <= 59)
        {
            self.privateLongitudeMM = inputLongitudeMM
            
        }
        else
        {
            log(7,text: "CoordinatesDDMMSSAndAltitude LongitudeMM input out of range: \(inputLongitudeMM) of 0...59. Zero value taken.")
            self.privateLongitudeMM = 0
        }
        
        if(inputLongitudeSS >= 0 && inputLongitudeSS < 60)
        {
            self.privateLongitudeSS=inputLongitudeSS
        }
        else
        {
            log(7,text: "CoordinatesDDMMSSAndAltitude longitudeSS input out of range: \(inputLongitudeSS) of 0.00..<60.0 Zero value taken.")
            self.privateLongitudeSS=0
            
        }

        
        
        if(inputLongitudeDD > -180 && inputLongitudeDD < 180)
        {
            self.privateLongitudeDD=inputLongitudeDD
        }
        else
        {
            log(7,text: "CoordinatesDDMMSSAndAltitude LongitudeDD input out of range: \(inputLongitudeDD) of -180...180. Value adjusted")
            if(inputLongitudeDD <= -180)
            {
                self.privateLongitudeDD = (inputLongitudeDD % 180) + 180
                if (privateLongitudeMM > 0 || privateLongitudeSS > 0)
                {
                    privateLongitudeDD--
                    
                   if( privateLongitudeSS > 0)
                   {
                    privateLongitudeSS = 60 - privateLongitudeSS
                    privateLongitudeMM = 59 - privateLongitudeMM
                    }
                    
                    else
                   {
                    privateLongitudeMM = 60 - privateLongitudeMM

                    }
                }
            }
            else
            {
                self.privateLongitudeDD = (inputLongitudeDD % 180) - 180
                if (privateLongitudeMM > 0 || privateLongitudeSS > 0)
                {
                    privateLongitudeDD++
                    if( privateLongitudeSS > 0)
                    {
                        privateLongitudeSS = 60 - privateLongitudeSS
                        privateLongitudeMM = 59 - privateLongitudeMM
                        
                    }
                    else
                    {
                        privateLongitudeMM = 60 - privateLongitudeMM
                        
                    }
                }
            }
        }
    }
    
    var latitudeDD:Int
    {
        return privateLatitudeDD
    }
    var latitudeMM:Int
    {
        return privateLatitudeMM
    }
    var latitudeSS:Float64
    {
        return privateLatitudeSS
    }
    
    var longitudeDD:Int
    {
        return privateLongitudeDD
    }
    var longitudeMM:Int
    {
        return privateLongitudeMM
    }
    var longitudeSS:Float64
    {
        return privateLongitudeSS
    }
    
    
}



struct CoordinatesFloatDegreesAndAltitude
{
    var latitude:ULatitudeFloat
    var longitude:ULongitudeFloat
    var altitude:UAltitudeFloat
    
    init (inputLatitude:ULatitudeFloat, inputLongitude:ULongitudeFloat, inputAltitude:UAltitudeFloat){
    
    
    latitude=inputLatitude
        longitude=inputLongitude
        altitude=inputAltitude
    
    
    
    }
    
    init (inputLatitude:Float64, inputLongitude:Float64, inputAltitude:Float64)
    {
        latitude = ULatitudeFloat   (input: inputLatitude)
        longitude = ULongitudeFloat  (input: inputLongitude)
        altitude = UAltitudeFloat( input: inputAltitude)
        
    }
    
    
    
    init (coordinates:CoordinatesDDMMSSAndAltitude)
    {
        var latitudeSign:Float64 = 1
        var longitudeSign:Float64 = 1
        
        if(coordinates.latitudeDD < 0)
        {
            latitudeSign = -1.0
        }
        
        if(coordinates.longitudeDD < 0)
        {
            longitudeSign = -1.0
        }
        
        
        self.latitude=ULatitudeFloat(input: Float64(coordinates.latitudeDD) + latitudeSign * Float64(coordinates.latitudeMM) / 60.0 + latitudeSign * coordinates.latitudeSS / 3600)
        
        self.longitude = ULongitudeFloat(input: Float64(coordinates.longitudeDD) + longitudeSign * Float64(coordinates.longitudeMM) / 60.0 + longitudeSign * coordinates.longitudeSS / 3600)
        
        self.altitude=coordinates.altitude
        
        
    }
    
}

