import UIKit

class ApiFormApp : HttpBaseResource{
	

    override var reqUrl:String{
        get{
            return "/api/api_from_app.exe.php"
        }
    }

	
	override func parse(_data: NSData){
        print(String(data: _data, encoding: NSUTF8StringEncoding) )
        self.responseData = NSJSONSerialization.JSONObjectWithData(JSONData, options: NSJSONReadingOptions()) as? [String:AnyObject]
        let isSuccess = self.body()["success"] == nil ? true : self.body()["success"]! as Bool
        if !isSuccess{
            self.errorCode = ResourceCode.SERVER_ERROR
            self.errorMsg = self.body()["msg"]! as String
        }
	}
}

