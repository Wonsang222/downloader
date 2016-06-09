//
//  Tools.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class AppProp{
	static var appId:String{
		get{
			let bundle_id = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as! String
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
            return NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
		}
	}
 
}

class Tools{
    
    
    static func toOriginPixel(pixel:CGFloat) -> CGFloat{
        return (pixel / UIScreen.mainScreen().scale)
    }
}

class DownLoader{

	func loadImg(url:String ,filePath:String ,after:(image:UIImage?) -> (Void)){
		if let URL = NSURL(string: url){
	    	let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
	        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
	        let request = NSMutableURLRequest(URL: URL)
	        request.HTTPMethod = "GET"

	        let task = session.dataTaskWithRequest(request, completionHandler: { data,response,error -> Void in
	            if error == nil && response != nil{
	                let statusCode = (response as! NSHTTPURLResponse).statusCode
	                if statusCode == 200{
	                	if let imageOut = UIImage(data:data!) {
		                	if let imageData = UIImagePNGRepresentation(imageOut){
                                dispatch_async(dispatch_get_main_queue(), {
                                    do{
                                        try imageData.writeToFile(filePath,options:NSDataWritingOptions.DataWritingAtomic)
                                    }catch{
                                        print("\(error)")
                                    }
                                    after(image:imageOut)
                                })
			                	return
		                	}
	                	}
	                }
	            }
                dispatch_async(dispatch_get_main_queue(), {
                    after(image:nil)
                })
	        })
	        task.resume()				
		}else{
            dispatch_async(dispatch_get_main_queue(), {
                after(image: nil)
            })
		}
	
	}
}