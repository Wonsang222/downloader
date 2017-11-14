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
    var introDrawable:UIImage?
    var viewIntroInfo = [String:Any]()
    weak var mainController:WMainController?
    var permissionController:PermissionController?
    
	fileprivate var saveVersion:Int{
		get{
			if let returnValue = WInfo.introInfo["version"]{
                let introFiles = WInfo.introInfo["part"] as! [[String:Any]]
				let manager = FileManager.default
                for item in introFiles{
                    if !manager.fileExists(atPath: (item["file"] as! String)) {
                        return 0
                    }
                }
                return returnValue as! Int
			}
			return 0
		}
	}

	fileprivate var saveIntro:UIImage?{
		get{
            if self.introDrawable != nil { return self.introDrawable }
            let introInfo = WInfo.introInfo
            if introInfo["part"] == nil { return nil }
            let termParts = introInfo["part"] as! [[String:Any]]
            if termParts.count == 0 { return nil }
            var pos = 0;
            if termParts.count > 1 {
                let randomNum:UInt32 = arc4random_uniform(UInt32(termParts.count))
                pos = Int(randomNum)
            }
            var tIntro = termParts[pos]
            if let filePath = tIntro["file"] as? String{
                let fileType = tIntro["fileType"] as? String
                if fileType == "gif" {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                        self.viewIntroInfo = tIntro
                        return UIImage(gifData: data)
                    } catch  {
                       return nil
                    }
                }else{
                    self.viewIntroInfo = tIntro
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
                let dialog = createMarketingAlertV2(resp: { (value) in
                    self.reqMarketingAgree("Y", next: next)
                })
                self.present(dialog, animated: false, completion: nil)
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
		   		let introImg = resource.body()["intro_img"] as! NSArray
		   		if Int(serverVersion)! > self.saveVersion{
                    var introInfo = WInfo.introInfo
                    introInfo["version"] = Int(serverVersion)!
                    var termJsonPart = [[String:Any]]()
                    for (index,item) in introImg.enumerated() {
                        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let filePath = (documentDirectoryURL.appendingPathComponent(UUID().uuidString) as NSURL).filePathURL!.path
                        DownLoader().loadImg(item as! String,filePath:filePath,after:{ (options) -> Void in
                            var termJson = [String:Any]()
                            if introInfo["part"] == nil {
                                introInfo["part"] = [[String:Any]]()
                            }
                            termJson["file"] = filePath
                            if (item as! String).hasSuffix(".gif") {
                                termJson["fileType"] = "gif"
                                termJson["loopCount"] = options["loopCount"]
                            }else if (item as! String).hasSuffix(".jpg") {
                                termJson["fileType"] = "jpg"
                            }else {
                                termJson["fileType"] = "png"
                            }
                            termJsonPart.append(termJson)
                            introInfo["part"] = termJsonPart
                            WInfo.introInfo = introInfo
                            if index == (introImg.count-1) {
                                self.doPlaySplash()
                                self.initIntro()
                            }
                        })
                        
                    }
                  
		   		}else{
                    self.initIntro();
		   		}
		   }
		)
    }
    
    func initIntro(){
        if(WInfo.confirmPermission){
            (UIApplication.shared.delegate as! AppDelegate).regApns(callback: { (res) in
                self.showMarketingPopup({
                    (UIApplication.shared.delegate as! AppDelegate).regApns(callback: { (res) in
                        self.reqTheme()
                    })
                })
            })
        }else{
            self.permissionController = self.storyboard?.instantiateViewController(withIdentifier: "permission") as? PermissionController
            self.permissionController?.show(parent: self, callback: {
                self.showMarketingPopup({
                    (UIApplication.shared.delegate as! AppDelegate).regApns(callback: { (res) in
                        self.reqTheme()
                    })
                })
            })
        }
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
        if splash == nil { return }
        if self.viewIntroInfo["fileType"] as? String == "gif" {
            var loopCount = Int(self.viewIntroInfo["loopCount"] as! String)!
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
        let loopCount = Int(self.viewIntroInfo["loopCount"] as! String)!
        if(loopCount != 1){
            oncePlayOk = true
            closeIntroProcess()
        }
    }
    
    
    func closeIntroProcess(){
        print(self.viewIntroInfo)
        var loopCount:Int?
        if self.viewIntroInfo["fileType"] as? String == "gif" {
            loopCount = Int(self.viewIntroInfo["loopCount"] as! String)!
            if(loopCount != 1){
                self.dismiss(animated: true, completion: nil)
            }else{
                if oncePlayOk && webViewLoadedOk {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }else{
            self.dismiss(animated: true, completion: nil)
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


