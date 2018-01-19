//
//  AppDelegate.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import AdSupport
import UserNotifications

class WAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate  {
    
    
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
    private var apnsCallback:((_ error:Bool)->Void)?
    
    
    func regApns(callback:@escaping (_ error:Bool)->Void){
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert], completionHandler: { (granted, error) in
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }else{
                    
                }
            })

        }else{
            let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(pushNotificationSettings)
        }
        
        

        
        UIApplication.shared.registerForRemoteNotifications()
        self.apnsCallback = callback
        
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

        for cookie in HTTPCookieStorage.shared.cookies! {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
        
        
        #if ADBRIX
        if NSClassFromString("ASIdentifierManager") != nil {
            let ifa = ASIdentifierManager.shared().advertisingIdentifier
            let isAppleAdvertisingTrackingEnabled = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
            IgaworksCore.setAppleAdvertisingIdentifier(ifa!.uuidString, isAppleAdvertisingTrackingEnabled: isAppleAdvertisingTrackingEnabled)
        }
        IgaworksCore.igaworksCore(withAppKey: AppProp.adbrixAppKey, andHashKey: AppProp.adbrixHashKey)
            //            IgaworksCore.setLogLevel(IgaworksCoreLogTrace)
        #endif
        
        setenv("JSC_useJIT", "false", 0)
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
//        let tokenString = deviceToken.description.replacingOccurrences(of: "[ <>]", with: "", options: .regularExpression, range: nil)
        var tokenString = ""
        for i in 0..<deviceToken.count {
            tokenString = tokenString + String(format:"%02.2hhx" , arguments: [deviceToken[i]])
        }
        #if DEBUG
        print(tokenString)
        #endif
        WInfo.deviceToken = tokenString
        let api = ApiFormApp().ap("mode","add_token")
            .ap("pack_name",AppProp.appId)
            .ap("token",WInfo.deviceToken)

        RSHttp().req([api],successCb: { (resource) -> Void in
            self.apnsCallback?(true)
        },errorCb : { (errorCode,resource) -> Void in
            self.apnsCallback?(false)
        })
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let userInfo = notification.request.content.userInfo as? [String : AnyObject] {
            if let push_seq = userInfo["push_seq"] as? String {
                self.handlePush(push_seq)
            }
        }
        completionHandler(.badge)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        if let userInfo = response.notification.request.content.userInfo as? [String : AnyObject] {
            if let push_seq = userInfo["push_seq"] as? String {
                self.handlePush(push_seq)
            }
        }
        completionHandler()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error){
        self.apnsCallback?(false)
        print(error)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
        let pushSeq = userInfo["push_seq"] as! String
        self.handlePush(pushSeq)
    }
    
    func handlePush(_ push_seq:String){
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

