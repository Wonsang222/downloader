//
//  WIntroController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class WIntroController: BaseController {

	@IBOutlet weak var introView: UIImageView!
    
    weak var mainController:WMainController?

	private var saveVersion:Int{
		get{
			if let returnValue = WInfo.introInfo["version"]{
				let introFile = WInfo.introInfo["file"] as! String
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
				return UIImage(contentsOfFile: filePath as! String)
			}else{
				return nil
			}
		}
	}

	private var saveThemeVersion:Int{
		get{
			if let returnValue = WInfo.themeInfo["version"]{
				return Int(returnValue as! String)!
			}
			return 0
		}
	}


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.saveIntro != nil {
            self.introView.image = self.saveIntro
        }
        self.reqCheckApiKey()
	
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showMarketingPopup(next:(()-> Void)){
        if WInfo.firstProcess {
            
            if WInfo.getMarketingPopupUrl == "" {
                let dialog = createMarketingAlert({ (UIAlertAction) in
                    self.reqMarketingAgree("Y", next: next)
                }) { (UIAlertAction) in
                    self.reqMarketingAgree("N", next: next)
                }
                self.presentViewController(dialog, animated: true, completion: nil)
            }else{
                let dialog = createMarketingDialog(WInfo.getMarketingPopupUrl, resp: { (value) in
                    self.reqMarketingAgree(value, next: next)
                })
                self.presentViewController(dialog, animated: false, completion: nil)
            }
        }else{
            next()
        }
    }


    private func reqMarketingAgree(yn:String,next:(()->Void)){
        RSHttp(controller:self).req(
            [ApiFormApp().ap("mode","set_marketing_agree").ap("pack_name",AppProp.appId).ap("marketing_agree",yn)],
            successCb: { (resource) -> Void in
                WInfo.firstProcess = false
                WInfo.agreeMarketing = (yn == "Y") ? true : false
                next()
            },errorCb:{ (errorCode,resource) -> Void in
                self.finishPopup()
                
            }
        )
    }
    
 
    private func reqCheckApiKey(){
		RSHttp(controller:self).req(
		   [ApiFormApp().ap("mode","check_apikey").ap("pack_name",AppProp.appId)],
		   successCb: { (resource) -> Void in
		   		let siteUrl = resource.body()["site_url"] as! String
		   		let solutionType = resource.body()["solution_type"] as! String
                let account_id = resource.body()["account_id"] as! String
                let urlParam = resource.body()["url_param"] as! String

		   		WInfo.appUrl = siteUrl
                WInfo.urlParam = urlParam;
                WInfo.solutionType = solutionType
                if let tracker_id = resource.body()["tracker_id"] as? String {
                    WInfo.trackerId = tracker_id
                }
                WInfo.accountId = account_id;
                RSHttp().req(
                    ApiFormApp().ap("mode","add_token")
                    .ap("pack_name",AppProp.appId)
                    .ap("token",WInfo.deviceToken)
                )
		   		self.reqGetIntro()
            },errorCb:{ (errorCode,resource) -> Void in
                self.finishPopup()
            }
		)
    }


 	private func reqGetIntro(){
		RSHttp(controller:self).req(
		   ApiFormApp().ap("mode","get_intro").ap("pack_name",AppProp.appId),
		   successCb: { (resource) -> Void in
		   		let serverVersion = resource.body()["version"] as! String
		   		let introImg = resource.body()["intro_img"] as! String
            
                if let marketingUrl = resource.body()["marketing_url"] as? String{
                    WInfo.getMarketingPopupUrl = marketingUrl
                }
            
		   		if Int(serverVersion)! > self.saveVersion{
                    let documentDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                    let filePath = documentDirectoryURL.URLByAppendingPathComponent(NSUUID().UUIDString)!.filePathURL!.path!
                    DownLoader().loadImg(introImg,filePath:filePath,after:{ (image) -> Void in
		   				if image != nil {
                            var saveIntroInfo:[String:AnyObject] = [String:AnyObject]()
                            saveIntroInfo["version"] = Int(serverVersion)!
                            saveIntroInfo["file"] = filePath
                            WInfo.introInfo = saveIntroInfo
                            self.introView.image = image
                            self.showMarketingPopup(self.reqTheme)
		   				}
		   			})
		   		}else{
                    self.showMarketingPopup(self.reqTheme)
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
		   		let serverVersion = (resource.body()["version"] as! String).replace(".", withString: "")
                let appUrl = resource.body()["app_url"] as! String
                let curVersion = AppProp.appVersion.replace(".", withString: "")
                if Int(serverVersion) < 0 {
                    self.dismissProcess()
                    return
                }
            
		   		if Int(serverVersion) > Int(curVersion) && WInfo.ignoreUpdateVersion != serverVersion {
					let alert = UIAlertController(title: "알림", message: "새로운 버전이 존재합니다." ,preferredStyle: UIAlertControllerStyle.Alert)
					alert.addAction(UIAlertAction(title: "업데이트" , style: UIAlertActionStyle.Default, handler:{ action in
                        UIApplication.sharedApplication().openURL(NSURL(string:appUrl)!)
                        exit(0)
					}))
					alert.addAction(UIAlertAction(title: "취소" , style: UIAlertActionStyle.Default, handler:{ action in
                        WInfo.ignoreUpdateVersion = serverVersion
						self.dismissProcess()
					}))
					self.presentViewController(alert,animated:true, completion: nil)
	   			}else{
	   				self.dismissProcess()
	   			}
		   }
		)
    }

    private func dismissProcess(){
        mainController?.endIntro()
    }
    
    
    private func finishPopup(){
        let alert = UIAlertController(title: "알림", message: "데이터가 잘못되어 앱을종료합니다.\n다시실행해주세요." ,preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "종료" , style: UIAlertActionStyle.Default, handler:{ action in
            exit(0)
        }))
        self.presentViewController(alert,animated:true, completion: nil)

    }
}


class WIntroSegue : UIStoryboardSegue {
    
    override func perform(){
        let source = self.sourceViewController
        let destination = self.destinationViewController
        
        UIView.transitionFromView(source.view,
                                  toView: destination.view,
                                  duration: 1.0,
                                  options: UIViewAnimationOptions.TransitionCrossDissolve,
                                  completion: nil)
    }
}


