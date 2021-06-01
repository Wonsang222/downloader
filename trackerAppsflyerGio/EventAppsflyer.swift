//
//  EventFacebook.swift
//  trackerAppsflyerGio
//
//  Created by WISA on 2021/05/28.
//

import UIKit
import AppsFlyerLib

open class EventAppsflyer: TrackerInstance, AppsFlyerTrackerDelegate {
    
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
    
    public required init(appDelegate: UIApplicationDelegate) {
        super.init(appDelegate: appDelegate)
        print("dong test 3dd 333 init")
        
        AppsFlyerTracker.shared().appsFlyerDevKey = AppProp.appsFlyerDevKey as! String
        AppsFlyerTracker.shared().appleAppID = AppProp.appsFlyerAppId as! String
        AppsFlyerTracker.shared().delegate = self
    }
    
    open override func overrideUserAgent() -> String {
        if let appsflyerId = AppsFlyerTracker.shared().getAppsFlyerUID() {
            EventAppsflyer.appsFlyerId = appsflyerId
            return "/WISAAPP_AF_ID(\(appsflyerId))"
        } else {
            return ""
        }
    }
    
    
    open override func trackAppFinishLaunching(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        
    }
    
    open override func trackAppOpenUrl(url: URL) {}
    
    open override func trackAppLaunch() {

    }
    
    open override func loginTest(viewCtrl: UIViewController) {}
    
//
//    public override func trackAppLaunch() {
//
//    }
//
//    public override func trackAppLaunch(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
//        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//    }
//
//    open override func trackAppOpenUrl() {
//
//    }
}
