//
//  UIMisc.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/16/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Foundation
import Cocoa

class ColorBox:NSButton {
    
    var color=packetColors[0]
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        var bPath:NSBezierPath = NSBezierPath()
        bPath.appendBezierPathWithRoundedRect(self.bounds, xRadius: 10.0, yRadius: 10.0)
        
        color.set()
        bPath.fill()    }
}