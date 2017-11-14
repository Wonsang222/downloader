//
//  WInfo.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class WInfo{
    
//    static let coreVersion:String = "wmgkcore_v2"
//    static let coreVersion:String = "wmgkcore_v2.1.1" //공유하기 API 추가
//    static let coreVersion:String = "wmgkcore_v2.1.2" //GIF Splash 추가
    static let coreVersion:String = "wmgkcore_v3.0.0" //바코드 인식기
    
	static var appUrl:String{
		get{
			if let returnValue = UserDefaults.standard.object(forKey: "kAppUrl") as? String{
//              return "http://118.129.243.73/ws_magic.html"
              return returnValue
			}else{
				return ""
			}
		}
		set{
			UserDefaults.standard.set(newValue, forKey: "kAppUrl")	
			UserDefaults.standard.synchronize()
		}
	}

	static var deviceToken:String{
		get{
			if let returnValue = UserDefaults.standard.object(forKey: "kDeviceToken") as? String{
				return returnValue;
			}else{
				return "";		
			}
		}
		set{
			UserDefaults.standard.set(newValue, forKey: "kDeviceToken")	
			UserDefaults.standard.synchronize()
		}
	}
    
    static var countryCode:String{
        get{
            
            if let value = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) {
               return value as! String
            }else{
                return ""
            }
        }
    }

	static var solutionType:String{
		get{
			if let returnValue = UserDefaults.standard.object(forKey: "kSolutionType") as? String{
				return returnValue;
			}else{
				return "";		
			}
		}
		set{
			UserDefaults.standard.set(newValue, forKey: "kSolutionType")	
			UserDefaults.standard.synchronize()
		}
	}

	static var introInfo:[String:Any]{
		get{
			if let returnValue = UserDefaults.standard.dictionary(forKey: "kIntroInfoR"){
				return returnValue as [String : Any];
			}else{
				return [String:Any]() 		
			}
		}
		set{
			UserDefaults.standard.set(newValue, forKey: "kIntroInfoR")	
			UserDefaults.standard.synchronize()
		}
	}

	static var themeInfo:[String:AnyObject]{
		get{
            
			if let returnValue = UserDefaults.standard.dictionary(forKey: "kThemeInfo"){
                return returnValue as [String : AnyObject];
            }else{
				return [String:AnyObject]()
			}
		}
		set{
            UserDefaults.standard.set(newValue, forKey: "kThemeInfo")
			UserDefaults.standard.synchronize()
		}
	}
    
    static var trackerId:String{
        get{
            if let returnValue = UserDefaults.standard.string(forKey: "kTrackerID"){
                return returnValue;
            }else{
                return ""
            }
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "kTrackerID")
            UserDefaults.standard.synchronize()
        }
    }

    static var accountId:String{
        get{
            if let returnValue = UserDefaults.standard.string(forKey: "kAccountID"){
                return returnValue;
            }else{
                return ""
            }
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "kAccountID")
            UserDefaults.standard.synchronize()
        }
    }
    static var getMarketingPopupUrl:String{
        get{
            if let returnValue = UserDefaults.standard.string(forKey: "kGetMarketingPopupUrl"){
                return returnValue;
            }else{
                return ""
            }
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "kGetMarketingPopupUrl")
            UserDefaults.standard.synchronize()
        }
    }
    

	static var userInfo:[String:AnyObject]{
		get{
			if let returnValue = UserDefaults.standard.dictionary(forKey: "kUserInfo"){
				return returnValue as [String : AnyObject];
			}else{
				return [String:AnyObject]()
			}
		}
		set{
			UserDefaults.standard.set(newValue, forKey: "kUserInfo")	
			UserDefaults.standard.synchronize()
		}
	}
    
    
    static func defaultCookies() -> [String]{
        var arrayValues: [String] = []
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                arrayValues.append(cookie.name+"=" + cookie.value)
                if cookie.domain.contains( WInfo.appUrl.replace("http://m.", withString: "")){
                    
                }
            }
        }
        return arrayValues;
    }
    
    static func defaultCookieForName(_ name:String) -> HTTPCookie?{
        if let cookies = HTTPCookieStorage.shared.cookies {
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
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                arrayValues.append(cookie.name+"=" + cookie.value)
                if cookie.domain.contains( WInfo.appUrl.replace("http://m.", withString: "")){
                    
                }
            }
        }
        return arrayValues.joined(separator: "; ")
    }
    
    static func clearCookie() {
        if let cookies = HTTPCookieStorage.shared.cookies(for: URL(string:WInfo.appUrl)!){
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
    }
    
    static func clearSessionCookie() {
        if let cookies = HTTPCookieStorage.shared.cookies(for: URL(string:WInfo.appUrl)!){
            for cookie in cookies {
                if cookie.isSessionOnly {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                }
            }
        }
        
    }
    
    static var firstProcess:Bool{
        get{
            if let returnValue = UserDefaults.standard.string(forKey: "kFirstProcess"){
                return returnValue == "NO" ? false : true
            }else{
                return true
            }
        }
        set{
            UserDefaults.standard.set(newValue ? "YES" : "NO", forKey: "kFirstProcess")
            UserDefaults.standard.synchronize()
        }
    }

    static var agreeMarketing:Bool{
        get{
            if let returnValue = UserDefaults.standard.string(forKey: "kAgreeMarketing"){
                return returnValue == "NO" ? false : true
            }else{
                return false
            }
        }
        set{
            UserDefaults.standard.set(newValue ? "YES" : "NO", forKey: "kAgreeMarketing")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var ignoreUpdateVersion:String{
        get{
            if let returnValue = UserDefaults.standard.string(forKey: "kIgnoreUpdateVersion"){
                return returnValue;
            }else{
                return ""
            }
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "kIgnoreUpdateVersion")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    static var urlParam:String{
        get{
            if let returnValue = UserDefaults.standard.string(forKey: "kUrlParam"){
                return returnValue;
            }else{
                return ""
            }
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "kUrlParam")
            UserDefaults.standard.synchronize()
        }
    }

    static var confirmPermission:Bool{
        get{
            if let returnValue = UserDefaults.standard.string(forKey: "kConfirmPermission"){
                return returnValue == "NO" ? false : true
            }else{
                return false
            }
        }
        set{
            UserDefaults.standard.set(newValue ? "YES" : "NO", forKey: "kConfirmPermission")
            UserDefaults.standard.synchronize()
        }
    }
    
}
