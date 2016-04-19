//
//  WInfo.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class WInfo{
	static var appUrl:String{
		get{
			if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("kAppUrl") as? String{
				return returnValue;
			}else{
				return "";		
			}
		}
		set{
			NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "kAppUrl")	
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}

	static var deviceToken:String{
		get{
			if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("kDeviceToken") as? String{
				return returnValue;
			}else{
				return "";		
			}
		}
		set{
			NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "kDeviceToken")	
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}

	static var solutionType:String{
		get{
			if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("kSolutionType") as? String{
				return returnValue;
			}else{
				return "";		
			}
		}
		set{
			NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "kSolutionType")	
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}

	static var introInfo:[String:AnyObject]{
		get{
			if let returnValue = NSUserDefaults.standardUserDefaults().dictionaryForKey("kIntroInfo"){
				return returnValue;
			}else{
				return [String:AnyObject]() 		
			}
		}
		set{
			NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "kIntroInfo")	
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}

	static var themeInfo:[String:AnyObject]{
		get{
			if let returnValue = NSUserDefaults.standardUserDefaults().dictionaryForKey("kThemeInfo"){
				return returnValue;
			}else{
				return [String:AnyObject]() 		
			}
		}
		set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "kThemeInfo")
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}


	static var userInfo:[String:AnyObject]{
		get{
			if let returnValue = NSUserDefaults.standardUserDefaults().dictionaryForKey("kUserInfo"){
				return returnValue;
			}else{
				return [String:AnyObject]()
			}
		}
		set{
			NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "kUserInfo")	
			NSUserDefaults.standardUserDefaults().synchronize()
		}
	}

    
    
    static func defaultCookie() -> String{
        
        var arrayValues: [String] = []
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string:WInfo.appUrl)!){
            for cookie in cookies {
                arrayValues.append("\(cookie.name)=\(cookie.value)")
            }
        }
        return arrayValues.joinWithSeparator(",")
    }

}
