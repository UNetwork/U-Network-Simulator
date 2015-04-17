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
    NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0),
    NSColor(calibratedRed: 0.25, green: 0, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0.25, green: 0.25, blue: 0, alpha: 1),
    NSColor(calibratedRed: 1, green: 0.75, blue: 0.25, alpha: 1),
    NSColor(calibratedRed: 0, green: 0.25, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0, green: 0, blue: 0.25, alpha: 1),
    NSColor(calibratedRed: 0.0, green: 0.25, blue: 0.25, alpha: 1),
    NSColor(calibratedRed: 0.25, green: 0.5, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0.25, green: 0, blue: 0.5, alpha: 1),
    NSColor(calibratedRed: 0.5, green: 0, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0.5, green: 0.5, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0.5, green: 0, blue: 0.5, alpha: 1),
    NSColor(calibratedRed: 1, green: 0.35, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0.1, green: 0.73, blue: 1, alpha: 1),
    NSColor(calibratedRed: 0.75, green: 0.5, blue: 0, alpha: 1),
    NSColor(calibratedRed: 0.75, green: 0.5, blue: 0.5, alpha: 1),
    NSColor(calibratedRed: 0.25, green: 0.75, blue: 0.75, alpha: 1)]

