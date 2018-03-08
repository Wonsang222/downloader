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
