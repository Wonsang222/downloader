import UIKit
import MobileCoreServices

class HttpBaseResource{
	var errorCode:ResourceCode = ResourceCode.SUCCESS
	var errorMsg = ""
    var reqUrl:String {
        get{
            return ""
        }
    }
    var reqMethod:String {
        get{
            return "POST"
        }
    }
	var charSet = "utf-8"
	var isMultiPart = false
	var tag:AnyObject?
    var params = [String:String]()
	var responseData = [String:AnyObject]() 
	var reqHeader = [String:String]()

	func body() -> [String:AnyObject]{
		return self.responseData
	}

	
	func generateParamter() -> String{
		var returnVal = "";
		for (key,value) in self.params{
            #if DEBUG
                print("\(key) , \(value)")
            #endif

            if returnVal != "" {
                returnVal += "&"
            }
            returnVal += key + "=" + value.urlEncode()!
		}
		return returnVal
	}

	func makeRequest() -> NSMutableURLRequest{
		let pageUrl:String = {() -> String in
			if self.reqUrl.hasPrefix("http://") || self.reqUrl.hasPrefix("https://") {
				return self.reqUrl
			}else{
				return HttpInfo.HOST + self.reqUrl
			}
		}()
		let request = {() -> NSMutableURLRequest in
			if self.reqMethod == "GET" {
				return NSMutableURLRequest(URL: NSURL(string:pageUrl + "?" + self.generateParamter())!)
			}else{
				return NSMutableURLRequest(URL: NSURL(string:pageUrl)!)
			}
		}()
        #if DEBUG
            print(pageUrl)
        #endif
		for(key,value) in self.reqHeader {
			request.addValue(value, forHTTPHeaderField: key)
		}
		request.HTTPMethod = self.reqMethod
		if(self.reqMethod != "GET"){
			if self.isMultiPart {
                
				let boundary = "===" + String(Int(NSDate().timeIntervalSince1970)) + "==="
				request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
				request.setValue("multipart/form-data;boundary=" + boundary, forHTTPHeaderField: "Content-Type")
				request.HTTPBody = self.makeMultipart(boundary)
			}else{
				request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
				request.HTTPBody = self.generateParamter().dataUsingEncoding(NSUTF8StringEncoding)
                print(self.generateParamter())
			}
		}
		return request
	}

	private func makeMultipart(boundary:String) -> NSMutableData{
		let multipartData = NSMutableData()
		let delimiter = "--\(boundary)\r\n"
		for (key,value) in self.params{
            #if DEBUG
                print("\(key) , \(value)")
            #endif
			if key.hasPrefix("$") {
				let fileUrl = NSURL(fileURLWithPath: value)
				let mimetype = self.mimeTypeForPath(value)
				let fileData = NSData(contentsOfFile: value)!
				multipartData.appendString(delimiter)
				multipartData.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileUrl.lastPathComponent)\"\r\n")
				multipartData.appendString("Content-Type: \(mimetype)\r\n")
				multipartData.appendString("Content-Transfer-Encoding: binary\r\n\r\n")
				multipartData.appendData(fileData)
				multipartData.appendString("\r\n")

			}else{
				multipartData.appendString(delimiter)
				multipartData.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n")
				multipartData.appendString("Content-Type: text/plain; charset=\(charSet)\r\n\r\n")
				multipartData.appendString(value)
				multipartData.appendString("\r\n")
			}
		}
		return multipartData
	}


	private func mimeTypeForPath(path: String) -> String {
	    let url = NSURL(fileURLWithPath: path)
	    let pathExtension = url.pathExtension

	    if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
	        if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
	            return mimetype as String
	        }
	    }
	    return "application/octet-stream";
	}


    func ap(param:String...) -> HttpBaseResource{
        params[param[0]] = param[1]
        return self;
	}
    
    func parse(_data: NSData) throws{
    }
    
    func parseHeader(_response: NSURLResponse) throws{
    }
}