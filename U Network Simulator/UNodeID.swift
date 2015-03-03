//
//  UStationID.swift
//  U Network Simulator
//
//  Created by Andrzej Parszuto on 2/10/15.
//

import Foundation


// This is random adoptable lenght identifier for each node of the network
//

class UNodeID {
    
    private var data=[UInt64]()
    
    init (lenght:Int)
    {
        if(lenght >= 2 && lenght <= 4)
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
            while random <  65535
            {
            
            random=random64()

            }
            self.data.append(random)
            
            
            // Shortest id if wrong data
        }
        
    }
    
    
    init (uID:UNodeID)
    {
        self.data=uID.data
    }
   
    
    
    
    
    
    init (specialType:SpecialUNodeIDS)
    {
        
        
        
        
       self.data.append(specialType.rawValue)
        
        
        
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
}



// Special uIDS - 0x00 - broadcast - lets reserve 65536 special brodcast ids



enum SpecialUNodeIDS : UInt64 {
    
    case Broadcast = 0
    case NU
    case ND
    case EU
    
}