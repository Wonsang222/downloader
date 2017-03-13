//
//  WInfo.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class WInfo{
    
    static let coreVersion:String = "wmgkcore_v2"
    
	static var appUrl:String{
		get{
			if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("kAppUrl") as? String{
//                return "http://m.nain.co.kr"
//                return "http://m.bh.wisaweb.co.kr"
//                return "http://118.129.243.73/ws_magic.html"
                return "http://118.129.243.248:8109"
//              return returnValue
			}else{
				return ""
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
    
    static var countryCode:String{
        get{
            
            if let value = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) {
               return value as! String
            }else{
                return ""
            }
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
            
			if var returnValue = NSUserDefaults.standardUserDefaults().dictionaryForKey("kThemeInfo"){
//                returnValue["theme"] = "v2"
//                returnValue["theme_select"] = "t2"
//                var ui_data = returnValue["ui_data"] as! [String:AnyObject]
//                var menus = ui_data["menus"] as! [[String:AnyObject]]
//                for (index,menu) in menus.enumerate(){
//                    if menus[index]["click"] as! String == "push"{
//                        menus[index]["badge_url"] = "http://118.129.243.73:8080/js/ic_a_isnew.png"
//                    }
//                    menus[index]["icon_url"] = "http://118.129.243.73:8080/js/ic_a_menu_disable.png"
//                }
//                var navibar = ui_data["navibar"] as! [String:AnyObject]
//                
//                navibar["status_style"] = "Light"
//                navibar["bg"] = "#ff0000"
//                navibar["icon_url"] = "http://118.129.243.73:8080/js/ic_navi_back.png"
//
//                
//                ui_data["menus"] = menus
//                ui_data["navibar"] = navibar
//                returnValue["ui_data"] = ui_data
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
    
    static var trackerId:String{
        get{
            if let returnValue = NSUserDefaults.standardUserDefaults().stringForKey("kTrackerID"){
                return returnValue;
            }else{
                return ""
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "kTrackerID")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    static var accountId:String{
        get{
            if let returnValue = NSUserDefaults.standardUserDefaults().stringForKey("kAccountID"){
                return returnValue;
            }else{
                return ""
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "kAccountID")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    static var getMarketingPopupUrl:String{
        get{
            if let returnValue = NSUserDefaults.standardUserDefaults().stringForKey("kGetMarketingPopupUrl"){
                return returnValue;
            }else{
                return ""
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "kGetMarketingPopupUrl")
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
    
    
    static func defaultCookies() -> [String]{
        var arrayValues: [String] = []
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            for cookie in cookies {
                arrayValues.append(cookie.name+"=" + cookie.value)
                if cookie.domain.containsString( WInfo.appUrl.replace("http://m.", withString: "")){
                    
                }
            }
        }
        return arrayValues;
    }
    
    static func defaultCookieForName(name:String) -> NSHTTPCookie?{
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            for cookie in cookies {
                if(cookie.name == "PHPSESSID"){
                    return cookie
                }
            }
        }
        return nil
    }
    
    static func defaultCookie() -> String{
        var arrayValues: [String] = []
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            for cookie in cookies {
                arrayValues.append(cookie.name+"=" + cookie.value)
                if cookie.domain.containsString( WInfo.appUrl.replace("http://m.", withString: "")){
                    
                }
            }
        }
        return arrayValues.joinWithSeparator("; ")
    }
    
    static func clearCookie() {
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string:WInfo.appUrl)!){
            for cookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
        
    }
    
    static func clearSessionCookie() {
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string:WInfo.appUrl)!){
            for cookie in cookies {
                if cookie.sessionOnly {
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
                }
            }
        }
        
    }
    
    static var firstProcess:Bool{
        get{
            if let returnValue = NSUserDefaults.standardUserDefaults().stringForKey("kFirstProcess"){
                return returnValue == "NO" ? false : true
            }else{
                return true
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue ? "YES" : "NO", forKey: "kFirstProcess")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    static var agreeMarketing:Bool{
        get{
            if let returnValue = NSUserDefaults.standardUserDefaults().stringForKey("kAgreeMarketing"){
                return returnValue == "NO" ? false : true
            }else{
                return false
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue ? "YES" : "NO", forKey: "kAgreeMarketing")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    static var ignoreUpdateVersion:String{
        get{
            if let returnValue = NSUserDefaults.standardUserDefaults().stringForKey("kIgnoreUpdateVersion"){
                return returnValue;
            }else{
                return ""
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "kIgnoreUpdateVersion")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    
    static var urlParam:String{
        get{
            if let returnValue = NSUserDefaults.standardUserDefaults().stringForKey("kUrlParam"){
                return returnValue;
            }else{
                return ""
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "kUrlParam")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

}
