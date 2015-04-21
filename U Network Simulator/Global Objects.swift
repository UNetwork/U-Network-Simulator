//
//  Global Objects.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/20/15.
//

import Foundation
import Cocoa

var processingMode = ProcessingType.Serial

var useCache = false

 let queueSerial = dispatch_queue_create("Serial Queue", DISPATCH_QUEUE_SERIAL)
 let queueConcurrent = dispatch_queue_create("Concurrent Queue", DISPATCH_QUEUE_CONCURRENT)

enum ProcessingType{
    case Stright, Serial, Paralel
}

var visiblePackets=Array(count: 17, repeatedValue: true)
var heartBeatPeersValue=0
var heartBeatNameStoreValue=0
var heartBeatAddressStoreValue=0

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


let packetColors = [
    CGColorCreateGenericRGB(0, 0, 0, 0.2),
    CGColorCreateGenericRGB(0.25,  0,  0,  1),
    CGColorCreateGenericRGB(0.25,  0.25,  0,  1),
    CGColorCreateGenericRGB(1,  0.75,  0.25,  1),
    CGColorCreateGenericRGB(0,  0.25,  0,  1),
    CGColorCreateGenericRGB(0,  0,  0.25,  1),
    CGColorCreateGenericRGB(0.0,  0.25,  0.25,  1),
    CGColorCreateGenericRGB(0.25,  0.5,  0,  1),
    CGColorCreateGenericRGB(0.25,  0,  0.5,  1),
    CGColorCreateGenericRGB(0.5,  0,  0,  1),
    CGColorCreateGenericRGB(0.5,  0.5,  0,  1),
    CGColorCreateGenericRGB(0.5,  0,  0.5,  1),
    CGColorCreateGenericRGB(1,  0.35,  0,  1),
    CGColorCreateGenericRGB(0.1,  0.73,  1,  1),
    CGColorCreateGenericRGB(0.75,  0.5,  0,  1),
    CGColorCreateGenericRGB(0.75,  0.5,  0.5,  1),
    CGColorCreateGenericRGB(0.25,  0.75,  0.75,  1)]

