//
//  UPacketReceptionConfirmation.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/28/15.

//

import Foundation

struct UPacketReceptionConfirmation
{
    var serial:UInt64 // from the packet this confirmation is about
    
    init(serial:UInt64)
    {
        self.serial=serial
    }
}