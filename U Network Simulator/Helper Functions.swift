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
    if (logLevel <= level)
    {
        print(text)
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
    
    let letters : NSString = "aaaaaabbbccccddddeeeeeffghhhiiiiiijjjkkkkklllmmmnnnooooopppqrrrrssstttuuuuuvwwxyyzz"
    
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    for (var i=0; i < len; i++){
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return randomString as String
}


// string to data format (UInt64) conversion

func stringToUData (text:String) -> [UInt64]
{
    var result = [UInt64]()
    
    var shifter = UInt64(8)
    var currentDatachunk = UInt64(0)
    
    for char in text.utf8
    {
        shifter--
        
        currentDatachunk += UInt64(char) << (shifter * 8)
        
        if (shifter == 0)
        {
            result.append(currentDatachunk)
            shifter = 8
            currentDatachunk = 0
        }
    }
    
    if (shifter < 8)
    {
        result.append(currentDatachunk)
    }
    
    return result
    
}


func uDataToString (data: [UInt64]) -> String
{
    var result8 = [UInt8]()
    
    for dataChunk in data
    {
        for i in 0...7
        {
            let byte64 = (dataChunk >> (UInt64(7-i) * 8)) & 0xFF
            
            let byte8 = UInt8(byte64)
            
            result8.append(byte8)
        }
        
    }
    
    if let result =  (String(bytes: result8, encoding: NSUTF8StringEncoding))
    {
        return result
    }
    
    return ""
}


extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

