//
//  AppDelegate.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/10/15.
//

import Foundation
import Cocoa




@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    // Console objects
    
    var logText:String=""
    var logChanged=true
    var logLevel:Int=6
    
    static let sharedInstance=AppDelegate()

    
    @IBOutlet var logTextView: NSTextView!
    
    
    @IBAction func logLevelComboBox(sender: NSComboBox)
    {
        logLevel = sender.integerValue
    }
    
    @IBAction func logClearText(sender: AnyObject) {
        AppDelegate.sharedInstance.logText=""
        logChanged=true
        
    }
    
    // UI update timer
    
    var uIUpdateTimer:NSTimer?
    
    
    
    // ---------------------------------------------------------------------------------------
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        
        uIInitialisation()      // UI Setup
        
       
        
        
        
    }


    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    // UI objects setup and initialisation
    
    func uIInitialisation()
    {
        uIUpdateTimer=NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector:"uIUpdate" , userInfo: nil, repeats: true)
        logTextView.editable=false
        
    }
    
    // UI Update
    
    func uIUpdate(){
    
        
        // Log
        
        if(logChanged)
        {

            logTextView.string=AppDelegate.sharedInstance.logText
            logTextView.scrollToEndOfDocument("")
            logChanged=false
        }
    
    
    
    
    }
    


}




