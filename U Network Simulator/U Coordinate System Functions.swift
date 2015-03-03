//
//  U Coordinate System Functions.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/17/15.

//

import Foundation

func  convertFlotingPointCoordinatesToUInt64(coordinates:CoordinatesFloatDegreesAndAltitude) -> (latitude:UInt64, longitude:UInt64, altitude: UInt64)
{
    let scale:Float64 = pow(2, 48)
    
    let newLatitudeFloat = scale * (Float64(coordinates.latitude.value + 90.0) / Float64(180.0))
    let newLatitude = UInt64(newLatitudeFloat)
    
    let newLongitudeFloat = scale * (Float64(coordinates.longitude.value + 180) / Float64(360.0))
    let newLongitude = UInt64(newLongitudeFloat)
    
    let scaleAltitude:Float64 = pow(2, 32)
    let newAltitudeFloat = scaleAltitude * (Float64(coordinates.altitude.value + 100000) / Float64(400100000))
    let newAltitude = UInt64(newAltitudeFloat)
    
    return(latitude:newLatitude, longitude:newLongitude, altitude: newAltitude)
}

func convertUInt64CoordinatesToFlotingPoint(inputLatitude:UInt64, inputLongitude:UInt64, inputAltitude:UInt64) -> (CoordinatesFloatDegreesAndAltitude)
{

    let latitude:Float64=( Float64(inputLatitude) / (pow(2, 48)) * 180) - 90
    let longitude:Float64=(Float64(inputLongitude) / (pow(2, 48)) * 360) - 180
    let altitude:Float64=(Float64(inputAltitude) / (pow(2, 32)) * 400100000) - 100000




let result=CoordinatesFloatDegreesAndAltitude(inputLatitude:ULatitudeFloat(input: latitude), inputLongitude:ULongitudeFloat(input: longitude), inputAltitude:UAltitudeFloat(input: altitude))
    
    return(result)

}
