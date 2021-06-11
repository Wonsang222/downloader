//
//  EventAppsFlyer.swift
//  wing
//
//  Created by khh on 13/06/2019.
//  Copyright © 2019 JooDaeho. All rights reserved.
//

import Foundation

class EventAppsFlyer {
    
    static var appsFlyerId:String {
        get{
            if let returnValue = UserDefaults.standard.object(forKey: "appsFlyerId") as? String{
                return returnValue
            }else{
                return ""
            }
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "appsFlyerId")
            UserDefaults.standard.synchronize()
        }
    }
    
}
