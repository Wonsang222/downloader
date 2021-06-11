//
//  EventFacebook.swift
//  trackerAppsflyerGio
//
//  Created by WISA on 2021/05/28.
//

#if APPSFLYER
import UIKit
import AppsFlyerLib

class EventAppsflyer: TrackerInstance, AppsFlyerTrackerDelegate {
    
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
        
        AppsFlyerTracker.shared().appsFlyerDevKey = AppProp.appsFlyerDevKey as! String
        AppsFlyerTracker.shared().appleAppID = AppProp.appsFlyerAppId as! String
        AppsFlyerTracker.shared().delegate = self
    }
    
    public override func overrideUserAgent() -> String {
        if let appsflyerId = AppsFlyerTracker.shared().getAppsFlyerUID() {
            EventAppsflyer.appsFlyerId = appsflyerId
            return "/WISAAPP_AF_ID(\(appsflyerId))"
        } else {
            return ""
        }
    }
    
    
    public override func trackAppFinishLaunching(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        
    }
    
    public override func trackAppOpenUrl(url: URL) {}
    
    public override func trackAppLaunch() {

    }
    
    public override func loginTest(viewCtrl: UIViewController) {}
}
#endif
