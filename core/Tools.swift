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
			return NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String
		}
	}
	static var appVersion:String{
		get{
			return NSBundle.mainBundle().infoDictionary?["CFBunldeShortVersionString"] as? String
		}
	}

}


class DownLoader{

	func loadImg(url:String ,filePath:String ,after:(image:UIImage?)){
		if var URL = NSURL(url){
	    	let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
	        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
	        let request = NSMutableURLRequest(URL: URL)
	        request.HTTPMethod = "GET"
	        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
	            if error == nil {
	                let statusCode = (response as NSHTTPURLResponse).statusCode
	                if statucCode == 200{
	                	if var image = UIImage(data:data) {
		                	if let imageData = UIImagePNGRepresentation(image){
		                		imageData.writeToFile(filePath,atomically:YES)
			                	after(image)
			                	return
\		                	}
	                	}
	                }
	            }
	            after(nil)
	        })
	        task.resume()				
		}else{
			after(nil)	
		}
	
	}
}