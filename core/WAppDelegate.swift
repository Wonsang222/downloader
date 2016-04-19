//
//  AppDelegate.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class WAppDelegate: UIResponder, UIApplicationDelegate  {
    
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
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
        print(userInfo)
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
        let pushSeq = userInfo["push_seq"] as! String
        
        RSHttp().req(
            ApiFormApp().ap("mode","get_push_data").ap("pack_name",AppProp.appId).ap("push_seq",String(pushSeq)),
            successCb : { (resource) -> Void in
                let result = resource.body()["result"] as! [String:AnyObject]
                let objectInfo = result["data"] as! [String:AnyObject]
                if( application.applicationState == .Active){
                    print("active")
                    let link = objectInfo["link"] as? String
                    let subtitle = objectInfo["subtitle"] as? String
                    let alertController = UIAlertController(title: subtitle!, message: subtitle!,preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "이동", style: UIAlertActionStyle.Default,handler: { action in
                        self.goNotificationLink(link!)
                    }))
                    alertController.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.Cancel,handler: { action in
                        
                    }))
                    
                }else{
                    let link = objectInfo["link"] as? String
                    let subtitle = objectInfo["subtitle"] as? String
                    let title = objectInfo["title"] as? String
                    let img_url = objectInfo["img_url"] as? String
                    let msg = objectInfo["msg"] as? String;
                    
                    if img_url != nil {
                        
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
    
}

