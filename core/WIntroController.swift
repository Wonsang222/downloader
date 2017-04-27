//
//  WIntroController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import ImageIO
import SwiftyGif


class WIntroController: BaseController,SwiftyGifDelegate {

	@IBOutlet weak var introView: UIView!
    var isLoaded = false
    var oncePlayOk = false
    var webViewLoadedOk = false
    weak var mainController:WMainController?

	fileprivate var saveVersion:Int{
		get{
			if let returnValue = WInfo.introInfo["version"]{
				let introFile = WInfo.introInfo["file"] as! String
				let manager = FileManager.default
				if manager.fileExists(atPath: introFile) {
					return returnValue as! Int
				}
			}
			return 0
		}
	}

	fileprivate var saveIntro:UIImage?{
		get{
    		if let filePath = WInfo.introInfo["file"] as? String{
                let fileType = WInfo.introInfo["fileType"] as? String
                if fileType == "gif" {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                        return UIImage(gifData: data)
                    } catch  {
                       return nil
                    }
                }else{
                    return UIImage(contentsOfFile: filePath)
                }
			}else{
				return nil
			}
		}
	}

	fileprivate var saveThemeVersion:Int{
		get{
			if let returnValue = WInfo.themeInfo["version"]{
				return Int(returnValue as! String)!
			}
			return 0
		}
	}


    override func viewDidLoad() {
        super.viewDidLoad()
        doPlaySplash()
        self.reqCheckApiKey()
	
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func showMarketingPopup(_ next:@escaping (()-> Void)){
        if WInfo.firstProcess {
            
            if WInfo.getMarketingPopupUrl == "" {
                let dialog = createMarketingAlert({ (UIAlertAction) in
                    self.reqMarketingAgree("Y", next: next)
                }) { (UIAlertAction) in
                    self.reqMarketingAgree("N", next: next)
                }
                self.present(dialog, animated: true, completion: nil)
            }else{
                let dialog = createMarketingDialog(WInfo.getMarketingPopupUrl, resp: { (value) in
                    self.reqMarketingAgree(value, next: next)
                })
                self.present(dialog, animated: false, completion: nil)
            }
        }else{
            next()
        }
    }


    fileprivate func reqMarketingAgree(_ yn:String,next:@escaping (()->Void)){
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
    
 
    fileprivate func reqCheckApiKey(){
		RSHttp(controller:self).req(
		   [ApiFormApp().ap("mode","check_apikey").ap("pack_name",AppProp.appId)],
		   successCb: { (resource) -> Void in
		   		let siteUrl = resource.body()["site_url"] as! String
		   		let solutionType = resource.body()["solution_type"] as! String
                let account_id = resource.body()["account_id"] as! String
                let urlParam = resource.body()["url_param"] as! String

                if let marketingUrl = resource.body()["marketing_url"] as? String{
                    WInfo.getMarketingPopupUrl = marketingUrl
                }

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


 	fileprivate func reqGetIntro(){
		RSHttp(controller:self).req(
		   ApiFormApp().ap("mode","get_intro").ap("pack_name",AppProp.appId),
		   successCb: { (resource) -> Void in
		   		let serverVersion = resource.body()["version"] as! String
		   		let introImg = "https://media.giphy.com/media/9fbYYzdf6BbQA/giphy.gif"//resource.body()["intro_img"] as! String
//            let introImg = "http://118.129.243.73/giphy1.gif"
//            let introImg = "https://davidwalsh.name/demo/herrera-wtf-once.gif"
            

            
//            return UIImage(contentsOfFile: "https://ssl.pstatic.net/tveta/libs/1153/1153511/20170425112142-F2mY2fkp.jpg")
		   		if Int(serverVersion)! > self.saveVersion{
                    let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let filePath = (documentDirectoryURL.appendingPathComponent(UUID().uuidString) as NSURL).filePathURL!.path
                    DownLoader().loadImg(introImg,filePath:filePath,after:{ (options) -> Void in
                        var saveIntroInfo = [String:Any]()
                        saveIntroInfo["version"] = Int(serverVersion)!
                        saveIntroInfo["file"] = filePath
                        if introImg.hasSuffix(".gif") {
                            saveIntroInfo["fileType"] = "gif"
                            saveIntroInfo["loopCount"] = options["loopCount"]
                        }else if introImg.hasSuffix(".jpg") {
                            saveIntroInfo["fileType"] = "jpg"
                        }else {
                            saveIntroInfo["fileType"] = "png"
                        }
                        WInfo.introInfo = saveIntroInfo
                        self.doPlaySplash()
                        self.reqTheme()
		   			})
		   		}else{
                    self.reqTheme()
		   		}
		   }
		)
    }

	fileprivate func reqTheme(){
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
    

	fileprivate func reqUpdate(){
		RSHttp(controller:self).req(
		   ApiFormApp().ap("mode","version_chk").ap("pack_name",AppProp.appId),
		   successCb: { (resource) -> Void in
		   		let serverVersion = (resource.body()["version"] as! String).replace(".", withString: "")
                let appUrl = resource.body()["app_url"] as! String
                let curVersion = AppProp.appVersion.replace(".", withString: "")
                let update_use = resource.body()["update_use"] as! String
                if update_use == "N" {
                    self.dismissProcess()
                    return
                }
		   		if Int(serverVersion)! > Int(curVersion)! && WInfo.ignoreUpdateVersion != serverVersion {
					let alert = UIAlertController(title: "알림", message: "새로운 버전이 존재합니다." ,preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "업데이트" , style: UIAlertActionStyle.default, handler:{ action in
                        UIApplication.shared.openURL(URL(string:appUrl)!)
                        exit(0)
					}))
					alert.addAction(UIAlertAction(title: "취소" , style: UIAlertActionStyle.default, handler:{ action in
                        WInfo.ignoreUpdateVersion = serverVersion
						self.dismissProcess()
					}))
					self.present(alert,animated:true, completion: nil)
	   			}else{
	   				self.dismissProcess()
	   			}
		   }
		)
    }

    fileprivate func dismissProcess(){
        mainController?.endIntro()
    }
    
    
    fileprivate func doPlaySplash(){
        if isLoaded {
            return
        }
        let splash = self.saveIntro
        if splash == nil {
            return
        }
        if WInfo.introInfo["fileType"] as? String == "gif" {
            var loopCount = Int(WInfo.introInfo["loopCount"] as! String)!
            loopCount = loopCount == 0 ? -1 : loopCount
            let imagview = UIImageView(gifImage:splash!, manager: SwiftyGifManager(memoryLimit:20), loopCount : loopCount)
            imagview.frame = self.introView.bounds
            imagview.contentMode = .scaleAspectFill
            imagview.clipsToBounds = true
            imagview.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            imagview.delegate = self
            self.introView.addSubview(imagview)
        
        }else{
            let imagview = UIImageView(frame: self.introView.bounds)
            imagview.frame = self.introView.bounds
            imagview.contentMode = .scaleAspectFill
            imagview.clipsToBounds = true
            imagview.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            imagview.image = splash
            self.introView.addSubview(imagview)
        }
  
        
        
    }
    
    
    fileprivate func finishPopup(){
        let alert = UIAlertController(title: "알림", message: "데이터가 잘못되어 앱을종료합니다.\n다시실행해주세요." ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "종료" , style: UIAlertActionStyle.default, handler:{ action in
            exit(0)
        }))
        self.present(alert,animated:true, completion: nil)

    }
    
    
    func gifDidLoop() {
        let loopCount = Int(WInfo.introInfo["loopCount"] as! String)!
        if(loopCount != 1){
            oncePlayOk = true
            closeIntroProcess()
        }
    }
    
    
    func closeIntroProcess(){
        let loopCount = Int(WInfo.introInfo["loopCount"] as! String)!
        if(loopCount != 1){
            self.dismiss(animated: true, completion: nil)
        }else{
            if oncePlayOk && webViewLoadedOk {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
}


class WIntroSegue : UIStoryboardSegue {
    
    override func perform(){
        let source = self.source
        let destination = self.destination
        
        UIView.transition(from: source.view,
                                  to: destination.view,
                                  duration: 1.0,
                                  options: UIViewAnimationOptions.transitionCrossDissolve,
                                  completion: nil)
    }
}


