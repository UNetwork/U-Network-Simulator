//
//  ConsoleWindow.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/4/15.
//

import Foundation
import Cocoa



class ConsoleWindowController:NSWindowController
{
    @IBOutlet var consoleTextView: NSTextView!
    
    
    
    
    
    @IBAction func clearLog(sender: AnyObject)
    {
        AppDelegate.sharedInstance.logClearText()
    }
    
    @IBAction func changeLogLevel(sender: NSComboBox)
    {
        logLevel = sender.integerValue
        
        
        
    }
    
    
    
    func updateConsole()
    {
        if AppDelegate.sharedInstance.logChanged == true
        {
            consoleTextView.string=AppDelegate.sharedInstance.logText
            consoleTextView.scrollToEndOfDocument("")
            AppDelegate.sharedInstance.logChanged = false
        }
        
   
        
    }

    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        consoleTextView.editable = false
        
        log(0,"console window loaded sucessfuly")

        
    }
}