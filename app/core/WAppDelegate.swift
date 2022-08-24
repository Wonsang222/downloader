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
import WebKit

class WAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var rootVc: UIViewController?
    var scriptWebview: WKWebView!
    
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
    var remotePushSeq:String?
    var commmandUrl:String?
    private var apnsCallback:((_ error:Bool)->Void)?
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        rootVc = self.window?.rootViewController
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        WSTracker.getInstance().trackAppOpenUrl(url: url)
    }
    
    
    func regApns(callback:@escaping (_ error:Bool)->Void){
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert], completionHandler: { (granted, error) in
                if granted {
                    self.apnsCallback = callback
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }else{
                    DispatchQueue.main.async {
                        callback(false);
                    }
                }
            })
            
        }else{
            let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(pushNotificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
            self.apnsCallback = callback
        }
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        scriptWebview = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        var userAgent: String!
        var finished = false
        scriptWebview.evaluateJavaScript("navigator.userAgent") { (result, error) in
            userAgent = result as? String
            finished = true
        }
        while !finished {
            RunLoop.current.run(mode: .defaultRunLoopMode, before: Date.distantFuture)
        }
        
        WSTracker.getInstance().load(appDelegate: self)
        WSTracker.getInstance().trackAppFinishLaunching(application: application, launchOptions: launchOptions)
        userAgent = "\(String(describing: userAgent)) WISAAPP/\(AppProp.appId)/\(WInfo.coreVersion)/IOS"
        let overrideAgent = WSTracker.getInstance().overrideUserAgent(userAgent: userAgent)
        UserDefaults.standard.register(
            defaults: ["UserAgent": overrideAgent]
        )
        if launchOptions != nil {
            if let userInfo = launchOptions![UIApplicationLaunchOptionsKey.remoteNotification] as? [String : AnyObject] {
                self.remotePushSeq = userInfo["push_seq"] as? String
            }
        }
        if let launchUrl = launchOptions?[.url] as? URL {
            if launchUrl.host == "page" {
                self.commmandUrl = launchUrl.query
            }
        }
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        
        RSHttp().req(
            ApiFormApp().ap("mode","add_token")
                .ap("pack_name",AppProp.appId)
                .ap("token",WInfo.deviceToken)
        )
        
        if(AppProp.appCookieSet != "YES") {
            WInfo.restoreAllCookie()
            WInfo.clearSessionCookie()
        }
        
        setenv("JSC_useJIT", "false", 0)
        
        WSTracker.getInstance().trackAppFinishLaunching(application: application, launchOptions: launchOptions)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive( _ application: UIApplication) {
        clearCache()
        //        AppsFlyerTracker.shared().trackAppLaunch()
        //        WSTracker.getInstance().trackAppLaunch
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        WInfo.saveAllCookie()
    }
    
    
    func clearCache() {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                    
                } catch let error as NSError {
                    debugPrint("dong Ooops! Something went wrong: \(error)")
                }
                
            }
            
        } catch let error as NSError {
            debugPrint("dong \(error.localizedDescription)")
        }
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var tokenString = ""
        for i in 0..<deviceToken.count {
            tokenString = tokenString + String(format:"%02.2hhx" , arguments: [deviceToken[i]])
        }
        if !WInfo.deviceToken.elementsEqual(tokenString) {
            WInfo.deviceToken = tokenString
            
            let api = ApiFormApp().ap("mode","add_token")
                .ap("pack_name",AppProp.appId)
                .ap("token",WInfo.deviceToken)
            
            RSHttp().req(api, successCb: { (resource) -> (Void) in
                self.apnsCallback?(true)
                self.apnsCallback = nil
            }) { (errorCode, resource) -> (Void) in
                self.apnsCallback?(false)
                self.apnsCallback = nil
            }
        } else {
            self.apnsCallback?(true)
            self.apnsCallback = nil
        }
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let userInfo = notification.request.content.userInfo as? [String : AnyObject] {
            if let push_seq = userInfo["push_seq"] as? String {
                self.handlePush(push_seq,isBackground: false)
            }
        }
        completionHandler(.badge)
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        if let userInfo = response.notification.request.content.userInfo as? [String : AnyObject] {
            if let push_seq = userInfo["push_seq"] as? String {
                self.handlePush(push_seq,isBackground: true)
            }
        }
        completionHandler()
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error){
        self.apnsCallback?(false)
        self.apnsCallback = nil
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
        let pushSeq = userInfo["push_seq"] as! String
        self.handlePush(pushSeq,isBackground: UIApplication.shared.applicationState != .active )
    }
    func handlePush(_ pushSeq:String,isBackground:Bool){
        RSHttp().req(
            ApiFormApp().ap("mode","get_push_data").ap("pack_name",AppProp.appId).ap("push_seq",String(pushSeq)),
            successCb : { (resource) -> Void in
                let objectInfo = resource.body()["data"] as! [String:AnyObject]
                if( UIApplication.shared.applicationState == .active && !isBackground){
                    let link = objectInfo["link"] as? String
                    let subtitle = objectInfo["subtitle"] as? String
                    let title = objectInfo["title"] as? String
                    let img_url = objectInfo["img_url"] as? String
                    let type = objectInfo["type"] as? String == "notice" ? "event" : "all"
                    var msg = objectInfo["msg"] as? String
                    msg = msg?.replace("<br />", withString: "\r\n")
                    msg = msg?.replace("<br/>", withString: "\r\n")
                    if img_url != nil {
                        let alertController = UIAlertController(title: title!, message: subtitle!,preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "이동", style: UIAlertActionStyle.default,handler: { action in
                            self.goNotificationLink(link!, type, pushSeq)
                        }))
                        alertController.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel,handler: { action in
                        }))
                        self.window?.rootViewController!.present(alertController,animated:true, completion: nil)
                    }else if msg != nil {
                        let alertController = UIAlertController(title: subtitle!, message: msg!,preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "이동", style: UIAlertActionStyle.default,handler: { action in
                            self.goNotificationLink(link!, type, pushSeq)
                        }))
                        alertController.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel,handler: { action in
                        }))
                        self.window?.rootViewController!.present(alertController,animated:true, completion: nil)
                    }else{
                        let alertController = UIAlertController(title: title!, message: subtitle!,preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "이동", style: UIAlertActionStyle.default,handler: { action in
                            self.goNotificationLink(link!, type, pushSeq)
                        }))
                        alertController.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel,handler: { action in
                        }))
                        self.window?.rootViewController!.present(alertController,animated:true, completion: nil)
                    }
                }else{
                    let link = objectInfo["link"] as? String
                    let type = objectInfo["type"] as? String == "notice" ? "event" : "all";
                    self.goNotificationLink(link!, type, pushSeq)
                }
            }
        )
    }
    // navigation view controller 에서 Pop 하는 방법, popToRootViewController : 지정된 뷰 컨트롤러가 탐색 스택의 맨 위에 있을 때까지 뷰 컨트롤러를 팝한다.
    // 알림함을 맨위의 뷰로 올리는 부분
    func goNotificationLink(_ link:String, _ type:String,_ seq:String){
        if let rootViewController = self.window!.rootViewController as? UINavigationController {
            rootViewController.popToRootViewController(animated: true)
            if let mainController = rootViewController.viewControllers[0] as? WMainController{
                mainController.performSegue(withIdentifier: "noti" ,  sender : [link, type, seq])
            }
        }
    }
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        self.proc_open_url(url: url)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        self.proc_open_url(url: url)
        return true
    }
    func proc_open_url(url:URL){
        if url.host == "page" {
            if let rootViewController = self.window!.rootViewController as? UINavigationController {
                if let mainController = rootViewController.viewControllers[0] as? WMainController{
                    if commmandUrl == nil {
                        mainController.loadPage("\(WInfo.appUrl)/" + url.query!)
                    }
                }
            }
        }
    }

}

