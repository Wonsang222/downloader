import UIKit
import MobileCoreServices

class HttpBaseResource{
	var errorCode:ResourceCode = ResourceCode.success
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
    var shouldCookieHandle:Bool{
        get{
            return false
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
            if returnVal != "" {
                returnVal += "&"
            }
            returnVal += key + "=" + value.urlEncode()!
		}
		return returnVal
	}

	func makeRequest() -> URLRequest{
		let pageUrl:String = {() -> String in
			if self.reqUrl.hasPrefix("http://") || self.reqUrl.hasPrefix("https://") {
				return self.reqUrl
			}else{
                if AppProp.appId.contains("com.mywisa.kollshopsg.magicapp") {
                    return "http://118.129.243.248:8109" + self.reqUrl
                }else{
                    return HttpInfo.HOST + self.reqUrl
                }
			}
		}()
		var request = {() -> URLRequest in
			if self.reqMethod == "GET" {
				return URLRequest(url: URL(string:pageUrl + "?" + self.generateParamter())!)
			}else{
				return URLRequest(url: URL(string:pageUrl)!)
			}
		}()
        request.httpShouldHandleCookies = shouldCookieHandle
        #if DEBUG
            print(pageUrl)
        #endif
		for(key,value) in self.reqHeader {
			request.addValue(value, forHTTPHeaderField: key)
		}
		request.httpMethod = self.reqMethod
		if(self.reqMethod != "GET"){
			if self.isMultiPart {
                
				let boundary = "===" + String(Int(Date().timeIntervalSince1970)) + "==="
				request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
				request.setValue("multipart/form-data;boundary=" + boundary, forHTTPHeaderField: "Content-Type")
				request.httpBody = self.makeMultipart(boundary) as Data
			}else{
				request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
				request.httpBody = self.generateParamter().data(using: String.Encoding.utf8)
                #if DEBUG
                print(self.generateParamter())
                #endif
			}
		}
		return request
	}

	fileprivate func makeMultipart(_ boundary:String) -> NSMutableData{
		let multipartData = NSMutableData()
		let delimiter = "--\(boundary)\r\n"
		for (key,value) in self.params{
            #if DEBUG
                print("\(key) , \(value)")
            #endif
			if key.hasPrefix("$") {
				let fileUrl = URL(fileURLWithPath: value)
				let mimetype = self.mimeTypeForPath(value)
				let fileData = try! Data(contentsOf: URL(fileURLWithPath: value))
				multipartData.appendString(delimiter)
				multipartData.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileUrl.lastPathComponent)\"\r\n")
				multipartData.appendString("Content-Type: \(mimetype)\r\n")
				multipartData.appendString("Content-Transfer-Encoding: binary\r\n\r\n")
				multipartData.append(fileData)
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


	fileprivate func mimeTypeForPath(_ path: String) -> String {
	    let url = URL(fileURLWithPath: path)
	    let pathExtension = url.pathExtension

	    if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
	        if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
	            return mimetype as String
	        }
	    }
	    return "application/octet-stream";
	}


    func ap(_ param:String...) -> HttpBaseResource{
        params[param[0]] = param[1]
        return self;
	}
    
    func parse(_ _data: Data) throws{
    }
    
    func parseHeader(_ _response: URLResponse) throws{
    }
}
