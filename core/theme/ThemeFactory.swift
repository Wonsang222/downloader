//
//  ThemeFactory.swift
//  magicapp
//
//  Created by WISA on 2017. 2. 28..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit

class ThemeFactory {
    
    static func createTheme(contoller:UIViewController, themeInfo:[String:AnyObject]?) -> CommonMkTheme? {
        if themeInfo == nil{
            return nil
        }
        let core = themeInfo!["core"] == nil ? "v1" : themeInfo!["core"] as! String
        if themeInfo!["theme"] == nil {
            return nil
        }
        let theme = themeInfo!["theme"] as! String
        switch core {
            case "v1":
                return ThemeV1( controller: contoller, object:themeInfo!)
            case "v2":
                if theme == "t1" {
                    return ThemeV2T1( controller: contoller, object:themeInfo!)
                }else if theme == "t2" {
                    return ThemeV2T2( controller: contoller, object:themeInfo!)
                }else{
                    return ThemeV2T1( controller: contoller, object:themeInfo!)
                }
            default :
                return ThemeV1( controller: contoller, object:themeInfo!)
        }
    }
}

class ThemeCache {
    
    struct StaticInstrance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance: ThemeCache?
    }
    
    var cache:[Int:UIImage] = [:]
    
    class func share() -> ThemeCache{
        dispatch_once(&StaticInstrance.dispatchToken) { 
            StaticInstrance.instance = ThemeCache()
        }
        return StaticInstrance.instance!
    }
    
    
    
    init() {
        
    }
    
    
    func saveCache(url:String,image:UIImage?)  {
        if(image == nil) {
         return
        }
        let document = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true)
        if !NSFileManager.defaultManager().fileExistsAtPath("\(document[0])/icon") {
            do{
                try NSFileManager.defaultManager().createDirectoryAtPath("\(document[0])/icon", withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error)
            }
        }
        do{
            try UIImagePNGRepresentation(image!)?.writeToFile("\(document[0])/icon/\(url.hashValue)", options: NSDataWritingOptions.AtomicWrite)
        }catch{
        }
        cache[url.hashValue] = image!
    }
    
    func getCache(url:String) -> UIImage? {
        if let image = cache[url.hashValue] {
            return image
        }
        let document = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true)
        if let imageData = NSData(contentsOfFile: "\(document[0])/icon/\(url.hashValue)") {
            if let returnVal = UIImage(data: imageData) {
                cache[url.hash] = returnVal
                return returnVal
            }
        }
        return nil
    }
    
}
extension UIButton{
    
    
    func themeIconLoader(icon_url:String){
        
        if let cacheImage = ThemeCache.share().getCache(icon_url) {
            self.setBackgroundImage(cacheImage, forState: UIControlState.Normal)
            self.setBackgroundImage(cacheImage, forState: UIControlState.Disabled)
            return
        }
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority,0)) {
            if let datas = NSData(contentsOfURL: NSURL(string: icon_url)!) {
                let server_img = UIImage(data: datas)?.makeFillImageV2(self)
                ThemeCache.share().saveCache(icon_url, image: server_img)
                dispatch_async(dispatch_get_main_queue(), { 
                    self.setBackgroundImage(server_img, forState: UIControlState.Normal)
                    self.setBackgroundImage(server_img, forState: UIControlState.Disabled)

                });
            }
            
        }
    }
    
    
    func themeIconLoaderN(icon_url:String){
        
        if let cacheImage = ThemeCache.share().getCache(icon_url) {
            self.setBackgroundImage(cacheImage, forState: UIControlState.Normal)
            self.setBackgroundImage(cacheImage, forState: UIControlState.Disabled)
            return
        }
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority,0)) {
            if let datas = NSData(contentsOfURL: NSURL(string: icon_url)!) {
                let server_img = UIImage(data: datas)
                ThemeCache.share().saveCache(icon_url, image: server_img)
                dispatch_async(dispatch_get_main_queue(), {
                    self.setBackgroundImage(server_img, forState: UIControlState.Normal)
                    self.setBackgroundImage(server_img, forState: UIControlState.Disabled)
                    
                });
            }
            
        }
    }
    
    
}

extension UIImageView{
    
    
    func themeIconLoaderN(icon_url:String){
        
        if let cacheImage = ThemeCache.share().getCache(icon_url) {
            self.image = cacheImage
            return
        }
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority,0)) {
            if let datas = NSData(contentsOfURL: NSURL(string: icon_url)!) {
                let server_img = UIImage(data: datas)
                ThemeCache.share().saveCache(icon_url, image: server_img)
                dispatch_async(dispatch_get_main_queue(), {
                    self.image = server_img
                });
            }
            
        }
    }
}
