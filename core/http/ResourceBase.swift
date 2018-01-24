import UIKit
import WebKit

class ApiFormApp : HttpBaseResource{
	
    
    override init() {
        super.init()
        _ = ap("device","ios")
        _ = ap("device_id",WInfo.deviceId)
        _ = ap("country_code",WInfo.countryCode)
        if !WInfo.accountId.isEmpty{
            _ = ap("account_id",WInfo.accountId)
        }
        _ = ap("app_version" ,AppProp.appVersion)

        reqHeader["core_version"] = WInfo.coreVersion

    }

    override var reqUrl:String{
        get{
            return "/api/api_from_app.exe.php"
        }
    }

    
	
	override func parse(_ _data: Data) throws{
        //print( NSString(data: _data, encoding: NSUTF8StringEncoding))
        self.responseData = try JSONSerialization.jsonObject(with: _data, options: JSONSerialization.ReadingOptions()) as! [String:AnyObject]
        let isSuccess = self.body()["success"] == nil ? true : self.body()["success"] as! Bool
        if !isSuccess{
            self.errorCode = ResourceCode.server_ERROR
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


    override func parse(_ _data: Data) throws{
//        print(String(data: _data, encoding: NSUTF8StringEncoding) )
        if let value = String(data: _data, encoding: String.Encoding.utf8){
            self.responseData = [String:AnyObject]()
            if value.range(of: "login.php?err") == nil{
                self.responseData["success"]  = false as AnyObject?
                self.errorMsg = "로그인에 실패하였습니다."
            }else{
                self.responseData["success"]  = true as AnyObject?
                self.errorCode = ResourceCode.server_ERROR
            }
        }
    }

    override func parseHeader(_ _response: URLResponse) throws{
        
//        let httpResponse: NSHTTPURLResponse = _response as! NSHTTPURLResponse
        
//        if let value = httpResponse.allHeaderFields["Set-Cookie"]{
//            print("Set Cookie  \(value)")
//        }
        
        
    
        
        
    }
    
    
    override func makeRequest() -> URLRequest{
        let pageUrl:String = {() -> String in
            if self.reqUrl.hasPrefix("http://") || self.reqUrl.hasPrefix("https://") {
                return self.reqUrl
            }else{
                return HttpInfo.HOST + self.reqUrl
            }
        }()
        var request = URLRequest(url: URL(string:pageUrl)!)
        #if DEBUG
            print(pageUrl)
        #endif
        for(key,value) in self.reqHeader {
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.addValue(self.reqUrl, forHTTPHeaderField: "Referer")
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = self.generateParamter().data(using: String.Encoding.utf8)
        return request
    }
    
    
}


class ResourceBuilderPushTest : HttpBaseResource{
    
    
    override init() {
        super.init()
        reqHeader["core_version"] = WInfo.coreVersion
        
    }
    
    override func makeRequest() -> URLRequest{
        var request = URLRequest(url: URL(string:"http://118.129.243.173:8080/apn")!)
        request.addValue(self.reqUrl, forHTTPHeaderField: "Referer")
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = self.generateParamter().data(using: String.Encoding.utf8)
        return request
    }
    
    
    
    override func parse(_ _data: Data) throws{
        self.errorCode = ResourceCode.success
    }
}



