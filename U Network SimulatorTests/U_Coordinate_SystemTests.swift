//
//  U_Coordinate_SystemTests.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/18/15.
//

import Cocoa
import XCTest

class U_Coordinate_SystemTests: XCTestCase {
    
    func testULatitudeFloat()
    {
        
        var testVariable=ULatitudeFloat(input: 22.33)
        XCTAssert(testVariable.value == 22.33, "Initalistaion with proper data failed")
        
        testVariable=ULatitudeFloat(input: -25.7523)
        XCTAssert(testVariable.value == -25.7523, "Initalistaion with proper data failed")
        
        testVariable=ULatitudeFloat(input: 0.0)
        XCTAssert(testVariable.value == 0.0, "Initalistaion with proper data failed")
        
        testVariable=ULatitudeFloat(input: -254.7523)
        XCTAssert(testVariable.value == -90.0, "Initalistaion with data below limit failed")
        
        testVariable=ULatitudeFloat(input: 252342342344.7523)
        XCTAssert(testVariable.value == 90, "Initalistaion with data over limit failed")
    }
    
    func testULongitudeFloat()
    {
        
        var testVariable=ULongitudeFloat(input: 22.33)
        XCTAssert(testVariable.value == 22.33, "Initalistaion with proper data failed")
        
        testVariable=ULongitudeFloat(input: -25.7523)
        XCTAssert(testVariable.value == -25.7523, "Initalistaion with proper data failed")
        
        testVariable=ULongitudeFloat(input: 0.0)
        XCTAssert(testVariable.value == 0.0, "Initalistaion with proper data failed")
        
        testVariable=ULongitudeFloat(input: -181)
        XCTAssert(testVariable.value == 179, "Initalistaion with data below limit failed")
        
        testVariable=ULongitudeFloat(input: 181)
        XCTAssert(testVariable.value == -179, "Initalistaion with data over limit failed")
        
        
    }
    
    func testUAltitudeFloat()
    {
        
        var testVariable=UAltitudeFloat(input: 22.33)
        XCTAssert(testVariable.value == 22.33, "Initalistaion with proper data failed")
        
        testVariable=UAltitudeFloat(input: -25.7523)
        XCTAssert(testVariable.value == -25.7523, "Initalistaion with proper data failed")
        
        testVariable=UAltitudeFloat(input: 0)
        XCTAssert(testVariable.value == 0, "Initalistaion with proper data failed")
        
        testVariable=UAltitudeFloat(input: -123123254.7523)
        XCTAssert(testVariable.value == -100000.0, "Initalistaion with data below limit failed")
        
        testVariable=UAltitudeFloat(input: 25232342342344.7523)
        XCTAssert(testVariable.value == 400000000.0, "Initalistaion with data over limit failed")
        
        
    }
    
