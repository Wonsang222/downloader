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
                let gai = GAI.sharedInstance()
                gai?.trackUncaughtExceptions = true;
                gai?.logger.logLevel = GAILogLevel.none
                return GAI.sharedInstance().tracker(withTrackingId: WInfo.trackerId)
            }
            
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let userAgent = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")
        UserDefaults.standard.register(
            defaults: ["UserAgent": "\(userAgent!) WISAAPP/\(AppProp.appId)/\(WInfo.coreVersion)/IOS"]
        )
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        
        RSHttp().req(
            ApiFormApp().ap("mode","add_token")
                .ap("pack_name",AppProp.appId)
                .ap("token",WInfo.deviceToken)
        )

        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        for cookie in HTTPCookieStorage.shared.cookies! {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
        
        
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
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive( _ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.description.replacingOccurrences(of: "[ <>]", with: "", options: .regularExpression, range: nil)
        #if DEBUG
        print(tokenString)
        #endif
        WInfo.deviceToken = tokenString
        RSHttp().req(
            ApiFormApp().ap("mode","add_token")
                .ap("pack_name",AppProp.appId)
                .ap("token",WInfo.deviceToken)
        )
        
        
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error){
        print(error)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
        
        let pushSeq = userInfo["push_seq"] as! String
        RSHttp().req(
            ApiFormApp().ap("mode","get_push_data").ap("pack_name",AppProp.appId).ap("push_seq",String(pushSeq)),
            successCb : { (resource) -> Void in
                let objectInfo = resource.body()["data"] as! [String:AnyObject]
                if( application.applicationState == .active){
                    let link = objectInfo["link"] as? String
                    let subtitle = objectInfo["subtitle"] as? String
                    let title = objectInfo["title"] as? String
                    let img_url = objectInfo["img_url"] as? String
                    var msg = objectInfo["msg"] as? String
                    msg = msg?.replace("<br />", withString: "\r\n")
                    msg = msg?.replace("<br/>", withString: "\r\n")
                    if img_url != nil {
                        let alertController = UIAlertController(title: title!, message: subtitle!,preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "이동", style: UIAlertActionStyle.default,handler: { action in
                            self.goNotificationLink(link!)
                        }))
                        alertController.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel,handler: { action in
                            
                        }))
                        self.window?.rootViewController!.present(alertController,animated:true, completion: nil)
                    }else if msg != nil {
                        let alertController = UIAlertController(title: subtitle!, message: msg!,preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "이동", style: UIAlertActionStyle.default,handler: { action in
                            self.goNotificationLink(link!)
                        }))
                        alertController.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel,handler: { action in
                            
                        }))
                        self.window?.rootViewController!.present(alertController,animated:true, completion: nil)
                        
                    }else{
                        let alertController = UIAlertController(title: title!, message: subtitle!,preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "이동", style: UIAlertActionStyle.default,handler: { action in
                            self.goNotificationLink(link!)
                        }))
                        alertController.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel,handler: { action in
                            
                        }))
                        self.window?.rootViewController!.present(alertController,animated:true, completion: nil)
                    }
                    
                }else{
                    let link = objectInfo["link"] as? String
                    self.goNotificationLink(link!)
                }

                
            }
        )
        
    }
    
    
    func goNotificationLink(_ link:String){
        if let rootViewController = self.window!.rootViewController as? UINavigationController {
            rootViewController.popToRootViewController(animated: true)
            if let mainController = rootViewController.viewControllers[0] as? WMainController{
                mainController.performSegue(withIdentifier: "noti" ,  sender : link)
            }
        }
    }
    
    
//    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
//    }
}

