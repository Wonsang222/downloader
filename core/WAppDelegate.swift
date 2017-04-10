//
//  AppDelegate.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import AdSupport

class WAppDelegate: UIResponder, UIApplicationDelegate  {
    
    
    var window: UIWindow?
    var tracker: GAITracker?{
        get{
            if WInfo.trackerId.isEmpty {
                return nil
            }else{
                return GAI.sharedInstance().trackerWithTrackingId(WInfo.trackerId)
            }
            
        }
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let userAgent = UIWebView().stringByEvaluatingJavaScriptFromString("navigator.userAgent")
        NSUserDefaults.standardUserDefaults().registerDefaults(
            ["UserAgent": "\(userAgent!) WISAAPP/\(AppProp.appId)/\(WInfo.coreVersion)/IOS"]
        )
        
        NSHTTPCookieStorage.sharedHTTPCookieStorage().cookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Always
        
        RSHttp().req(
            ApiFormApp().ap("mode","add_token")
                .ap("pack_name",AppProp.appId)
                .ap("token",WInfo.deviceToken)
        )

        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        for cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies! {
            NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
        }
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true;
        gai.logger.logLevel = GAILogLevel.None
        
        
        #if ADBRIX
        if NSClassFromString("ASIdentifierManager") != nil {
            let ifa = ASIdentifierManager.sharedManager().advertisingIdentifier
            let isAppleAdvertisingTrackingEnabled = ASIdentifierManager.sharedManager().advertisingTrackingEnabled
            IgaworksCore.setAppleAdvertisingIdentifier(ifa.UUIDString, isAppleAdvertisingTrackingEnabled: isAppleAdvertisingTrackingEnabled)
        }
        IgaworksCore.igaworksCoreWithAppKey(AppProp.adbrixAppKey, andHashKey: AppProp.adbrixHashKey)
            //            IgaworksCore.setLogLevel(IgaworksCoreLogTrace)
        #endif
        return true
    }
    func applicationWillResignActive(application: UIApplication) {
    }
    
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationDidBecomeActive( application: UIApplication) {
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenString = deviceToken.description.stringByReplacingOccurrencesOfString("[ <>]", withString: "", options: .RegularExpressionSearch, range: nil)
        print(tokenString)
        WInfo.deviceToken = tokenString
        RSHttp().req(
            ApiFormApp().ap("mode","add_token")
                .ap("pack_name",AppProp.appId)
                .ap("token",WInfo.deviceToken)
        )
        
        
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError){
        print(error)
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
        
        let pushSeq = userInfo["push_seq"] as! String
        RSHttp().req(
            ApiFormApp().ap("mode","get_push_data").ap("pack_name",AppProp.appId).ap("push_seq",String(pushSeq)),
            successCb : { (resource) -> Void in
                let objectInfo = resource.body()["data"] as! [String:AnyObject]
                if( application.applicationState == .Active){
                    let link = objectInfo["link"] as? String
                    let subtitle = objectInfo["subtitle"] as? String
                    let title = objectInfo["title"] as? String
                    let img_url = objectInfo["img_url"] as? String
                    var msg = objectInfo["msg"] as? String
                    msg = msg?.replace("<br />", withString: "\r\n")
                    msg = msg?.replace("<br/>", withString: "\r\n")
                    if img_url != nil {
                        let alertController = UIAlertController(title: title!, message: subtitle!,preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "이동", style: UIAlertActionStyle.Default,handler: { action in
                            self.goNotificationLink(link!)
                        }))
                        alertController.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.Cancel,handler: { action in
                            
                        }))
                        self.window?.rootViewController!.presentViewController(alertController,animated:true, completion: nil)
                    }else if msg != nil {
                        let alertController = UIAlertController(title: subtitle!, message: msg!,preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "이동", style: UIAlertActionStyle.Default,handler: { action in
                            self.goNotificationLink(link!)
                        }))
                        alertController.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.Cancel,handler: { action in
                            
                        }))
                        self.window?.rootViewController!.presentViewController(alertController,animated:true, completion: nil)
                        
                    }else{
                        let alertController = UIAlertController(title: title!, message: subtitle!,preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "이동", style: UIAlertActionStyle.Default,handler: { action in
                            self.goNotificationLink(link!)
                        }))
                        alertController.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.Cancel,handler: { action in
                            
                        }))
                        self.window?.rootViewController!.presentViewController(alertController,animated:true, completion: nil)
                    }
                    
                }else{
                    let link = objectInfo["link"] as? String
                    self.goNotificationLink(link!)
                }

                
            }
        )
        
    }
    
    
    func goNotificationLink(link:String){
        if let rootViewController = self.window!.rootViewController as? UINavigationController {
            rootViewController.popToRootViewControllerAnimated(true)
            if let mainController = rootViewController.viewControllers[0] as? WMainController{
                mainController.performSegueWithIdentifier("noti" ,  sender : link)
            }
        }
    }
    
    
//    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
//    }
}