    func testCoordinatesFloat64DegreesAndAltitude()
    {
        
        var testVariable=CoordinatesDDMMSSAndAltitude(inputLatitudeDD: 0, inputLatitudeMM: 0, inputLatitudeSS: 0, inputLongitudeDD: 0, inputLongitudeMM: 0, inputLongitudeSS: 0, inputAltitude: UAltitudeFloat(input: 0))
        
        var testVariable2=CoordinatesFloatDegreesAndAltitude(coordinates: testVariable)
        
        let treeInts = convertFlotingPointCoordinatesToUInt64(testVariable2)
        
        XCTAssert(testVariable2.latitude.value == 0, "Initalistaion with proper data failed")
        XCTAssert(testVariable2.longitude.value == 0, "Initalistaion with proper data failed")
        XCTAssert(testVariable2.altitude.value == 0, "Initalistaion with proper data failed")
        
        
        let properLatitudeFloat:Float64 = pow(2,47)
        let properLatitudeInt64:UInt64 = UInt64(properLatitudeFloat)
        
        XCTAssert(treeInts.latitude == properLatitudeInt64, "conversion of latitude to UInt64 failed")
        
        let properLongitudeFloat:Float64 = pow(2,47)
        let properLongitudeInt64 = UInt64(properLongitudeFloat)
        XCTAssert(treeInts.longitude == properLongitudeInt64, "conversion of longitude to UInt64 failed")
        
        
        let properAltitudeFloat:Float64 = pow(2,32)*(100000/400100000)
        let properAltitudeInt64 = UInt64(properAltitudeFloat)
        XCTAssert(treeInts.altitude == properAltitudeInt64, "conversion of altitude to UInt64 failed")
        
        
        testVariable=CoordinatesDDMMSSAndAltitude(inputLatitudeDD: 1, inputLatitudeMM: 1, inputLatitudeSS: 1, inputLongitudeDD: 1, inputLongitudeMM: 1, inputLongitudeSS: 1, inputAltitude: UAltitudeFloat(input: 1))
        testVariable2=CoordinatesFloatDegreesAndAltitude(coordinates: testVariable)
        var properValue:Float64=1.0 + (1.0/60) + (1.0/3600)
        XCTAssert(testVariable2.latitude.value == properValue, "Initalistaion with proper data failed")
        XCTAssert(testVariable2.longitude.value == properValue, "Initalistaion with proper data failed")
        XCTAssert(testVariable2.altitude.value == 1, "Initalistaion with proper data failed")
        
        
        testVariable=CoordinatesDDMMSSAndAltitude(inputLatitudeDD: -1, inputLatitudeMM: 1, inputLatitudeSS: 1, inputLongitudeDD: -1, inputLongitudeMM: 1, inputLongitudeSS: 1, inputAltitude: UAltitudeFloat(input: 1))
        
        testVariable2=CoordinatesFloatDegreesAndAltitude(coordinates: testVariable)
        properValue = -1.0 - (1.0/60) - (1.0/3600)
        XCTAssert(testVariable2.latitude.value == properValue, "Initalistaion with proper data failed")
        XCTAssert(testVariable2.longitude.value == properValue, "Initalistaion with proper data failed")
        
        testVariable=CoordinatesDDMMSSAndAltitude(inputLatitudeDD: 90, inputLatitudeMM: 1, inputLatitudeSS: 1, inputLongitudeDD: -180, inputLongitudeMM: 1, inputLongitudeSS: 0, inputAltitude: UAltitudeFloat(input: 1))
        testVariable2=CoordinatesFloatDegreesAndAltitude(coordinates: testVariable)
        XCTAssert(testVariable2.latitude.value == 90, "Initalistaion with  data out of limits failed")
        XCTAssert(testVariable2.longitude.value == 179.0 + 59.0/60.0, "Initalistaion with  data  out of limits failed")
        
        testVariable=CoordinatesDDMMSSAndAltitude(inputLatitudeDD: 90, inputLatitudeMM: 1, inputLatitudeSS: 1, inputLongitudeDD: 180, inputLongitudeMM: 1, inputLongitudeSS: 1, inputAltitude: UAltitudeFloat(input: 1))
        testVariable2=CoordinatesFloatDegreesAndAltitude(coordinates: testVariable)
        properValue = -179.0 - 58.0/60.0 - 59.0/3600
        XCTAssert(testVariable2.latitude.value == 90, "Initalistaion with  data  out of limits failed")
        XCTAssert(testVariable2.longitude.value == properValue, "Initalistaion with  data  out of limits failed")
        
    }
    
