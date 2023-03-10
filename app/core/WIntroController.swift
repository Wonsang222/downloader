//
//  WIntroController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import ImageIO
import AppTrackingTransparency


class WIntroController: BaseController,OLImageViewDelegate {
    
    @IBOutlet weak var introView: UIView!
    var loopCount:UInt = 1
    var isLoaded = false
    var oncePlayOk = false
    var updateUse: String?
    var webViewLoadedOk = false
    var introDrawable:UIImage?
    var viewIntroInfo = [String:Any]()
    weak var mainController:WMainController?
    var permissionController:PermissionController?
    var existWinfo = false
    
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
                        return OLImage(data: data)
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
        
        if WInfo.accountId != "" {
            self.existWinfo = true
        }
        
        doPlaySplash()
        self.reqCheckApiKey()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // [0]
    fileprivate func reqMarketingMsg(){
        RSHttp(controller:self, showingPopup:self.existWinfo).req(
            ApiFormApp().ap("mode","get_marketing_msg").ap("pack_name",AppProp.appId),
            successCb: { (resource) -> Void in
                let json = resource.body()["marketing"] as? [String:AnyObject]
                (UIApplication.shared.delegate as! AppDelegate).regApns(callback: { (res) in
                    #if FACEBOOK
                    self.showMarketingPopup({
                        self.showTrackingAuth {
                            self.reqTheme()
                        }
                    },json: json!)
                    #else
                    self.showMarketingPopup({
                        self.reqTheme()
                    },json: json!)
                    #endif
                        
                })
        },errorCb:{ (errorCode,resource) -> Void in
            guard self.existWinfo == true else {
                return self.finishPopup()
            }
            self.dismissProcess()
        })
    }
    
    // [1] 팝업 메시지 나오는 부분
    fileprivate func showMarketingPopup(_ next:@escaping (()-> Void), json:[String:AnyObject]){
        if WInfo.firstProcess{
            if WInfo.getMarketingPopupUrl == "" {
                let dialog = createMarketingAlertV2(msg: json, resp: { (value) in
                    if(json["marketing_re_yn"] as? String == "Y" && value == "N"){
                        let dialog2 = self.createMarketingAlertRe(msg: json, resp: { (value) in
                            self.setMarketingAgree(yn:value,{next()})
                        })
                        self.present(dialog2, animated: false, completion: nil)
                    }else{
                        self.setMarketingAgree(yn:value,{next()})
                    }
                })
                self.present(dialog, animated: false, completion: nil)
            }else{
                let dialog = createMarketingDialog(WInfo.getMarketingPopupUrl, resp: { (value) in
                    self.setMarketingAgree(yn:value,{next()})
                })
                self.present(dialog, animated: false, completion: nil)
            }
        }else{
            next()
        }
    }
    
    fileprivate func showWarningPopup(){
        let dialog = createWarningAlert { (action) in
            exit(0)
        }
        self.present(dialog, animated: false, completion: nil)
    }
    
