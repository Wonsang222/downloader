//
//  ThemeFactory.swift
//  magicapp
//
//  Created by WISA on 2017. 2. 28..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit

class ThemeFactory {
    
    static func createTheme(_ contoller:UIViewController, themeInfo:[String:Any]?) -> CommonMkTheme? {
        
        if themeInfo == nil{
            return nil
        }
        let core = themeInfo!["core"] == nil ? "v1" : (themeInfo!["core"] as! String == "v3" ? "v2" : themeInfo!["core"] as! String)
        if themeInfo!["theme"] == nil {
            return nil
        }
        let theme = themeInfo!["theme"] as! String
        print("theme info :", theme)
        // TODO: Test
        
//        let themeCls = NSClassFromString("\(AppProp.appName!).Theme\(core.uppercased())\(theme.uppercased())") as? CommonMkTheme.Type
//        print("theme dong", themeCls)
//                let themeCls = NSClassFromString("wing.ThemeV2T3") as? CommonMkTheme.Type
        
        switch core {
        case "v1", "v2", "v3":
//            return themeCls!.init(controller: contoller, object:themeInfo!)
            return ThemeV2T2( controller: contoller, object:themeInfo!)
        default:
            return ThemeV1( controller: contoller, object:themeInfo!)
        }
        
        
        //        switch core {
        //            case "v1":
        //                return ThemeV1( controller: contoller, object:themeInfo!)
        //            case "v2","v3":
        //                if theme == "t1" {
        //                    return ThemeV2T1( controller: contoller, object:themeInfo!)
        //                }else if theme == "t2" {
        //                    return ThemeV2T2( controller: contoller, object:themeInfo!)
        //                }else if theme == "t3" {
        //                    return ThemeV2T3( controller: contoller, object:themeInfo!)
        //                }else{
        //                    return ThemeV2T1( controller: contoller, object:themeInfo!)
        //                }
        //            default :
        //                return ThemeV1( controller: contoller, object:themeInfo!)
        //        }
    }
}

class ThemeCache {
    
    private static var __once: () = { 
            StaticInstrance.instance = ThemeCache()
        }()
    
    struct StaticInstrance {
        static var dispatchToken: Int = 0
        static var instance: ThemeCache?
    }
    
    var cache:[Int:UIImage] = [:]
    
    class func share() -> ThemeCache{
        _ = ThemeCache.__once
        return StaticInstrance.instance!
    }
    
    
    
    init() {
        
    }
    
    
    func saveCache(_ url:String,image:UIImage?)  {
        if(image == nil) {
         return
        }
        let document = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)
        if !FileManager.default.fileExists(atPath: "\(document[0])/icon") {
            do{
                try FileManager.default.createDirectory(atPath: "\(document[0])/icon", withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError{
                print(error)
            }
        }
        do{
            try UIImagePNGRepresentation(image!)?.write(to: URL(fileURLWithPath: "\(document[0])/icon/\(url.hashValue)"), options: NSData.WritingOptions.atomicWrite)
        }catch{
        }
        cache[url.hashValue] = image!
    }
    
    func getCache(_ url:String) -> UIImage? {
        if let image = cache[url.hashValue] {
            return image
        }
        let document = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)
        if let imageData = try? Data(contentsOf: URL(fileURLWithPath: "\(document[0])/icon/\(url.hashValue)")) {
            if let returnVal = UIImage(data: imageData) {
                cache[url.hash] = returnVal
                return returnVal
            }
        }
        return nil
    }
    func clear(){
        let fileManager = FileManager.default
        let document = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)
        do{
            let directoryContents = try fileManager.contentsOfDirectory(atPath: "\(document[0])/icon")
            for path in directoryContents {
                try fileManager.removeItem(atPath: "\(document[0])/icon/\(path)")
            }
        }catch{}
    }
}
extension UIButton{
    
    
    func themeIconLoader(_ icon_url:String){
        if let cacheImage = ThemeCache.share().getCache(icon_url) {
            self.setBackgroundImage(cacheImage, for: UIControlState())
            self.setBackgroundImage(cacheImage, for: UIControlState.disabled)
            return
        }
        DispatchQueue.global(qos: .background).async {
            if let datas = try? Data(contentsOf: URL(string: icon_url)!) {
                DispatchQueue.main.async(execute: {
                    let server_img = UIImage(data: datas)?.makeFillImageV2(self)
                    ThemeCache.share().saveCache(icon_url, image: server_img)
                    self.setBackgroundImage(server_img, for: UIControlState())
                    self.setBackgroundImage(server_img, for: UIControlState.disabled)

                });
            }
            
        }
    }
    
    
    func themeIconLoaderN(_ icon_url:String){
        
        if let cacheImage = ThemeCache.share().getCache(icon_url) {
            self.setBackgroundImage(cacheImage, for: UIControlState())
            self.setBackgroundImage(cacheImage, for: UIControlState.disabled)
            return
        }
        DispatchQueue.global(qos: .background).async {
            if let datas = try? Data(contentsOf: URL(string: icon_url)!) {
                let server_img = UIImage(data: datas)
                ThemeCache.share().saveCache(icon_url, image: server_img)
                DispatchQueue.main.async(execute: {
                    self.setBackgroundImage(server_img, for: UIControlState())
                    self.setBackgroundImage(server_img, for: UIControlState.disabled)
                    
                });
            }
            
        }
    }
    
    
}

extension UIImageView{
    
    
    func themeIconLoaderN(_ icon_url:String){
        
        if let cacheImage = ThemeCache.share().getCache(icon_url) {
            self.image = cacheImage
            return
        }
        DispatchQueue.global(qos: .background).async {
            if let datas = try? Data(contentsOf: URL(string: icon_url)!) {
                let server_img = UIImage(data: datas)
                ThemeCache.share().saveCache(icon_url, image: server_img)
                DispatchQueue.main.async(execute: {
                    self.image = server_img
                });
            }
            
        }
    }
}
