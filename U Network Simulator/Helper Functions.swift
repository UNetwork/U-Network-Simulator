//
//  Helper Functions.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/10/15.
//

import Foundation
import Cocoa

// 64 random bits

func random64()->UInt64 {return (UInt64(rand())<<33 | UInt64(rand())<<2 | UInt64(random()&0x3))}


// string to unit64 conversion

func strToUInt64(stringToConvert:String)->(UInt64)
{
    
    var magicNumber:NSNumber
    
    magicNumber=NSDecimalNumber(string: stringToConvert)
    
    return (magicNumber.unsignedLongLongValue)
}

// log with trashold shoud be in another file, but works here by now

func log(level:Int, text:String)
{
    if (AppDelegate.sharedInstance.logLevel <= level)
    {
        println(text)
        AppDelegate.sharedInstance.logText+=text+"\n"
        AppDelegate.sharedInstance.logChanged=true
    }
}

/* Log levels:

0 - Object initialisers
1 - intra interface communication (in the air)
2 - node to interface communication
3 - intra node routing
4 - routing spare level
5 - UServices API calls
6 - Traffic stats and controll
7 - Data errors

*/

func unsignedDifference(a:UInt64, b:UInt64)->(UInt64){
    
    var result=UInt64(0)
    if(a>b){result=a-b}else{result=b-a}
    return result
    
}


func randomUserName (len : Int) -> String {
    
    let letters : NSString = "aaaaaabbcccddddeeeeeffghhhiiiiiijjjkkkklllmmmnnnoooooopppqrrrrsssstttuuuuuvwwxyyzzz          "
    
    var randomString : NSMutableString = NSMutableString(capacity: len)
    
    for (var i=0; i < len; i++){
        var length = UInt32 (letters.length)
        var rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return randomString as String
}