    fileprivate func showTrackingAuth(_ next:@escaping (()-> Void)) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                    case .authorized:
                        print("dong 1")
                        next()
                        break
                    case .denied:
                        print("dong 2")
                        next()
                        break
                    case .notDetermined:
                        print("dong 3")
                        next()
                        break
                    case .restricted:
                        print("dong 4")
                        next()
                        break
                }
            }
        } else {
            next()
        }
    }
    
    fileprivate func reqCheckApiKey(){
        RSHttp(controller:self, showingPopup: self.existWinfo == true ? false : true).req(
            ApiFormApp().ap("mode","check_apikey").ap("pack_name",AppProp.appId),
            successCb: { (resource) -> Void in
                let siteUrl = resource.body()["site_url"] as! String
                let solutionType = resource.body()["solution_type"] as! String
                let account_id = resource.body()["account_id"] as! String
                let urlParam = resource.body()["url_param"] as! String
                let appName = resource.body()["app_name"] as! String // [1]
                self.updateUse = resource.body()["update_use"] as? String
                
                if let marketingUrl = resource.body()["marketing_url"] as? String{
                    WInfo.getMarketingPopupUrl = marketingUrl
                }
                
                WInfo.appUrl = siteUrl
                WInfo.urlParam = urlParam
                WInfo.solutionType = solutionType
                WInfo.appName = appName // [1]
                
                if let tracker_id = resource.body()["tracker_id"] as? String {
                    WInfo.trackerId = tracker_id
                }
                WInfo.accountId = account_id;
                RSHttp(controller:self, showingPopup: self.existWinfo == true ? false : true).req(
                    ApiFormApp().ap("mode","add_token")
                        .ap("pack_name",AppProp.appId)
                        .ap("token",WInfo.deviceToken)
                )
                self.reqGetIntro()
        },errorCb:{ (errorCode,resource) -> Void in
            guard self.existWinfo == true else {
                return self.finishPopup()
            }
            self.dismissProcess()
        }
        )
    }
    
    
    fileprivate func reqGetIntro(){
        RSHttp(controller:self, showingPopup: self.existWinfo == true ? false : true).req(
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
        },errorCb:{ (errorCode,resource) -> Void in
            guard self.existWinfo == true else {
                return self.finishPopup()
            }
            self.dismissProcess()
        })
    }
    
    func initIntro(){
        if Tools.hasJailbreak() {
            self.showWarningPopup();
        } else if(WInfo.confirmPermission) {
            reqMarketingMsg()
        } else {
            self.permissionController = self.storyboard?.instantiateViewController(withIdentifier: "permission") as? PermissionController
            self.permissionController?.show(parent: self, callback: {
                self.reqMarketingMsg()
            })
        }
    }
    
    fileprivate func reqTheme(){
        RSHttp(controller:self, showingPopup: self.existWinfo == true ? false : true).req(
            ApiFormApp()
                .ap("mode","get_theme")
                // 나인 커스텀 관련
                .ap("able_theme", WInfo.getAbleTheme.joined(separator: ","))
                .ap("pack_name",AppProp.appId),
            successCb: { (resource) -> Void in
                let serverVersion = resource.body()["version"] as! String
                if Int(serverVersion)! > self.saveThemeVersion{
                    WInfo.themeInfo = resource.body()
                }
                self.reqUpdate()
        },errorCb:{ (errorCode,resource) -> Void in
            guard self.existWinfo == true else {
                return self.finishPopup()
            }
            self.dismissProcess()
        }
        )
    }
    
    fileprivate func reqUpdate(){
        if self.updateUse == "N" {
            self.dismissProcess()
            return
        }
        
        RSHttp(controller:self, showingPopup: false).req(
            ResourceVER().ap("mode", "version_chk").ap("bundleId", AppProp.appId).ap("country", "KR"),
            successCb: { (resource) -> Void in
                var serverVersion: String!
                var appUrl: String!
                if let appInfo = resource.body()["results"] as? [[String: AnyObject]] {
                    if appInfo.count > 0 {
                        serverVersion = appInfo[0]["version"] as? String
                        appUrl = appInfo[0]["trackViewUrl"] as? String
                    } else {
                        // 배포전의 테스트플라잇 예외, 로컬버전 삽입
                        serverVersion = AppProp.appVersion
                        appUrl = ""
                    }
                }
                let curVersion = AppProp.appVersion
                
                if Tools.compareVersion(serverVersion, curVersion) && WInfo.ignoreUpdateVersion != serverVersion.replace(".", withString: ""){
                    let alert = UIAlertController(title: "알림", message: "새로운 버전이 존재합니다." ,preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "업데이트" , style: UIAlertActionStyle.default, handler:{ action in
                        UIApplication.shared.openURL(URL(string:appUrl)!)
                        exit(0)
                    }))
                    alert.addAction(UIAlertAction(title: "취소" , style: UIAlertActionStyle.default, handler:{ action in
                        WInfo.ignoreUpdateVersion = serverVersion.replace(".", withString: "")
                        self.dismissProcess()
                    }))
                    self.present(alert,animated:true, completion: nil)
                }else{
                    self.dismissProcess()
                }
        },errorCb:{ (errorCode,resource) -> Void in
            guard self.existWinfo == true else {
                return self.finishPopup()
            }
            self.dismissProcess()
        })
    }
    
    fileprivate func dismissProcess() {
        mainController?.endIntro()
    }
    
    
    fileprivate func doPlaySplash(){
        if isLoaded {
            return
        }
        let splash = self.saveIntro
        if splash == nil { return }
        if self.viewIntroInfo["fileType"] as? String == "gif" {
            self.loopCount = (splash as! OLImage).loopCount
            let imageview = OLImageView(frame: self.introView.bounds)
            imageview.frame = self.introView.bounds
            imageview.contentMode = .scaleAspectFill
            imageview.clipsToBounds = true
            imageview.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            imageview.delegate = self
            imageview.image = splash
            self.introView.addSubview(imageview)
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
        let alert = UIAlertController(title: "알림", message: "데이터가 잘못되어 앱을종료합니다.\n다시 실행해주세요." ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "종료" , style: UIAlertActionStyle.default, handler:{ action in
            exit(0)
        }))
        self.present(alert,animated:true, completion: nil)
    }
    
    func imageViewDidLoop(_ imageView: OLImageView!) {
        oncePlayOk = true
        closeIntroProcess()
    }
    
    func closeIntroProcess(){
        if self.viewIntroInfo["fileType"] as? String == "gif" {
            //            if(self.loopCount != 0) {
            //                self.delayDismissFunc()
            //            }else{
            if oncePlayOk && webViewLoadedOk {
                self.delayDismissFunc()
            }
            //            }
        }else{
            self.delayDismissFunc()
        }
    }
    
    func delayDismissFunc() {
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.dismiss(animated: true, completion: nil)
        })
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

extension String {
    func replaceForNumber(target: String, withString: String) -> Int {
        
        let numOfString = self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
        return Int(numOfString) ?? 0
    }
}

