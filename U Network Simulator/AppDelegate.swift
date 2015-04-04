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
    @IBOutlet weak var toolbar: NSToolbar!
    
    var consoleWindow:ConsoleWindowController?
    var addNodesWindow:AddNodesWindowController?
    var statsWindow:StatsWindowController?
    var nodeWindow:NodeWindowController?
    var settingsWindow:SettingsWindowController?
    

    @IBAction func showConsoleWindow(sender: AnyObject)
    {
        if  let win = consoleWindow   // bug is here when closing window with red dot and opening again
        {
            consoleWindow!.close()
            consoleWindow=nil
        }
        else
        {
            let newWindow=ConsoleWindowController(windowNibName: "ConsoleWindow")
            consoleWindow=newWindow
            consoleWindow!.window?.makeKeyWindow()
        }
    }
    
    @IBAction func showNodeInspectorWindow(sender: AnyObject)
    {
        if let win = nodeWindow
        {
            nodeWindow!.close()
            nodeWindow=nil
        }
        else
        {
            let newWindow=NodeWindowController(windowNibName: "NodeWindow")
            nodeWindow=newWindow
            nodeWindow!.window?.makeKeyWindow()
        }

    }
    
    
    @IBAction func showStats(sender: AnyObject)
    {
        if let win = statsWindow
        {
            statsWindow!.close()
            statsWindow=nil
        }
        else
        {
            let newWindow=StatsWindowController(windowNibName: "StatsWindow")
            statsWindow=newWindow
            statsWindow!.window?.makeKeyWindow()
        }

    }
    
    @IBAction func toggleSimulationPause(sender: AnyObject)
    {
    
    
    // gobal switch toggle
    
    
    
    
    
    }
    
    @IBAction func showAddNodesWindow(sender: AnyObject)
    {
        if let win = addNodesWindow
        {
            addNodesWindow!.close()
            addNodesWindow=nil
        }
        else
        {
            let newWindow=AddNodesWindowController(windowNibName: "AddNodesWindow")
            addNodesWindow=newWindow
            addNodesWindow!.window?.makeKeyWindow()
        }

    }
    
    
    @IBAction func showSettingssWindow(sender: AnyObject)
    {
        if let win = settingsWindow
        {
            settingsWindow!.close()
            settingsWindow=nil
        }
        else
        {
            let newWindow=SettingsWindowController(windowNibName: "SettingsWindow")
            settingsWindow=newWindow
            settingsWindow!.window?.makeKeyWindow()
        }

    }
    
    
    
    
    // Console objects
    
    var logText:String=""
    var logChanged=true
    
    static let sharedInstance=AppDelegate()

    
    
 
    
     func logClearText() {
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
        
    }
    
    // UI Update
    
    func uIUpdate(){
consoleWindow?.updateConsole()
    }
    


}




