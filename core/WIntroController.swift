//
//  WIntroController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class WIntroController: UIViewController {

	@IBOutlet weak var introView: UIImageView!

	private var saveVersion:Int{
		get{
			if let returnValue = WInfo.introInfo["version"]{
				let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, YES)
				let documentDirectory = paths[0] as! String
				let introFile = documentDirectory.stringByAppendingPathComponent(WInfo.introInfo["file"])
				let manager = NSFileManager.defaultManager()
				if manager.fileExistsAtPath(introFile) {
					return returnValue as! Int
				}
			}
			return 0
		}
	}

	private var saveIntro:UIImage?{
		get{
			if let filePath = WInfo.introInfo["file"]{
				return UIImage(contentsOfFile: filePath)
			}else{
				return nil
			}
		}
	}

	private var saveThemeVersion:Int{
		get{
			if let returnValue = WInfo.themeInfo["version"]{
				return returnValue as! Int
			}
			return 0
		}
	}


    override func viewDidLoad() {
        super.viewDidLoad()
		self.introView.image = self.saveIntro
        self.reqCheckApiKey()
	
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    private func reqCheckApiKey(){
		RSHttp(controller:self).req(
		   ApiFormApp().ap("mode","check_apikey").ap("pack_name",AppProp.appId),
		   successCb: { (resource) -> Void in
		   		let siteUrl = resource.body()["site_url"] as! String
		   		let gcmId = resource.body()["gcm_id"] as! String
		   		let solutionType = resource.body()["solution_type"] as! String
		   		WInfo.appUrl = siteUrl
		   		WInfo.gcmId = gcmId
		   		WInfo.solutionType = solutionType
		   		self.reqGetIntro()
		   }
		)
    }


 	private func reqGetIntro(){
		RSHttp(controller:self).req(
		   ApiFormApp().ap("mode","get_intro").ap("pack_name",AppProp.appId),
		   successCb: { (resource) -> Void in
		   		let serverVersion = resource.body()["version"] as! String
		   		let introImg = resource.body()["intro_img"] as! String
		   		if Int(serverVersion)! > self.saveVersion{
		   			let filePath = getDocumentsDirectory().stringByAppendingPathComponent( NSUUID().UUIDString )
		   			DownLoader().loadUrl(introImg,filePath:filePath,after { (image) -> Void in
		   				if image {
		   					var saveIntroInfo:[String:AnyObject] = [String:AnyObject]()
		   					saveIntroInfo["version"] = Int(serverVersion)!
		   					saveIntroInfo["file"] = filePath
		   					WInfo.saveIntroInfo = saveIntroInfo
   							self.introView.image = self.saveIntro
		   					self.reqTheme()
		   				}
		   			})
		   		}else{
		   			self.reqTheme()
		   		}
		   }
		)
    }

	private func reqTheme(){
		RSHttp(controller:self).req(
		   ApiFormApp().ap("mode","get_theme").ap("pack_name",AppProp.appId),
		   successCb: { (resource) -> Void in
		   		let serverVersion = resource.body()["version"] as! String
		   		if Int(serverVersion)! > self.saveThemeVersion{
					WInfo.themeInfo = resource.body()
		   		}
		   		self.reqUpdate()
		   }
		)
    }

	private func reqUpdate(){
		RSHttp(controller:self).req(
		   ApiFormApp().ap("mode","version_chk").ap("pack_name",AppProp.appId),
		   successCb: { (resource) -> Void in
		   		let serverVersion = resource.body()["version"] as! String
		   		let curVersion = WInfo.appVersion
		   		if serverVersion.compare(curVersion,options:NSStringCompareOptions.NumbericSearch) == NSComparisonResult.OrderedDescending {
					let alert = UIAlertController(title: "알림", message: "새로운 버전이 존재합니다." ,preferredStyle: UIAlertControllerStyle.Alert)
					alert.addAction(UIAlertAction(title: "업데이트" , style: UIAlertActionStyle.Default, handler:{ action in
						NSApplication.sharedApplication().openURL(NSURL: NSURL("itms://itunes.apple.com/us/app/apple-store/id375380948?mt=8")!)
						NSApplication.sharedApplication().terminate(self)
					}))
					alert.addAction(UIAlertAction(title: "취소" , style: UIAlertActionStyle.Default, handler:{ action in
						self.endIntro()
					}))
					self.presentViewController(alert,animated:true, completion: nil)
	   			}else{
	   				self.endIntro()
	   			}
		   }
		)
    }

    private func endIntro(){
    	print("endIntro")
    }
}

