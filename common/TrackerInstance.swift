//
//  TrackerInstance.swift
//  common
//
//  Created by WISA on 2021/05/26.
//

import UIKit

open class TrackerInstance: NSObject {
    
    required public init(appDelegate: UIApplicationDelegate) {
        print("dong dd test")
    }
    
    open func overrideUserAgent() -> String {
        return ""
    }
    
    open func trackAppLaunch() {}
    
    open func trackAppFinishLaunching(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {}
    
    open func trackAppOpenUrl(url: URL) {}
    
    open func loginTest(viewCtrl: UIViewController) {
        
    }
}
