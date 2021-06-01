import UIKit
import SystemConfiguration

enum RSHttpStatus{
	case ready
	case success
	case fail
	case fail_RESEND
}
typealias RSHttpSuccessHandler = (_ resource:HttpBaseResource) -> (Void)
typealias RSHttpErrorHandler = (_ errorCode:ResourceCode,_ resource:HttpBaseResource) -> (Void)


class RSHttp{
	fileprivate var status:RSHttpStatus = RSHttpStatus.ready
	var viewController:UIViewController?
	var isProgress = true
	var isShowingError = true

	init(){

	}
	init(controller:UIViewController?){
		self.viewController = controller
	}
	init(controller:UIViewController?, progress:Bool){
		self.viewController = controller
		self.isProgress = progress
	}
	init(controller:UIViewController?, showingPopup:Bool){
		self.viewController = controller
		self.isShowingError = showingPopup
	}
	init(controller:UIViewController?, progress:Bool, showingPopup:Bool){
		self.viewController = controller
		self.isProgress = progress
		self.isShowingError = showingPopup
	}

	func req(_ resources:HttpBaseResource...){
        self.req(resources,successCb:nil,errorCb:nil)
	}

	func req(_ resources:HttpBaseResource..., successCb:RSHttpSuccessHandler?){
        self.req(resources,successCb:successCb,errorCb:nil)
	}
    
    func req(_ resources:HttpBaseResource..., successCb:RSHttpSuccessHandler?, errorCb:RSHttpErrorHandler?){
        self.req(resources,successCb:successCb,errorCb:errorCb)
    }
    
	func req(_ resources:[HttpBaseResource], successCb:RSHttpSuccessHandler?, errorCb:RSHttpErrorHandler?){
		progressShow()
		DispatchQueue.global(qos: .background).async {
			for resource in resources{
				if !self.connectedToNetwork() {
					resource.errorCode = ResourceCode.e8000
                    DispatchQueue.main.async{
                        self.popup(resource,errorCb:errorCb)
                    }
                    break
				}
				let semaphore = DispatchSemaphore(value: 0)
				let urlConfig =	URLSessionConfiguration.default
                if let appId  = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                    var useragent = "\(String(describing: appId))/\(appVersion)"
                    #if APPSFLYER
                    if resource.reqPurpose == "LOGIN" {
                        useragent.append("/WISAAPP_AF_ID(\(EventAppsFlyer.appsFlyerId))")
                    }
                    #endif
                    resource.reqHeader["User-Agent"] = useragent
                }
                
                if(WInfo.accountId == "naingirl") {
                    urlConfig.timeoutIntervalForRequest = Double(60000) / 1000
                    urlConfig.timeoutIntervalForResource = Double(60000) / 1000
                } else {
                    urlConfig.timeoutIntervalForRequest = Double(HttpInfo.TIMEOUT) / 1000
                    urlConfig.timeoutIntervalForResource = Double(HttpInfo.TIMEOUT) / 1000
                }

                URLSession(configuration: urlConfig).dataTask(with: resource.makeRequest(),completionHandler: { (data, response, error) in
					if error == nil {
						do{
							try resource.parseHeader(response!)
							try resource.parse(data!)
						}catch let error as NSError{
                            print("Error: \(error)")
                            print(Thread.callStackSymbols)
							resource.errorCode = ResourceCode.e9998
						}
                        
					}else{
                        print("req error ", error!)
                        if (error! as NSError).code == -1001 {
                            resource.errorCode = ResourceCode.e9996
                        } else {
                            resource.errorCode = ResourceCode.e9994
                        }
					}
					semaphore.signal()
				}).resume()

				_ = semaphore.wait(timeout: DispatchTime.distantFuture)
				DispatchQueue.main.async{

					switch(resource.errorCode){
						case .success:
							if successCb != nil { successCb!(resource) }
						case .server_ERROR,.e9993:
                            self.popup(resource,errorCb:errorCb)
						default:
                            self.popup(resource,errorCb:errorCb)
					}	
				}
			}

			DispatchQueue.main.async{
				self.progressHide()
			}
		}
	}

    fileprivate func popup(_ resource:HttpBaseResource,errorCb:RSHttpErrorHandler?){
        #if DEBUG
        print("Resource Http Error \(resource.errorCode)")
        #endif
		if self.isShowingError && viewController != nil {
            let message = (resource.errorCode == ResourceCode.e9993 || resource.errorCode == ResourceCode.server_ERROR) ? resource.errorMsg : resource.errorCode.message()
			if viewController != nil {
				let alert = UIAlertController(title: "알림", message: message ,preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "확인" , style: UIAlertActionStyle.default, handler:{ action in
                    errorCb?(resource.errorCode,resource)
				}))
				viewController!.present(alert,animated:true, completion: nil)
            }
		}else{
            errorCb?(resource.errorCode,resource)
		}
		
	}

	fileprivate func progressShow(){
		// ProgressBar Show
		if(self.isProgress){

		}
	}

	fileprivate func progressHide(){
		// ProgressBar Hide
		if(self.isProgress){

		}
	}

	fileprivate func connectedToNetwork() -> Bool {
        let defaultRouteReachability: SCNetworkReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.google.com")!
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
	}

}
