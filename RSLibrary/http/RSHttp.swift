import UIKit
import SystemConfiguration

enum RSHttpStatus{
	case READY
	case SUCCESS
	case FAIL
	case FAIL_RESEND
}

class RSHttp{
	var status:RSHttpStatus = RSHttpStatus.READY
	var isProgress = true
	var isShowingError = true

	func req(resources:HttpBaseResource...){
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
				let appVersion = NSBundle.mainBundle().infoDictionary?["CFBunldeShortVersionString"] as? String
				resource.reqHeader["User-Agent"] = "\(appId)/\(appVersion)"
                
				urlConfig.timeoutIntervalForRequest = Double(HttpInfo.TIMEOUT) / 1000
				urlConfig.timeoutIntervalForResource = Double(HttpInfo.TIMEOUT) / 1000
				do{
					NSURLSession.sharedSession().dataTaskWithRequest(resource.makeRequest(), completionHandler : { data,response,error -> Void in
						if error == nil {
							resource.parseHeader(response!)
							resource.parse(data!)
						}else{
							resource.errorCode = ResourceCode.E9994
						}
						dispatch_semaphore_signal(semaphore)
					}).resume()

				} catch{
					dispatch_semaphore_signal(semaphore)
					resource.errorCode = ResourceCode.E9999
				}
				dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER)
			}
			dispatch_async(dispatch_get_main_queue()){
				self.progressHide()
			}

		}
	}


	private func progressShow(){
		// ProgressBar Show
	}

	private func progressHide(){
		// ProgressBar Hide
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
