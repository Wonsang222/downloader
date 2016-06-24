import UIKit
import WebKit

class ApiFormApp : HttpBaseResource{
	
    
    override init() {
        super.init()
        ap("device","ios")
        ap("device_id",UIDevice.currentDevice().identifierForVendor!.UUIDString)
        ap("country_code",WInfo.countryCode)
        if !WInfo.accountId.isEmpty{
            ap("account_id",WInfo.accountId)
        }
    }

    override var reqUrl:String{
        get{
            return "/api/api_from_app.exe.php"
        }
    }

	
	override func parse(_data: NSData) throws{
//        print( NSString(data: _data, encoding: NSUTF8StringEncoding))
        self.responseData = try NSJSONSerialization.JSONObjectWithData(_data, options: NSJSONReadingOptions()) as! [String:AnyObject]
        let isSuccess = self.body()["success"] == nil ? true : self.body()["success"] as! Bool
        if !isSuccess{
            self.errorCode = ResourceCode.SERVER_ERROR
            self.errorMsg = self.body()["msg"] as! String
        }
	}
}

class WingLogin : HttpBaseResource{

    override var reqUrl:String{
        get{
            return WInfo.appUrl + "/main/exec.php"
        }
    }
    override var shouldCookieHandle:Bool{
        get{
            return true
        }
    }


    override func parse(_data: NSData) throws{
//        print(String(data: _data, encoding: NSUTF8StringEncoding) )
        if let value = String(data: _data, encoding: NSUTF8StringEncoding){
            self.responseData = [String:AnyObject]()
            if value.rangeOfString("login.php?err") == nil{
                self.responseData["success"]  = false
                self.errorMsg = "로그인에 실패하였습니다."
            }else{
                self.responseData["success"]  = true
                self.errorCode = ResourceCode.SERVER_ERROR
            }
        }
    }

    override func parseHeader(_response: NSURLResponse) throws{
        
        let httpResponse: NSHTTPURLResponse = _response as! NSHTTPURLResponse
        
        if let value = httpResponse.allHeaderFields["Set-Cookie"]{
            print("Set Cookie  \(value)")
        }
        
        
    
        
        
    }
    
    
    override func makeRequest() -> NSMutableURLRequest{
        let pageUrl:String = {() -> String in
            if self.reqUrl.hasPrefix("http://") || self.reqUrl.hasPrefix("https://") {
                return self.reqUrl
            }else{
                return HttpInfo.HOST + self.reqUrl
            }
        }()
        let request = NSMutableURLRequest(URL: NSURL(string:pageUrl)!)
        #if DEBUG
            print(pageUrl)
        #endif
        for(key,value) in self.reqHeader {
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.addValue(self.reqUrl, forHTTPHeaderField: "Referer")
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = self.generateParamter().dataUsingEncoding(NSUTF8StringEncoding)
        return request
    }
    
    
}


