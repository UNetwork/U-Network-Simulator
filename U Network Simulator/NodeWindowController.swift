//
//  NodeInfoWindow.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/4/15.
//

import Foundation
import Cocoa


class NodeWindowController:NSWindowController
    
{
    
    @IBOutlet weak var infoText: NSTextField!
    
    
    
    @IBOutlet weak var chatText: NSTextField!
    
    @IBOutlet weak var namesTable: NSTableView!
    
    @IBOutlet weak var message: NSTextField!
   
    @IBAction func sendMessage(sender: AnyObject)
    {
        
        
    }
    override init(window: NSWindow!)
    {
        super.init(window: window)
    }
    
    required init?(coder: (NSCoder!))
    {
        super.init(coder: coder)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        
        
        
    }
}