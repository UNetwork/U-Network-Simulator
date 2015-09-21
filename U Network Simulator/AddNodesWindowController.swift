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
    
    
    @IBOutlet weak var meshLat: NSTextField!
    @IBOutlet weak var meshLong: NSTextField!
    @IBOutlet weak var meshAlt: NSTextField!
    @IBOutlet weak var meshX: NSTextField!
    @IBOutlet weak var meshY: NSTextField!
    @IBOutlet weak var meshZ: NSTextField!
    
    @IBOutlet weak var randomSwitch: NSButton!
    
    @IBAction func createMesh(sender: AnyObject) {
        
        let meshLatValue = Float64(meshLat.floatValue)
        let meshLongValue = Float64(meshLong.floatValue)
        let meshAltValue = Float64(meshAlt.floatValue)
        let meshXValue = UInt32(meshX.integerValue)
        let meshYValue = UInt32(meshY.integerValue)
        let meshZValue = UInt32(meshZ.integerValue)
        
        let randomize = self.randomSwitch.state
        
        let meshLocation = CoordinatesFloatDegreesAndAltitude(inputLatitude: meshLatValue, inputLongitude: meshLongValue, inputAltitude: meshAltValue)
        let convertedMeshLocation = convertFlotingPointCoordinatesToUInt64(meshLocation)
        
        let networkMeshAddress = UNodeAddress(inputLatitude: convertedMeshLocation.latitude, inputLongitude: convertedMeshLocation.longitude, inputAltitude: convertedMeshLocation.altitude)
        
        let distance = wirelessInterfaceRange / 2
        
        
        createNodeMesh(meshXValue, columns: meshYValue, layers: meshZValue, distance: distance, position: networkMeshAddress, random: (randomize == 0 ? false : true))
        self.window!.close()
    }
    
    
    @IBAction func addNodes(sender: AnyObject)
    {
        let fromLatValue = ULatitudeFloat(input: Float64(fromLat.stringValue.floatValue))
        let fromLongValue = ULongitudeFloat (input: Float64(fromLong.stringValue.floatValue))
        let fromAltValue = UAltitudeFloat(input: Float64(fromAlt.stringValue.floatValue))
        
        let toLatValue = ULatitudeFloat(input: Float64(toLat.stringValue.floatValue))
        let toLongValue = ULongitudeFloat(input: Float64(toLong.stringValue.floatValue))
        let toAltValue = UAltitudeFloat(input: Float64(toAlt.stringValue.floatValue))
        
        let numberValue = Int(number.stringValue)
        
        let position = CoordinatesFloatDegreesAndAltitude(inputLatitude: fromLatValue, inputLongitude: fromLongValue, inputAltitude: fromAltValue)
        let convertedPosition = convertFlotingPointCoordinatesToUInt64(position)
        
        let deltaPosition = CoordinatesFloatDegreesAndAltitude(inputLatitude: toLatValue, inputLongitude: toLongValue, inputAltitude: toAltValue)
        let convertedDeltaPosition = convertFlotingPointCoordinatesToUInt64(deltaPosition)
        
        let deltaLat = unsignedDifference(convertedPosition.latitude, b: convertedDeltaPosition.latitude)
        let deltaLong = unsignedDifference(convertedPosition.longitude, b: convertedDeltaPosition.longitude)
        let deltaAlt = unsignedDifference(convertedPosition.altitude, b: convertedDeltaPosition.altitude)

        if let repetitions = numberValue
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

    override func windowDidLoad()
    {
        super.windowDidLoad()
    }
    func createNodeMesh(rows:UInt32, columns:UInt32, layers:UInt32, distance:UInt64,  position:UNodeAddress, random:Bool)
    {
        
        let dist=UInt32(distance)
        var distLat:UInt32 = 0
        var distLong:UInt32 = 0
        var distAlt:UInt32 = 0
        
        for r in 1...rows
        {
            for c in 1...columns
            {
                for l in 1...layers
                {
                    if(random)
                    {
                        distLat = arc4random_uniform(dist)
                        distLong = arc4random_uniform(dist)
                        distAlt = arc4random_uniform(dist)
                    }
                    let nodePosition=USimulationRealLocation(inputLatitude: (UInt64(r-1) * distance) + position.latitude + UInt64(distLat), inputLongitude: (UInt64(c-1) * distance) + position.longitude + UInt64(distLong), inputAltitude: (UInt64(l-1) * distance) + position.altitude + UInt64(distAlt))
                    
                    simulator.addWirelessNode(nodePosition)
                }
            }
        }
        /*
        for  aNode in simulator.simulationNodes.values
        {
        aNode.node.setupAndStart()
        }
        log (5,"Initial setup done")
        
        for  aNode in simulator.simulationNodes.values
        {
        aNode.node.populateOwnData()
        }
        
        log (5,"Data populated")
        */
        
    }
}


