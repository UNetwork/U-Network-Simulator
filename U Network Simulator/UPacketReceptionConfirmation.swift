//
//  UPacketReceptionConfirmation.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/28/15.

//

import Foundation

struct UPacketReceptionConfirmation
{
    var envelope:UPacketEnvelope
    var recievedPacketLenghtAndChecksum:UInt64  // from the packet this confirmation is about
}