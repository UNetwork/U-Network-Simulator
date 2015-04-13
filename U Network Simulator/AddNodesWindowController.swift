//
//  AddNodesWindow.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/4/15.
//

import Foundation
import Cocoa


class AddNodesWindowController:NSWindowController
{
    
    
    @IBOutlet weak var fromLat: NSTextField!
    
    @IBOutlet weak var fromLong: NSTextField!
    
    @IBOutlet weak var fromAlt: NSTextField!
    
    
    @IBOutlet weak var toLat: NSTextField!
    
    @IBOutlet weak var toLong: NSTextField!
    
    
    @IBOutlet weak var toAlt: NSTextField!
    
    
    @IBOutlet weak var number: NSTextField!
    
    
    @IBAction func addNodes(sender: AnyObject)
    {
        let fromLatValue = ULatitudeFloat(input: Float64(fromLat.stringValue.floatValue))
        let fromLongValue = ULongitudeFloat (input: Float64(fromLong.stringValue.floatValue))
        let fromAltValue = UAltitudeFloat(input: Float64(fromAlt.stringValue.floatValue))
        
        let toLatValue = ULatitudeFloat(input: Float64(toLat.stringValue.floatValue))
        let toLongValue = ULongitudeFloat(input: Float64(toLong.stringValue.floatValue))
        let toAltValue = UAltitudeFloat(input: Float64(toAlt.stringValue.floatValue))
        
        let numberValue = number.stringValue.toInt()
        
        let position = CoordinatesFloatDegreesAndAltitude(inputLatitude: fromLatValue, inputLongitude: fromLongValue, inputAltitude: fromAltValue)
        let convertedPosition = convertFlotingPointCoordinatesToUInt64(position)
        
        let deltaPosition = CoordinatesFloatDegreesAndAltitude(inputLatitude: toLatValue, inputLongitude: toLongValue, inputAltitude: toAltValue)
        let convertedDeltaPosition = convertFlotingPointCoordinatesToUInt64(deltaPosition)
        
        let deltaLat = unsignedDifference(convertedPosition.latitude, convertedDeltaPosition.latitude)
        let deltaLong = unsignedDifference(convertedPosition.longitude, convertedDeltaPosition.longitude)
        let deltaAlt = unsignedDifference(convertedPosition.altitude, convertedDeltaPosition.altitude)

        
        if let repetitions=numberValue
        {
            for index in 1...repetitions
            {

                let finalLatitude = deltaLat == 0 ? convertedPosition.latitude : convertedPosition.latitude &+ (random64() % deltaLat)
                let finalLongitude = deltaLong == 0 ? convertedPosition.longitude : convertedPosition.longitude &+ (random64() % deltaLong)
                let finalAltitude = deltaAlt == 0 ? convertedPosition.altitude : convertedPosition.altitude &+ (random64() % deltaAlt)
                
                let nodePosition = USimulationRealLocation(inputLatitude: finalLatitude, inputLongitude: finalLongitude, inputAltitude: finalAltitude)
                
                simulator.addWirelessNode(nodePosition)

                
            }
        }
        
        
        
    }

    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        
        
        
    }
    
}
