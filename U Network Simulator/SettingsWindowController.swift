//
//  SettingsWindow.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 4/4/15.
//  Copyright (c) 2015 U. All rights reserved.
//

import Foundation
import Cocoa

var visiblePackets=Array(count: 17, repeatedValue: true)

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
    @IBAction func switchStoreIdForName(sender: AnyObject) {      if visiblePackets[6] {visiblePackets[6]=false}else{visiblePackets[6]=true}
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
    
    @IBAction func updateNumberOfVisible(sender: AnyObject) {
    }
    @IBOutlet weak var numberOfVisiblePackets: NSTextField!
    // heartbeat
    
    @IBOutlet weak var heartBeatPeers: NSTextField!
    @IBOutlet weak var heartBeatNameStore: NSTextField!
    @IBOutlet weak var heartBeatAddressStore: NSTextField!
    
    @IBAction func updateHeartBeat(sender: AnyObject) {
    }
    
    // hardcore
    
    @IBOutlet weak var wirelessInterfaceRange: NSTextField!
    
    @IBOutlet weak var packetLifeTime: NSTextField!
    
    
    @IBOutlet weak var discoveryBroadcastDepth: NSTextField!
    
    @IBOutlet weak var storeSearchDepth: NSTextField!
    
    
    @IBAction func updateHardcore(sender: AnyObject) {
    }
    
    // nothing will work if changed
    
    
    @IBAction func processingTypeCombo(sender: NSComboBox) {
    }
    
    
    @IBAction func useCache(sender: AnyObject) {
    }
    
    
    
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        
        self.colorBoxDiscoveryBroadcast.color=packetColors[1]
        self.colorBoxDiscoveryBroadcast.setNeedsDisplay()
        self.colorBoxReceptionConfirmation.color=packetColors[2]
        self.colorBoxReceptionConfirmation.setNeedsDisplay()
        self.colorBoxReplayForDiscovery.color=packetColors[3]
        self.colorBoxReplayForDiscovery.setNeedsDisplay()
        self.colorBoxReplayForNetworkLookupRequest.color=packetColors[4]
        self.colorBoxReplayForNetworkLookupRequest.setNeedsDisplay()
        self.colorBoxSearchIdForName.color=packetColors[5]
        self.colorBoxSearchIdForName.setNeedsDisplay()
        self.colorBoxStoreIdForName.color=packetColors[6]
        self.colorBoxStoreIdForName.setNeedsDisplay()
        self.colorBoxStoreNameReply.color=packetColors[7]
        self.colorBoxStoreNameReply.setNeedsDisplay()
        self.colorBoxSearchAddressForID.color=packetColors[8]
        self.colorBoxSearchAddressForID.setNeedsDisplay()
        self.colorBoxStoreAddressForId.color=packetColors[9]
        self.colorBoxStoreAddressForId.setNeedsDisplay()
        self.colorBoxReplyForIdSearch.color=packetColors[10]
        self.colorBoxReplyForIdSearch.setNeedsDisplay()
        self.colorBoxReplyForAddressSearch.color=packetColors[11]
        self.colorBoxReplyForAddressSearch.setNeedsDisplay()
        self.colorBoxPing.color=packetColors[12]
        self.colorBoxPing.setNeedsDisplay()
        self.colorBoxPong.color=packetColors[13]
        self.colorBoxPong.setNeedsDisplay()
        self.colorBoxData.color=packetColors[14]
        self.colorBoxData.setNeedsDisplay()
        self.colorBoxDataDeliveryConfirmation.color=packetColors[15]
        self.colorBoxDataDeliveryConfirmation.setNeedsDisplay()
        self.colorBoxDropped.color=packetColors[16]
        self.colorBoxDropped.setNeedsDisplay()
        
        
        
    }

    
}
