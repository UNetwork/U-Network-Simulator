//
//  TestingHelperFunctions.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 3/15/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Foundation





var exampleNodeAddress:UNodeAddress
{
    let addressF=CoordinatesFloatDegreesAndAltitude(inputLatitude: 51.0, inputLongitude: 17.0, inputAltitude: 130.0)
    
    let addressU=convertFlotingPointCoordinatesToUInt64(addressF)
    
    let nodeAddress=UNodeAddress(inputLatitude: addressU.latitude, inputLongitude: addressU.longitude, inputAltitude: addressU.altitude)
    
    return nodeAddress
}

var closeToExampleNodeAddress:UNodeAddress
{
    let lat = exampleNodeAddress.latitude + wirelessInterfaceRange / 8
    let long = exampleNodeAddress.longitude + wirelessInterfaceRange / 8
    let alt = exampleNodeAddress.altitude + wirelessInterfaceRange / 8
    return(UNodeAddress(inputLatitude: lat, inputLongitude: long, inputAltitude: alt))
}















