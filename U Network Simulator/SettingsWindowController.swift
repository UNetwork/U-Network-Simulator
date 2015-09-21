//
//  SettingsWindow.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/4/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Foundation
import Cocoa



class SettingsWindowController:NSWindowController
{
    
// show packets
    
    @IBOutlet weak var colorBoxDiscoveryBroadcast: ColorBox!
    @IBAction func switchDiscoveryBroadcast(sender: AnyObject) {
        if visiblePackets[1] {visiblePackets[1]=false}else{visiblePackets[1]=true}
    }
    
    @IBOutlet weak var colorBoxReceptionConfirmation: ColorBox!
    @IBAction func switchReceptionConfirmation(sender: AnyObject) {
              if visiblePackets[2] {visiblePackets[2]=false}else{visiblePackets[2]=true}
    }
    
    
    @IBOutlet weak var colorBoxReplayForDiscovery: ColorBox!
    @IBAction func switchReplayForDiscovery(sender: AnyObject) {
              if visiblePackets[3] {visiblePackets[3]=false}else{visiblePackets[3]=true}
    }
    
    @IBOutlet weak var colorBoxReplayForNetworkLookupRequest: ColorBox!
    @IBAction func switchReplayForNetworkLookupRequest(sender: AnyObject) {
              if visiblePackets[4] {visiblePackets[4]=false}else{visiblePackets[4]=true}
    }
    
    
    @IBOutlet weak var colorBoxSearchIdForName: ColorBox!
    @IBAction func switchSearchIdForName(sender: AnyObject) {
              if visiblePackets[5] {visiblePackets[5]=false}else{visiblePackets[5]=true}
    }
    
    
    @IBOutlet weak var colorBoxStoreIdForName: ColorBox!
    @IBAction func switchStoreIdForName(sender: AnyObject) {
        if visiblePackets[6] {visiblePackets[6]=false}else{visiblePackets[6]=true}
    }
    
    
    @IBOutlet weak var colorBoxStoreNameReply: ColorBox!
    @IBAction func switchStoreNameReply(sender: AnyObject) {
              if visiblePackets[7] {visiblePackets[7]=false}else{visiblePackets[7]=true}
    }
    
    
    @IBOutlet weak var colorBoxSearchAddressForID: ColorBox!
    @IBAction func switchSearchAddressForID(sender: AnyObject) {
              if visiblePackets[8] {visiblePackets[8]=false}else{visiblePackets[8]=true}
    }
    
    @IBOutlet weak var colorBoxStoreAddressForId: ColorBox!
    @IBAction func switchStoreAddressForId(sender: AnyObject) {
              if visiblePackets[9] {visiblePackets[9]=false}else{visiblePackets[9]=true}
    }
    
    
    @IBOutlet weak var colorBoxReplyForIdSearch: ColorBox!
    @IBAction func switchReplyForIdSearch(sender: AnyObject) {
              if visiblePackets[10] {visiblePackets[10]=false}else{visiblePackets[10]=true}
    }
    
    @IBOutlet weak var colorBoxReplyForAddressSearch: ColorBox!
    @IBAction func switchReplyForAddressSearch(sender: AnyObject) {
              if visiblePackets[11] {visiblePackets[11]=false}else{visiblePackets[11]=true}
    }
    
    
    @IBOutlet weak var colorBoxPing: ColorBox!
    @IBAction func switchPing(sender: AnyObject) {
              if visiblePackets[12] {visiblePackets[12]=false}else{visiblePackets[12]=true}
    }
    
    @IBOutlet weak var colorBoxPong: ColorBox!
    @IBAction func switchPong(sender: AnyObject) {
              if visiblePackets[13] {visiblePackets[13]=false}else{visiblePackets[13]=true}
    }
    
    
    @IBOutlet weak var colorBoxData: ColorBox!
    @IBAction func switchData(sender: AnyObject) {
              if visiblePackets[14] {visiblePackets[14]=false}else{visiblePackets[14]=true}
    }
    
    @IBOutlet weak var colorBoxDataDeliveryConfirmation: ColorBox!
    @IBAction func switchDataDeliveryConfirmation(sender: AnyObject) {
              if visiblePackets[15] {visiblePackets[15]=false}else{visiblePackets[15]=true}
    }
    
    @IBOutlet weak var colorBoxDropped: ColorBox!
    @IBAction func switchDropped(sender: AnyObject) {
              if visiblePackets[16] {visiblePackets[16]=false}else{visiblePackets[16]=true}
    }
    

    // heartbeat
    
    @IBOutlet weak var heartBeatPeers: NSTextField!
    @IBOutlet weak var heartBeatNameStore: NSTextField!
    @IBOutlet weak var heartBeatAddressStore: NSTextField!
    
