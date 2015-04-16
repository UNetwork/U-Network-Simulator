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
    
    static let sharedInstance=AppDelegate()
    
    



    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var toolbar: NSToolbar!
    
    var consoleWindow:ConsoleWindowController?
    var addNodesWindow:AddNodesWindowController?
    var statsWindow:StatsWindowController?
    var nodeWindow:NodeWindowController?
    var settingsWindow:SettingsWindowController?
    var visualisationWindow:VisualisationWindowController?
    
    override init() {
        super.init()
        
        
    }
    
    // menu items
    
    
    
    @IBAction func resetSimulator(sender: AnyObject) {
        simulator=UNetworkSimulator()
        visualisationWindow?.refreshEverything()
    }
    
    
    @IBAction func refresh(sender: AnyObject) {
        
       // visualisationWindow?.refreshEverything()
        
        refreshVisualisationWindow()
    }
    
    @IBAction func visualisationWindow(sender: AnyObject) {
        if  let win = visualisationWindow
        {
            visualisationWindow!.showWindow(nil)
            visualisationWindow!.window?.makeKeyWindow()
        }
        else
        {
            let newWindow=VisualisationWindowController(windowNibName: "VisualisationWindow")
            visualisationWindow = newWindow
            visualisationWindow!.window?.backgroundColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1)
            visualisationWindow!.window?.makeKeyWindow()
        }
    }
    

    @IBAction func showConsoleWindow(sender: AnyObject)
    {
        if  let win = consoleWindow
        {
            consoleWindow!.showWindow(nil)
            consoleWindow!.window?.makeKeyWindow()
        }
        else
        {
            let newWindow=ConsoleWindowController(windowNibName: "ConsoleWindow")
            consoleWindow = newWindow
            consoleWindow!.window?.makeKeyWindow()
        }
    }
    
    @IBAction func showNodeInspectorWindow(sender: AnyObject)
    {
        if  let win = nodeWindow
        {
            nodeWindow!.showWindow(nil)
            nodeWindow!.window?.makeKeyWindow()
        }
        else
        {
            let newWindow=NodeWindowController(windowNibName: "NodeWindow")
            nodeWindow = newWindow
            nodeWindow!.window?.makeKeyWindow()
        }

    }
    
    
    @IBAction func showStats(sender: AnyObject)
    {
        if  let win = statsWindow
        {
            statsWindow!.showWindow(nil)
            statsWindow!.window?.makeKeyWindow()
        }
        else
        {
            let newWindow=StatsWindowController(windowNibName: "StatsWindow")
            statsWindow = newWindow
            statsWindow!.window?.makeKeyWindow()
        }

    }
    
    @IBAction func toggleSimulationPause(sender: AnyObject)
    {
    
    
    // gobal switch toggle
    
    
    
    
    
    }
    
    @IBAction func showAddNodesWindow(sender: AnyObject)
    {
        if  let win = addNodesWindow
        {
            addNodesWindow!.showWindow(nil)
            addNodesWindow!.window?.makeKeyWindow()
        }
        else
        {
            let newWindow=AddNodesWindowController(windowNibName: "AddNodesWindow")
            addNodesWindow = newWindow
            addNodesWindow!.window?.makeKeyWindow()
        }

    }
    
    
    @IBAction func showSettingssWindow(sender: AnyObject)
    {
        if  let win = settingsWindow
        {
            settingsWindow!.showWindow(nil)
            settingsWindow!.window?.makeKeyWindow()
        }
        else
        {
            let newWindow=SettingsWindowController(windowNibName: "SettingsWindow")
            settingsWindow = newWindow
            settingsWindow!.window?.makeKeyWindow()
        }

    }
    
    
    
    
    // Console objects
    
    var logText:String=""
    var logChanged=true
    

    @IBAction func clearConnections(sender: AnyObject) {
        
        if let visWin = self.visualisationWindow?.window
        {
            for aView in visWin.contentView.subviews
            {
                if aView is ConnectionView
                {
                    aView.removeFromSuperview()
                }
               if aView is NodeView
               {
                (aView as! NodeView).clicked = false
                (aView as! NodeView).setNeedsDisplayInRect(aView.bounds)
                }
            }
        }
        
    }
    
    @IBAction func randomPing(sender: AnyObject)
    {
        let fromNodeId = simulator.simulationNodeIdCache[Int(arc4random_uniform(UInt32(simulator.simulationNodeIdCache.count)))]
        let toNodeId = simulator.simulationNodeIdCache[Int(arc4random_uniform(UInt32(simulator.simulationNodeIdCache.count)))]
        
        let fromSimulationNode = simulator.simulationNodes[fromNodeId]
        let toSimulationNode = simulator.simulationNodes[toNodeId]
        
        fromSimulationNode!.node.pingApp!.sendPing(toNodeId, address: toSimulationNode!.node.address)
        
        if (visualisationWindow != nil)
        {
           
            let fromView =  visualisationWindow!.nodeViews[fromNodeId]!
            
            fromView.clicked = true
            fromView.setNeedsDisplayInRect(fromView.bounds)
            
            let toView = visualisationWindow!.nodeViews[toNodeId]!
            
            toView.clicked = true
            toView.setNeedsDisplayInRect(toView.bounds)
            
            
                }
        
        
        
    }
    
    @IBAction func randomNameStore(sender: AnyObject) {
         let randomNode = simulator.simulationNodeIdCache[Int(arc4random_uniform(UInt32(simulator.simulationNodeIdCache.count)))]
            let simulationNode = simulator.simulationNodes[randomNode]
        
        simulationNode!.node.searchApp.storeName()
    }
    
    
    @IBAction func randomAddressStore(sender: AnyObject) {
        let randomNode = simulator.simulationNodeIdCache[Int(arc4random_uniform(UInt32(simulator.simulationNodeIdCache.count)))]
        let simulationNode = simulator.simulationNodes[randomNode]
        
        simulationNode!.node.searchApp.storeAddress()
    }

    
    @IBAction func refreshAllPeers(sender: AnyObject) {
        
        for simNode in simulator.simulationNodes.values
        {
            simNode.node.refreshPeers()
        }
    }
 
    
     func logClearText() {
        AppDelegate.sharedInstance.logText=""
        logChanged=true
        
    }
    
    // UI update timer
    
    var uIUpdateTimer:NSTimer?
    
    
    
    // ---------------------------------------------------------------------------------------
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        
        uIInitialisation()      // UI Setup
        
        refreshVisualisationWindow()
       
        
        
        
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
    
    func refreshVisualisationWindow()
    {
        
        
        
        visualisationWindow?.refreshEverything()
    }
    


}




