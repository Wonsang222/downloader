//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by 위사모바일 on 2020/09/28.
//  Copyright © 2020 JooDaeho. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override public func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // 푸시를 변경하는 부분
        if let bestAttemptContent = bestAttemptContent{
            bestAttemptContent.title = "\(bestAttemptContent.title)"
            
            // if let imageURLString = bestAttemptContent.userInfo["image"]as? String {
            if let imageURLString = bestAttemptContent.userInfo["img_url"]as? String {
                if let imagePath = self.image(imageURLString) {
                    let imageURL = URL(fileURLWithPath: imagePath)
                    do {
                        let attach = try UNNotificationAttachment(identifier: "img_url", url: imageURL, options: nil)
                        bestAttemptContent.attachments = [attach]
                    } catch {
                        print(error)
                    }
                }
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            // Mark the message as still encrypted.
            bestAttemptContent.title = "\(bestAttemptContent.title)(ERR)"
            bestAttemptContent.subtitle = "(ERR)"
            bestAttemptContent.body = "serviceExtensionTimeWillExpire"
            contentHandler(bestAttemptContent)
        }
    }
    
    
    func image(_ URLString: String)->String?{
        let componet = URLString.components(separatedBy: "/")
        if let fileName = componet.last{
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true)
            if let documentsPath = paths.first{
                let filePath = documentsPath.appending("/"+fileName)
                if let imageURL = URL(string:URLString){
                    do{
                        let data = try NSData(contentsOf: imageURL, options: NSData.ReadingOptions(rawValue:0))
                        if data.write(toFile:filePath, atomically: true){
                            return filePath
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
        return nil
    }
}