    @IBAction func updateHeartBeat(sender: AnyObject) {
        
        heartBeatPeersValue = heartBeatPeers.integerValue
        heartBeatNameStoreValue = heartBeatNameStore.integerValue
        heartBeatAddressStoreValue = heartBeatAddressStore.integerValue
    }
    
    // hardcore
    
    @IBOutlet weak var wirelessInterfaceRangeField: NSTextField!
    @IBOutlet weak var packetLifeTimeField: NSTextField!
    @IBOutlet weak var discoveryBroadcastDepthField: NSTextField!
    @IBOutlet weak var storeSearchDepthField: NSTextField!
    
    @IBAction func updateHardcore(sender: AnyObject)
    {
        wirelessInterfaceRange = UInt64(wirelessInterfaceRangeField.integerValue)
        standardPacketLifeTime = UInt32(packetLifeTimeField.integerValue)
        maxDiscoveryBroadcastDeepth = discoveryBroadcastDepthField.integerValue
        defaultStoreSearchDepth = UInt32(storeSearchDepthField.integerValue)
    }
    
    // nothing will work if changed
    
    
    @IBAction func processingTypeCombo(sender: NSComboBox)
    {
        
        switch sender.indexOfSelectedItem
        {
        case 0: processingMode = ProcessingType.Stright
        case 1: processingMode = ProcessingType.Serial
        case 2: processingMode = ProcessingType.Paralel
        default: log(7,text: "Unknown processing type selected")
        }
    }
    
    @IBAction func useCacheSwitch(sender: AnyObject)
    {
        if useCache
        {
            useCache=false
        }
        else
        {
            simulator.wirelessMedium.interfacesInRangeCache = [UNodeID: [UNetworkInterfaceSimulationWireless]]() //reset cache
            useCache=true

        }
    }
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.colorBoxDiscoveryBroadcast.color=NSColor(CGColor: packetColors[1])
        self.colorBoxDiscoveryBroadcast.setNeedsDisplay()
        self.colorBoxReceptionConfirmation.color=NSColor(CGColor: packetColors[2])
        self.colorBoxReceptionConfirmation.setNeedsDisplay()
        self.colorBoxReplayForDiscovery.color=NSColor(CGColor: packetColors[3])
        self.colorBoxReplayForDiscovery.setNeedsDisplay()
        self.colorBoxReplayForNetworkLookupRequest.color=NSColor(CGColor: packetColors[4])
        self.colorBoxReplayForNetworkLookupRequest.setNeedsDisplay()
        self.colorBoxSearchIdForName.color=NSColor(CGColor: packetColors[5])
        self.colorBoxSearchIdForName.setNeedsDisplay()
        self.colorBoxStoreIdForName.color=NSColor(CGColor: packetColors[6])
        self.colorBoxStoreIdForName.setNeedsDisplay()
        self.colorBoxStoreNameReply.color=NSColor(CGColor: packetColors[7])
        self.colorBoxStoreNameReply.setNeedsDisplay()
        self.colorBoxSearchAddressForID.color=NSColor(CGColor: packetColors[8])
        self.colorBoxSearchAddressForID.setNeedsDisplay()
        self.colorBoxStoreAddressForId.color=NSColor(CGColor: packetColors[9])
        self.colorBoxStoreAddressForId.setNeedsDisplay()
        self.colorBoxReplyForIdSearch.color=NSColor(CGColor: packetColors[10])
        self.colorBoxReplyForIdSearch.setNeedsDisplay()
        self.colorBoxReplyForAddressSearch.color=NSColor(CGColor: packetColors[11])
        self.colorBoxReplyForAddressSearch.setNeedsDisplay()
        self.colorBoxPing.color=NSColor(CGColor: packetColors[12])
        self.colorBoxPing.setNeedsDisplay()
        self.colorBoxPong.color=NSColor(CGColor: packetColors[13])
        self.colorBoxPong.setNeedsDisplay()
        self.colorBoxData.color=NSColor(CGColor: packetColors[14])
        self.colorBoxData.setNeedsDisplay()
        self.colorBoxDataDeliveryConfirmation.color=NSColor(CGColor: packetColors[15])
        self.colorBoxDataDeliveryConfirmation.setNeedsDisplay()
        self.colorBoxDropped.color=NSColor(CGColor: packetColors[16])
        self.colorBoxDropped.setNeedsDisplay()
        
        self.heartBeatPeers.integerValue = heartBeatPeersValue
        self.heartBeatNameStore.integerValue = heartBeatNameStoreValue
        self.heartBeatAddressStore.integerValue = heartBeatAddressStoreValue
        
        self.wirelessInterfaceRangeField.integerValue = Int(wirelessInterfaceRange)
        self.packetLifeTimeField.integerValue = Int(standardPacketLifeTime)
        self.discoveryBroadcastDepthField.integerValue = maxDiscoveryBroadcastDeepth
        self.storeSearchDepthField.integerValue = Int(defaultStoreSearchDepth)
        
    }
}
