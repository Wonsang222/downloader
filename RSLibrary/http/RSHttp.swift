import UIKit
import SystemConfiguration

enum RSHttpStatus{
	case READY
	case SUCCESS
	case FAIL
	case FAIL_RESEND
}
typealias RSHttpSuccessHandler = (resource:HttpBaseResource) -> (Void)
typealias RSHttpErrorHandler = (errorCode:ResourceCode,resource:HttpBaseResource) -> (Void)


class RSHttp{
	private var status:RSHttpStatus = RSHttpStatus.READY
	var viewController:UIViewController?
	var isProgress = true
	var isShowingError = true

	init(){

	}
	init(controller:UIViewController){
		self.viewController = controller
	}
	init(controller:UIViewController, progress:Bool){
		self.viewController = controller
		self.isProgress = progress
	}
	init(controller:UIViewController, showingPopup:Bool){
		self.viewController = controller
		self.isShowingError = showingPopup
	}
	init(controller:UIViewController, progress:Bool, showingPopup:Bool){
		self.viewController = controller
		self.isProgress = progress
		self.isShowingError = showingPopup
	}

	func req(resources:HttpBaseResource...){
            print(resources)
        self.req(resources,successCb:nil,errorCb:nil)
	}

	func req(resources:HttpBaseResource..., successCb:RSHttpSuccessHandler?){
        self.req(resources,successCb:successCb,errorCb:nil)
	}

	func req(resources:[HttpBaseResource], successCb:RSHttpSuccessHandler?, errorCb:RSHttpErrorHandler?){
		progressShow()
		let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
		dispatch_async(dispatch_get_global_queue(priority,0)) {
			for resource in resources{
				if !self.connectedToNetwork() {
					resource.errorCode = ResourceCode.E8000
					continue
				}
				let semaphore = dispatch_semaphore_create(0)
				let urlConfig =	NSURLSessionConfiguration.defaultSessionConfiguration()
                let appId = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String
				let appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
				resource.reqHeader["User-Agent"] = "\(appId)/\(appVersion)"
                
				urlConfig.timeoutIntervalForRequest = Double(HttpInfo.TIMEOUT) / 1000
				urlConfig.timeoutIntervalForResource = Double(HttpInfo.TIMEOUT) / 1000
				NSURLSession.sharedSession().dataTaskWithRequest(resource.makeRequest(), completionHandler : { data,response,error -> Void in
					if error == nil {
						do{
							try resource.parseHeader(response!)
							try resource.parse(data!)
						}catch {
							resource.errorCode = ResourceCode.E9998
						}
					}else{
						resource.errorCode = ResourceCode.E9994
					}
					dispatch_semaphore_signal(semaphore)
				}).resume()

				dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER)
				dispatch_async(dispatch_get_main_queue()){

					switch(resource.errorCode){
						case .SUCCESS:
							if successCb != nil { successCb!(resource:resource) }
						case .SERVER_ERROR,.E9993:
                            self.popup(resource,errorCb:errorCb)
						default:
                            self.popup(resource,errorCb:errorCb)
					}	
				}
			}

			dispatch_async(dispatch_get_main_queue()){
				self.progressHide()
			}
		}
	}

    private func popup(resource:HttpBaseResource,errorCb:RSHttpErrorHandler?){
		if self.isShowingError && viewController != nil {
			if viewController != nil {
				let alert = UIAlertController(title: "알림", message: resource.errorMsg ,preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "확인" , style: UIAlertActionStyle.Default, handler:{ action in
					if errorCb != nil {
                        errorCb!(errorCode:resource.errorCode,resource:resource)
					}
				}))
				viewController!.presentViewController(alert,animated:true, completion: nil)
            }
		}else{
			if errorCb != nil {
                errorCb!(errorCode:resource.errorCode,resource:resource)
			}
		}
		
	}

	private func progressShow(){
		// ProgressBar Show
		if(self.isProgress){

		}
	}

	private func progressHide(){
		// ProgressBar Hide
		if(self.isProgress){

		}
	}

	private func connectedToNetwork() -> Bool {
	    var zeroAddress = sockaddr_in()
	    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
	    zeroAddress.sin_family = sa_family_t(AF_INET)
	    
	    guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
	        SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
	    }) else {
	        return false
	    }
	    
	    var flags : SCNetworkReachabilityFlags = []
	    
	    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
	        return false
	    }
	    
	    let isReachable = flags.contains(.Reachable)
	    let needsConnection = flags.contains(.ConnectionRequired)
    	return (isReachable && !needsConnection)
	}

}
