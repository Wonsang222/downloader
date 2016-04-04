import UIKit

class ApiFormApp : HttpBaseResource{
	

    override var reqUrl:String{
        get{
            return "/api/api_from_app.exe.php"
        }
    }

	
	override func parse(_data: NSData) throws{
        print(String(data: _data, encoding: NSUTF8StringEncoding) )
        self.responseData = try NSJSONSerialization.JSONObjectWithData(_data, options: NSJSONReadingOptions()) as! [String:AnyObject]
        let isSuccess = self.body()["success"] == nil ? true : self.body()["success"] as! Bool
        if !isSuccess{
            self.errorCode = ResourceCode.SERVER_ERROR
            self.errorMsg = self.body()["msg"] as! String
        }
        print(self.body())
	}
}

class WingLogin : HttpBaseResource{

    override var reqUrl:String{
        get{
            return WInfo.appUrl + "/main/exec.php"
        }
    }


    override func parse(_data: NSData) throws{
        print(String(data: _data, encoding: NSUTF8StringEncoding) )
        if let value = String(data: _data, encoding: NSUTF8StringEncoding){
            self.responseData = [String:AnyObject]()
            if value.rangeOfString("login.php?err") == nil{
                self.responseData["success"]  = false
            }else{
                self.responseData["success"]  = true
                self.errorCode = ResourceCode.SERVER_ERROR
                self.errorMsg = "로그인에 실패하였습니다."
            }
        }
    }

    override func parseHeader(_response: NSURLResponse) throws{
        
    }
}