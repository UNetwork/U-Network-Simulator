//
//  UStationID.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/10/15.
//

import Foundation


/*
This is random identifier for each node of the network.
Lenght is 64 - 256 bits.
The 64-bit id with zero value is broadcast  id
*/

class UNodeID {
    
    private var data=[UInt64]()
    
    init (lenght:Int)
    {
        if(lenght >= 1 && lenght <= 4)
        {
            self.data=[UInt64]()
            for _ in 0..<lenght
            {
                self.data.append(random64())
            }
        }
        else
        {
            var random=random64()
            self.data.append(random)
            // Shortest id if wrong data
        }
    }
    
    init ()     // Broadcast packet if in transmitedToUID in packet header
    {
       self.data.append(0)
    }
    
    
    func isEqual(to:UNodeID) -> Bool
    {
        if (to.data.count != self.data.count)
        {
            return false
        }
        else
        {
            for (counter, datachunk) in enumerate(self.data)
            {
                if (to.data[counter] != datachunk)
                {
                    return false
                }
            }
        }
        return true
    }
    
    
    func isBroadcast() -> Bool
    {
        if(self.data.count == 1 && self.data[0] == 0)
        {
            return true
        }
        return false
    }
}



