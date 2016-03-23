import UIKit

class ResourceBase : HttpBaseResource{
	

	override func parseHeader(_response: NSURLResponse){

	}
	override func parse(_data: NSData){
        print(String(data: _data, encoding: NSUTF8StringEncoding) )
        
	}
}

class ResourceSmaple : ResourceBase{
    override var reqUrl:String{
        get{
            return "http://naver.com"
        }
    }
}