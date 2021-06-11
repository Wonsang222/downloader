//
//  TrackerInstance.swift
//  common
//
//  Created by WISA on 2021/05/26.
//

import UIKit
import AppTrackingTransparency

public class TrackerInstance: NSObject {
    
    var enableShowTracking:Bool = false
    
    required public init(appDelegate: UIApplicationDelegate) {
        print("dong dd test")
    }
    
    public func overrideUserAgent() -> String {
        return ""
    }
    
    public func trackAppLaunch() {}
    
    public func trackAppFinishLaunching(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {}
    
    public func trackAppOpenUrl(url: URL) {}
    
    public func loginTest(viewCtrl: UIViewController) {
        
    }
}
