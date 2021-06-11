//
//  Tools.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import ImageIO

class AppProp{
	static var appId:String{
		get{
            let bundle_id = Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String
            if bundle_id.hasSuffix(".lh"){
                return bundle_id.replace(".lh", withString: "")
            }
            if bundle_id.hasSuffix(".adhoc") {
                return bundle_id.replace(".adhoc", withString: "")
            }
            return bundle_id
		}
	}
	static var appVersion:String{
		get{
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
		}
	}
    
    static var adbrixAppKey:String?{
        get{
            return Bundle.main.infoDictionary?["WGAdbrixAppKey"] as? String
        }
    }
    static var adbrixHashKey:String?{
        get{
            return Bundle.main.infoDictionary?["WGAdbrixHashKey"] as? String
        }
    }
    static var gpsUseMessage:String?{
        get{
            return Bundle.main.infoDictionary?["NSLocationWhenInUseUsageDescription"] as? String
        }
    }
    static var appName:String?{
        get{
            return Bundle.main.infoDictionary?["CFBundleName"] as? String
        }
    }
    // 쿠키 클리어 여부
    static var appCookieSet:String?{
        get{
            return Bundle.main.infoDictionary?["WGCookieSetting"] as? String
        }
    }
    
    
    static var appsFlyerDevKey:String?{
        get{
            return Bundle.main.infoDictionary?["WGAppsFlyerDevKey"] as? String
        }
    }
    static var appsFlyerAppId:String?{
        get{
            return Bundle.main.infoDictionary?["WGAppsFlyerAppId"] as? String
        }
    }
    
    
}

class Tools{
    
    
    static func toOriginPixel(_ pixel:CGFloat) -> CGFloat{
        return (pixel / UIScreen.main.scale)
    }
    
    static func safeArea() -> CGFloat{
        if #available(iOS 11.0, *){
            if let returnVal = UIApplication.shared.keyWindow?.safeAreaInsets.bottom{
                return returnVal
            }else{
                return 0
            }
        }else{
            return 0
        }
    }
    static func border1px(parent: UIView, color:String) -> UIView{
        let view = UIView()
        view.frame = CGRect(x: 0, y: parent.frame.height-Tools.toOriginPixel(1.0), width: parent.frame.width, height: Tools.toOriginPixel(1.0))
        view.backgroundColor = UIColor(hexString: color)
        view.autoresizingMask = [.flexibleWidth]
        return view
    }

    static func compareVersion(_ serverVersion: String, _ localVersion: String) -> Bool {
            /// 매직앱 아이폰 버전의 종류는 x.x , x.x.x , x.x.xx 가 있다.
            let server = serverVersion.split(separator:".").map{ String($0) }
            let local = localVersion.split(separator:".").map{ String($0) }
        
            if Int(server[0]+server[1])! > Int(local[0]+local[1])! {
                return true;
            } else if Int(server[0]+server[1])! == Int(local[0]+local[1])! {
                if server.count == 3 && local.count == 3 && Int(server[2])! > Int(local[2])! {
                    return true;
                } else {
                    return false;
                }
            } else {
                return false
            }
    }
    
    static func hasJailbreak() -> Bool {
        
        guard let cydiaUrlScheme = NSURL(string: "cydia://package/com.example.package") else { return false }
        if UIApplication.shared.canOpenURL(cydiaUrlScheme as URL) {
            return true
        }
        #if arch(i386) || arch(x86_64)
        return false
        #endif
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
            fileManager.fileExists(atPath: "/Applications/SBSetting.app") ||
            fileManager.fileExists(atPath: "/Applications/Terminal.app") ||
            fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            fileManager.fileExists(atPath: "/bin/bash") ||
            fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
            fileManager.fileExists(atPath: "/etc/apt") ||
            fileManager.fileExists(atPath: "/usr/bin/ssh") ||
            fileManager.fileExists(atPath: "/private/var/lib/apt") {
            return true
        }
        
        if self.canOpen(path: "/Applications/Cydia.app") ||
           self.canOpen(path: "/Applications/SBSetting.app") ||
            self.canOpen(path: "/Applications/Terminal.app") ||
            self.canOpen(path: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            self.canOpen(path: "/bin/bash") ||
            self.canOpen(path: "/usr/sbin/sshd") ||
            self.canOpen(path: "/etc/apt") ||
            self.canOpen(path: "/usr/bin/ssh") {
            return true
        }
        
        let path = "/private/" + NSUUID().uuidString
        do {
            try "anyString".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            try fileManager.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
    static func canOpen(path: String) -> Bool {
        let file = fopen(path, "r")
        guard file != nil else { return false }
        fclose(file)
        return true
    }
}

class DownLoader{

    func loadImg(_ url:String ,filePath:String ,after:@escaping (_ options:[String:Any]) -> (Void)){
		if let URL = URL(string: url){
	        var request = URLRequest(url: URL)
	        request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error == nil && response != nil{
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    if statusCode == 200{
                        let options = [String:Any]()
                        DispatchQueue.main.async(execute: {
                            do{
                                
                                if url.hasSuffix(".gif") {
                                    try data?.write(to: Foundation.URL(fileURLWithPath: filePath), options: NSData.WritingOptions.atomic)
                                } else {
                                    if let imageOut = UIImage(data:data!) {
                                        if let imageData = UIImagePNGRepresentation(imageOut){
                                            try imageData.write(to: Foundation.URL(fileURLWithPath: filePath), options: NSData.WritingOptions.atomic)
                                        }
                                    }
                                }
                                
                            }catch{
                                print("\(error)")
                            }
                            after(options)
                        })
                    }else{
                        DispatchQueue.main.async(execute: {
                            after([String:Any]())
                        })
                    }
                }
            })
	        task.resume()
		}else{
            DispatchQueue.main.async(execute: {
                after([String:Any]())
            })
		}
	
	}
}
