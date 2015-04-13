//
//  VizualisationWindow.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/9/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Foundation
import Cocoa

class VisualisationWindowController:NSWindowController, NSWindowDelegate {
    
    var nodeViews=[UNodeID:NodeView]()
    
    
    
    
    func windowDidResize(notification: NSNotification) {
        refreshEverything() 
    }
    
    
    
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        refreshEverything()
    }
    
    
    @IBAction func showNode(sender: AnyObject) {
        
        refreshEverything()
        
    }
    
    
    func refreshEverything()
    {
        
        
        if let visWin = self.window
        {
            for aView in visWin.contentView.subviews
            {
                aView.removeFromSuperview()
            }
            
            for aSimulationNode in simulator.simulationNodes.values
            {
                visWin.contentView.addSubview( aSimulationNode.node.view(visWin))
            }
            
            
            
            
            
        }
    }
    
}