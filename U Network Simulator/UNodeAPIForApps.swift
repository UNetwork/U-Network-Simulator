//
//  UNodeServicesForAppsAPI.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/20/15.
//

import Foundation


class UNodeAPI
{
    let node:UNode
    var apps = [UInt64: UAppProtocol]()                     // Handler for all "installed" apps

    init(node:UNode)
    {
        self.node=node
    }
    
    
    func launchApp(app:UAppProtocol)
    {
        apps[app.appID] = app
    }
    
    
    
    func sendDataToUser(name:String, data:[UInt64], app:UAppProtocol)
    {
        

node.dataApp.deliverData(name, data: data, appID: app.appID)
    }
    
    func searchForID(aName:String, app:UAppProtocol)
    {
        node.searchApp.findIdForName(aName, app: app)
    }
    
    func searchForAddress(anID:UNodeID, app:UAppProtocol)
    {
        node.searchApp.findAddressForId(anID, app: app)
    }
    

}



struct UNodeNetworkError
{
    var flags:UInt64 = 0
}