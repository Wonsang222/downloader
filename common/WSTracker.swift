//
//  WSTracker.swift
//  common
//
//  Created by WISA on 2021/05/26.
//

import Foundation
import UIKit

class WSTracker {
    

    static let _tracker = WSTracker()

    public static func getInstance() -> WSTracker {
        return _tracker;
    }

    var instances: [TrackerInstance] = []


    public func load(appDelegate: UIApplicationDelegate) {
        let trackerClassNms = Bundle.main.infoDictionary?["AppTrackerClass"] as! [String]
        print("dong 1 \(trackerClassNms.count)")

        for classNm in trackerClassNms {
            print("dong 1  \(classNm)")
            print("dong 1.5 \(NSClassFromString(classNm))")
            let ins = NSClassFromString(classNm) as? TrackerInstance.Type
            instances.append(ins!.init(appDelegate: appDelegate))
            print("dong 2 \(instances)")
        }
    
    }

    public func overrideUserAgent(userAgent: String) -> String {
        var addition = ""
        for ins in instances {
            addition += ins.overrideUserAgent()
        }
        return userAgent + addition
    }

    public func trakAppLaunch() {
        for ins in instances {
            ins.trackAppLaunch()
        }
    }
    
    public func trackAppOpenUrl(url: URL) {
        for ins in instances {
            ins.trackAppOpenUrl(url: url)
        }
        
    }
    
    public func trackAppFinishLaunching(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        for ins in instances {
            ins.trackAppFinishLaunching(application: application, launchOptions: launchOptions)
        }
    }
    
    public func loginTest(viewCtrl: UIViewController) {
        for ins in instances {
            ins.loginTest(viewCtrl: viewCtrl)
        }
    }
    
}
