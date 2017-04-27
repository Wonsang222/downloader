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
//            return "kr.co.sroom.magicapp"
            

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
 
}

class Tools{
    
    
    static func toOriginPixel(_ pixel:CGFloat) -> CGFloat{
        return (pixel / UIScreen.main.scale)
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
                        var options = [String:Any]()
                        DispatchQueue.main.async(execute: {
                            do{
                                
                                if url.hasSuffix(".gif") {

                                    
                                    let source = CGImageSourceCreateWithData( data as! CFData , nil)
                                    let propertis = CGImageSourceCopyProperties(source!, nil) as! NSDictionary
                                    let metadata = propertis.object(forKey: kCGImagePropertyGIFDictionary) as! NSDictionary
                                    if metadata.object(forKey: kCGImagePropertyGIFLoopCount) == nil {
                                        options["loopCount"] = "1"
                                    }else{
                                        let loop = metadata.object(forKey: kCGImagePropertyGIFLoopCount) as! Int
                                        options["loopCount"] = String(loop)
                                    }
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