    func testCoordinatesDDMMSSAndAltitude()
    {
        
        var testVariable=CoordinatesDDMMSSAndAltitude(inputLatitudeDD: 43, inputLatitudeMM: 35, inputLatitudeSS: 21.54, inputLongitudeDD: -23, inputLongitudeMM: 11, inputLongitudeSS: 32.772, inputAltitude: UAltitudeFloat(input: 1.23))
        XCTAssert(testVariable.latitudeDD == 43, "Initalistaion with proper data failed")
        XCTAssert(testVariable.latitudeMM == 35, "Initalistaion with proper data failed")
        XCTAssert(testVariable.latitudeSS == 21.54, "Initalistaion with proper data failed")
        XCTAssert(testVariable.longitudeDD == -23, "Initalistaion with proper data failed")
        XCTAssert(testVariable.longitudeMM == 11, "Initalistaion with proper data failed")
        XCTAssert(testVariable.longitudeSS == 32.772, "Initalistaion with proper data failed")
        XCTAssert(testVariable.altitude.value == 1.23, "Initalistaion with proper data failed")
        
        
        testVariable=CoordinatesDDMMSSAndAltitude(inputLatitudeDD: 91, inputLatitudeMM: 79, inputLatitudeSS: 60.01, inputLongitudeDD: 181, inputLongitudeMM: 443, inputLongitudeSS: 66, inputAltitude: UAltitudeFloat(input: 8888888888888888))
        XCTAssert(testVariable.latitudeDD == 90, "Initalistaion with data over limit failed")
        XCTAssert(testVariable.latitudeMM == 0, "Initalistaion with data over limit failed")
        XCTAssert(testVariable.latitudeSS == 0, "Initalistaion with data over limit failed")
        XCTAssert(testVariable.longitudeDD == -179, "Initalistaion with data over limit failed")
        XCTAssert(testVariable.longitudeMM == 0, "Initalistaion with data over limit failed")
        XCTAssert(testVariable.longitudeSS == 0, "Initalistaion with data over limit failed")
        XCTAssert(testVariable.altitude.value == 400000000.0, "Initalistaion with data over limit failed")
        
        
        
        testVariable=CoordinatesDDMMSSAndAltitude(inputLatitudeDD: -91, inputLatitudeMM: -3, inputLatitudeSS: -60.01, inputLongitudeDD: -181, inputLongitudeMM: -3, inputLongitudeSS: 60.00000001, inputAltitude: UAltitudeFloat(input: -888888888888888))
        XCTAssert(testVariable.latitudeDD == -90, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.latitudeMM == 0, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.latitudeSS == 0, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.longitudeDD == 179, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.longitudeMM == 0, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.longitudeSS == 0, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.altitude.value == -100000.0, "Initalistaion with data below limit failed")
        
        testVariable=CoordinatesDDMMSSAndAltitude(inputLatitudeDD: 90, inputLatitudeMM: 1, inputLatitudeSS: 1, inputLongitudeDD: 180, inputLongitudeMM: 1, inputLongitudeSS: 1, inputAltitude: UAltitudeFloat(input: -888888888888888))
        XCTAssert(testVariable.latitudeDD == 90, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.latitudeMM == 0, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.latitudeSS == 0, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.longitudeDD == -179, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.longitudeMM == 58, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.longitudeSS == 59, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.altitude.value == -100000.0, "Initalistaion with data below limit failed")
        
        testVariable=CoordinatesDDMMSSAndAltitude(inputLatitudeDD: 90, inputLatitudeMM: 1, inputLatitudeSS: 1, inputLongitudeDD: 180, inputLongitudeMM: 1, inputLongitudeSS: 0, inputAltitude: UAltitudeFloat(input: 1))
        XCTAssert(testVariable.latitudeDD == 90, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.latitudeMM == 0, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.latitudeSS == 0, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.longitudeDD == -179, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.longitudeMM == 59, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.longitudeSS == 00, "Initalistaion with data below limit failed")
        
        
        testVariable=CoordinatesDDMMSSAndAltitude(inputLatitudeDD: 90, inputLatitudeMM: 1, inputLatitudeSS: 1,
            inputLongitudeDD: -180, inputLongitudeMM: 1, inputLongitudeSS: 1, inputAltitude: UAltitudeFloat(input: 1))
        XCTAssert(testVariable.latitudeDD == 90, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.latitudeMM == 0, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.latitudeSS == 0, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.longitudeDD == 179, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.longitudeMM == 58, "Initalistaion with data below limit failed")
        XCTAssert(testVariable.longitudeSS == 59, "Initalistaion with data below limit failed")
        
        
    }
    
    func testFloatToInt64ConversionAndViceVersa()
        
    {
        var latint = random64() &  0x0000ffffffffffff
        var longint = random64() & 0x0000ffffffffffff
        var altint = random64() &  0x00000000ffffffff
        
        for i in 1...1000 {
            
            latint = random64() &  0x0000ffffffffffff
            longint = random64() & 0x0000ffffffffffff
            altint = random64() &  0x00000000ffffffff
            
            
            var  converted = convertUInt64CoordinatesToFlotingPoint(latint, inputLongitude: longint, inputAltitude: altint)
            var reconverted=convertFlotingPointCoordinatesToUInt64(converted)
            XCTAssert(reconverted.latitude > latint - 2 && reconverted.latitude < latint + 2, "Latitude reconversion failed")
            
            XCTAssert(reconverted.longitude > longint - 2   && reconverted.longitude < longint + 2, "Longitude reconversion failed")
            XCTAssert(reconverted.altitude > altint - 2 && reconverted.altitude < altint + 2, "Altitude reconversion failed")
            
            var converted2=convertUInt64CoordinatesToFlotingPoint(reconverted.latitude, inputLongitude: reconverted.longitude, inputAltitude: reconverted.altitude)
            var reconverted2=convertFlotingPointCoordinatesToUInt64(converted2)
            XCTAssert(reconverted2.latitude > latint - 2 && reconverted.latitude < latint + 2, "Latitude reconversion failed")
            XCTAssert(reconverted2.longitude > longint - 2   && reconverted.longitude < longint + 2, "Longitude reconversion failed")
            XCTAssert(reconverted2.altitude > altint - 2 && reconverted.altitude < altint + 2, "Altitude reconversion failed")
            
            
            
        }
        
    }
    
    
    
    
    
}



































































