//
//  trackerFacebook.swift
//  trackerFacebook
//
//  Created by WISA on 2021/05/27.
//
#if FACEBOOK
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

public class EventFacebook: TrackerInstance {
    
    public required init(appDelegate: UIApplicationDelegate) {
        super.init(appDelegate: appDelegate)
        enableShowTracking = true
        print("dong test 3dd 333 init")
    }
    
    public override func overrideUserAgent() -> String {
        return ""
    }
    
    
    public override func trackAppFinishLaunching(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public override func trackAppOpenUrl(url: URL) {
        ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation])
    }
    
    public override func trackAppLaunch() {

    }
    
    public override func loginTest(viewCtrl: UIViewController) {
        let btn = FBLoginButton.init()
        btn.center = viewCtrl.view.center
        viewCtrl.view.addSubview(btn)
    }
}
#endif

