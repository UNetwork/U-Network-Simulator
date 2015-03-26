//
//  Global Objects.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/20/15.
//

import Foundation

var processingMode = ProcessingType.Serial

var useCache = true

 let queueSerial = dispatch_queue_create("Serial Queue", DISPATCH_QUEUE_SERIAL)
 let queueConcurrent = dispatch_queue_create("Concurrent Queue", DISPATCH_QUEUE_CONCURRENT)

enum ProcessingType{
    case Stright, Serial, Paralel
}

// some orientation points for data search and distribition packets


let aboveNorthPoleLeft = UNodeAddress(inputLatitude: maxLatitude, inputLongitude:  UInt64(0), inputAltitude: maxAltitude)
let belowNorthPoleLeft = UNodeAddress(inputLatitude: maxLatitude, inputLongitude:  UInt64(0), inputAltitude: UInt64(0))
let aboveSouthPoleLeft = UNodeAddress(inputLatitude: UInt64(0), inputLongitude:  UInt64(0), inputAltitude: maxAltitude)
let belowSouthPoleLeft = UNodeAddress(inputLatitude: UInt64(0), inputLongitude: UInt64(0), inputAltitude: UInt64(0))

let aboveNorthPoleRight = UNodeAddress(inputLatitude: maxLatitude, inputLongitude:  maxLongitude, inputAltitude: maxAltitude)
let belowNorthPoleRight = UNodeAddress(inputLatitude: maxLatitude, inputLongitude:  maxLongitude, inputAltitude: UInt64(0))
let aboveSouthPoleRight = UNodeAddress(inputLatitude: UInt64(0), inputLongitude:  maxLongitude, inputAltitude: maxAltitude)
let belowSouthPoleRight = UNodeAddress(inputLatitude: UInt64(0), inputLongitude: maxLongitude, inputAltitude: UInt64(0))

let searchStoreAddresses = [aboveNorthPoleLeft, belowNorthPoleLeft, aboveSouthPoleLeft, belowNorthPoleLeft, aboveNorthPoleRight, belowNorthPoleRight, aboveSouthPoleRight, belowSouthPoleRight]


