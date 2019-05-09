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

class ResourceVER: HttpBaseResource {

    override var reqUrl: String {
        get {
            return "https://itunes.apple.com/lookup"
        }
    }
    
    override func parse(_ _data: Data) throws {
        self.responseData = try JSONSerialization.jsonObject(with: _data, options: JSONSerialization.ReadingOptions()) as! [String:AnyObject]
        if let isSuccess = self.body()["resultCount"] as? Int {
            if isSuccess == 0 {
                // 테스트플라잇 및 기타사항
            }
        } else {
            // 데이터 변환시 오류발생 코드 삽입
            self.errorCode = ResourceCode.e9998
            self.errorMsg = "데이터 파싱 에러"
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
        
        let httpResponse: HTTPURLResponse = _response as! HTTPURLResponse
    
        // 기존
//        if let cookies = HTTPCookieStorage.shared.cookies {
//            for cookie in cookies {
//                if cookie.name == "PHPSESSID" {
//                    print("dong cookie name \(cookie.value)")
//                    DispatchQueue.main.sync {
//                        WInfo.setCookie(cookie: cookie)
//                    }
//                }
//            }
//        }
        
        // 수정
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: httpResponse.allHeaderFields as! [String: String], for: _response.url!)
        for cookie in cookies {
            if cookie.name == "PHPSESSID" {
                print("dong cookie name \(cookie.value)")
                DispatchQueue.main.sync {
                    WInfo.setCookie(cookie: cookie)
                }
            }
        }
        
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
        request.httpShouldHandleCookies = false
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = self.generateParamter().data(using: String.Encoding.utf8)
        return request
    }
    
    
}



class ResourceBuilderPushTest : HttpBaseResource{
    
    
    override init() {
        super.init()
//        reqHeader["core_version"] = WInfo.coreVersion
    }
    
    override func makeRequest() -> URLRequest{
        var request = URLRequest(url: URL(string:"http://m.magicapp.co.kr/api/push-one.php")!)
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



