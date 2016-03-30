//
//  AppDelegate.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {

//class AppDelegate: UIResponder, UIApplicationDelegate,GGLInstanceIDDelegate,GCMReceiverDelegate  {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // self.loadGcm()
        return true
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }


    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "kr.co.wisa.magicapp" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("magicapp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }


    // func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
    //     let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
    //     instanceIDConfig.delegate = self
    //     GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
    //     registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
    //     kGGLInstanceIDAPNSServerTypeSandboxOption:true]
    //     GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
    //     scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    // }

    // func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
    //     print("Registration for remote notification failed with error: \(error.localizedDescription)")
    //     let userInfo = ["error": error.localizedDescription]
    //     NSNotificationCenter.defaultCenter().postNotificationName(registrationKey, object: nil, userInfo: userInfo)
    // }    


    // func application( application: UIApplication,didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    //     print("Notification received: \(userInfo)")
    //     GCMService.sharedInstance().appDidReceiveMessage(userInfo);
    //     NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,userInfo: userInfo)
    // }

    // func application( application: UIApplication,didReceiveRemoteNotification userInfo: [NSObject : AnyObject],fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
    //   print("Notification received: \(userInfo)")
    //   GCMService.sharedInstance().appDidReceiveMessage(userInfo);
    //   NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,userInfo: userInfo)
    //   handler(UIBackgroundFetchResult.NoData);
    // }

    // func registrationHandler(registrationToken: String!, error: NSError!) {
    //     if (registrationToken != nil) {
    //       self.registrationToken = registrationToken
    //       print("Registration Token: \(registrationToken)")
    //       self.subscribeToTopic()
    //       let userInfo = ["registrationToken": registrationToken]
    //       NSNotificationCenter.defaultCenter().postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
    //     } else {
    //       print("Registration to GCM failed with error: \(error.localizedDescription)")
    //       let userInfo = ["error": error.localizedDescription]
    //       NSNotificationCenter.defaultCenter().postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
    //     }
    // }


    // func subscribeToTopic() {
    //     if(registrationToken != nil && connectedToGCM) {
    //       GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: subscriptionTopic,
    //       options: nil, handler: {(error:NSError?) -> Void in
    //           if let error = error {
    //             // Treat the "already subscribed" error more gently
    //             if error.code == 3001 {
    //               print("Already subscribed to \(self.subscriptionTopic)")
    //             } else {
    //               print("Subscription failed: \(error.localizedDescription)");
    //             }
    //           } else {
    //             self.subscribedToTopic = true;
    //             NSLog("Subscribed to \(self.subscriptionTopic)");
    //           }
    //       })
    // }

    // // [START on_token_refresh]
    // func onTokenRefresh() {
    //     print("The GCM registration token needs to be changed.")
    //     GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    // }
    // func willSendDataMessageWithID(messageID: String!, error: NSError!) {
    //     if (error != nil) {
    //     } else {
    //     }
    // }

    // func didSendDataMessageWithID(messageID: String!) {
    // }

    // func didDeleteMessagesOnServer() {
    // }

    // private func loadGcm(){
    //     var configureError:NSError?
    //     if #available(iOS 8.0,*){
    //         let settings :UIUserNotificationSettings = UIUserNotificationSettings(forTypes:[.Alert,.Badge,.Sound], categories: nil)            
    //         application.registerUserNotificationSettings(settings)
    //         application.registerUserForRemoteNotification()
    //     }else{
    //         let types:UIRemoteNotificationType = [.Alert , .Badge , .Sound]
    //         application.registerForRemoteNotificationTypes(types)
    //     }        
    //     let gcmConfig = GCMConfig.defaultConfig()
    //     gcmConfig.receiverDelegate = self
    //     GCMService.sharedInstance().startWithConfig(gcmConfig)
    // }

    // private subscribeToTopic(){

    // }
}

