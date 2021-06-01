//
//  trackerFacebook.swift
//  trackerFacebook
//
//  Created by WISA on 2021/05/27.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit


open class EventFacebook: TrackerInstance {
    
    public required init(appDelegate: UIApplicationDelegate) {
        super.init(appDelegate: appDelegate)
        print("dong test 3dd 333 init")
    }
    open override func overrideUserAgent() -> String {
        return ""
    }
    
    
    open override func trackAppFinishLaunching(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    open override func trackAppOpenUrl(url: URL) {
        ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation])
    }
    
    open override func trackAppLaunch() {

    }
    
    open override func loginTest(viewCtrl: UIViewController) {
        let btn = FBLoginButton.init()
        btn.center = viewCtrl.view.center
        viewCtrl.view.addSubview(btn)
    }
    
    
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

