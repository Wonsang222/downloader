//
//  WebController.swift
//  wing
//
//  Created by WISA on 2018. 1. 8..
//  Copyright © 2018년 JooDaeho. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
//import ZBarSDK
import AVKit
import AVFoundation
import WebKit
#if GPSENABLED
import CoreLocation
#endif

class WebEngine : NSObject,ABPeoplePickerNavigationControllerDelegate {
    static let gPool:WKProcessPool = WKProcessPool()
    let CONTACT_CALLBACK = 40
    let SCANNER_CALLBACK = 50
    var controllerCallback:[Int:String] = [:]
    var controller:BaseWebController
    var webDelegate:WebControlDelegate?
    
    init(_ controller:BaseWebController) {
        self.controller = controller
        super.init()
    }
    
    var currentURL:URL? {
        get {
            return nil
        }
    }
    
    let paySchema = [
        ["schema" : "smartxpay-transfer", "url" : "https://itunes.apple.com/kr/app/seumateu-egseupei-gyejwaiche/id393794374?mt=8"],  //SmartXPay
        ["schema" : "hdcardappcardansimclick", "url" : "http://itunes.apple.com/kr/app/id702653088?mt=8"],  //현대카드
        ["schema" : "shinhan-sr-ansimclick", "url" : "https://itunes.apple.com/kr/app/sinhan-mobilegyeolje/id572462317?mt=8"], //신한카드
        ["schema" : "kb-acp", "url" : "https://itunes.apple.com/kr/app/kbgugmin-aebkadue/id695436326?mt=8"],    //KB카드
        ["schema" : "mpocket.online.ansimclick", "url" : "https://itunes.apple.com/kr/app/mpokes/id535125356?mt=8&ls=1"], // 삼성카드
        ["schema" : "tswansimclick", "url" : "https://itunes.apple.com/kr/app/id430282710"],   //삼성 서랍
        
        ["schema" : "lotteappcard", "url" : "https://itunes.apple.com/kr/app/losde-aebkadeu/id688047200?mt=8"], //롯데카드
        ["schema" : "lottesmartpay", "url" : ""], //롯데
        
        ["schema" : "cloudpay", "url" : "itmss://itunes.apple.com/app/id847268987"], //외환카드 , 하나카드
        ["schema" : "nhappcardansimclick", "url" : "http://itunes.apple.com/kr/app/nhnonghyeob-mobailkadeu-aebkadeu/id698023004?mt=8"], //NH카드
        ["schema" : "citispay", "url" : "https://itunes.apple.com/kr/app/citi-cards-mobile-ssitikadeu/id373559493?l=en&mt=8"],          //NH카드
        ["schema" : "lguthepay", "url" : "https://itunes.apple.com/kr/app/paynow/id760098906?mt=8"],          //페이나우
        
        ["schema" : "smhyundaiansimclick", "url" : ""],
        ["schema" : "nonghyupcardansimclick", "url" : ""],
        ["schema" : "nhallonepayansimclick" , "url" : ""],  // 농협앱카드 추가 관련
        
        ["schema" : "lguthepay-xpay", "url" : ""],
        ["schema" : "payco", "url" : ""],
        ["schema" : "smshinhanansimclick", "url" : ""],
        ["schema" : "ansimclickscard", "url" : ""],     // 삼성카드
        ["schema" : "ansimclickipcollect", "url" : ""], // 삼성카드
        ["schema" : "vguardstart", "url" : ""], // 삼성카드
        ["schema" : "samsungpay", "url" : ""], // 삼성카드
        ["schema" : "scardcertiapp", "url" : ""], // 삼성카드
        
        ["schema" : "ispmobile", "url" : "https://itunes.apple.com/kr/app/mobail-anjeongyeolje-isp/id369125087?mt=8"],  // ISP
        
        ["schema" : "citispay", "url" : ""], // 삼성카드
        ["schema" : "nhallonepayansimclick", "url" : ""], // 삼성카드
        ["schema" : "citispay", "url" : ""], // 삼성카드
        ["schema" : "citicardappkr", "url" : ""], // 삼성카드
        ["schema" : "citimobileapp", "url" : ""], // 삼성카드
        ["schema" : "uppay", "url" : ""], // 삼성카드
        ["schema" : "shinsegaeeasypayment", "url" : ""], // 삼성카드
        ["schema" : "paypin", "url" : ""], // 페이핀
        ["schema" : "storylink", "url" : "https://itunes.apple.com/us/app/kakaostory/id486244601?mt=8"], // 카카오스토리
        //        ["schema" : "kakaostory", "url" : "https://itunes.apple.com/us/app/kakaostory/id486244601?mt=8"], // 카카오스토리2 test
        ["schema" : "kakaotalk", "url" : "https://itunes.apple.com/kr/app/%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1-kakaotalk/id362057947?mt=8"], // 카카오톡
        ["schema" : "kakaolink", "url" : "https://itunes.apple.com/kr/app/%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1-kakaotalk/id362057947?mt=8"], // 카카오링크
        ["schema" : "kakaobizchat", "url" : "https://itunes.apple.com/kr/app/%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1-kakaotalk/id362057947?mt=8"], // 카카오비즈챗
        ["schema" : "kakaoplus", "url" : "https://itunes.apple.com/kr/app/%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1-kakaotalk/id362057947?mt=8"], // 카카오플러스
        ["schema" : "supertoss", "url" : "https://itunes.apple.com/kr/app/%ED%86%A0%EC%8A%A4/id839333328?mt=8"],  // 토스
    ]
    
    func createAccessCookie() {
        let access_cookie_dic : [HTTPCookiePropertyKey:Any] = [
            HTTPCookiePropertyKey.domain : WInfo.appUrl.globalUrl() as AnyObject,
            HTTPCookiePropertyKey.path : "/" as AnyObject,
            HTTPCookiePropertyKey.name : "wisamall_access_device" as AnyObject,
            HTTPCookiePropertyKey.value : "APP",
            HTTPCookiePropertyKey.expires : Date().addingTimeInterval(60*60*24*365*300)
        ];
        let cookie:HTTPCookie = HTTPCookie(properties: access_cookie_dic)!
        HTTPCookieStorage.shared.setCookie(cookie)
    }
    
    func handleWing(_ url:String? )->Bool {
        if url != nil && url!.hasSuffix("exec_file=member/logout.exe.php") {
            let userInfo = WInfo.userInfo
            if let member_id = userInfo["userId"] as? String{
                let resource = ApiFormApp().ap("mode","set_login_stat").ap("pack_name",AppProp.appId).ap("login_stat","N").ap("member_id",member_id)
                RSHttp(controller: nil, progress: false, showingPopup: false).req(resource) { (resource) -> (Void) in
                }
            }
            WInfo.clearSessionCookie()
            WInfo.userInfo = [String:AnyObject]()
            
            return true
        }
        // video tag
        if url!.hasSuffix(".mp4") {
            let playerController = AVPlayerViewController()
            
            playerController.player =  AVPlayer(url: URL(string: url!)!)
            
            self.controller.present(playerController, animated: true, completion: {
                playerController.player?.play();
            })
            return false
        }
        
        if url!.hasPrefix("https://kauth.kakao.com/oauth/authorize?") {
        }
        
        return true
    }
    func handleItunes(_ url:String?)->Bool{
        if url == nil {
            return true
        }
        if url!.hasPrefix("https://itunes.apple.com/kr/app/") {
            UIApplication.shared.openURL(URL(string:url!)!)
            return false
        }
        if url!.hasPrefix("https://itunes.apple.com/us/app/") {
            UIApplication.shared.openURL(URL(string:url!)!)
            return false
        }
        if url!.hasPrefix("https://appsto.re/kr/") {
            UIApplication.shared.openURL(URL(string:url!)!)
            return false
        }
        if url!.hasPrefix("https://appsto.re/us/") {
            UIApplication.shared.openURL(URL(string:url!)!)
            return false
        }
        if url!.hasPrefix("http://itunes.apple.com/us/app/") {
            UIApplication.shared.openURL(URL(string:url!)!)
            return false
        }
        if url!.hasPrefix("http://itunes.apple.com/kr/app/") {
            UIApplication.shared.openURL(URL(string:url!)!)
            return false
        }
        if url!.hasPrefix("itms-apps://") {
            UIApplication.shared.openURL(URL(string:url!)!)
            return false
        }
        return true
        
    }
    func handleApiEvent(_ url:String?)-> Bool{
        if url == nil {
            return true
        }
        if url!.hasPrefix("wisamagic://api") {
            let api_string = url!.replace("wisamagic://api?", withString: "")
            self.apiEvent(api_string.paramParse())
            return false
        }
        return true
    }
    func handleEvent(_ url:String?)-> Bool{
        if url == nil {
            return true
        }
        if url!.hasPrefix("wisamagic://event?json=") {
            let json = url!.replace("wisamagic://event?json=", withString: "")
            do{
                let json_decode = json.removingPercentEncoding
                let value = try
                    JSONSerialization.jsonObject(
                        with: json_decode!.data(using: String.Encoding.utf8)!
                        ,options: JSONSerialization.ReadingOptions()) as! [String:AnyObject]
                self.webDelegate?.hybridEvent(value)
            }catch{
            }
            return false
        }
        return true
    }
    
    func handleSchema(_ url:String?)->Bool{
        if url == nil {
            return true
        }
        for appSchema in paySchema {
            if url!.hasPrefix(appSchema["schema"]! as String) {
                if UIApplication.shared.canOpenURL(URL(string:url!)!) {
                    UIApplication.shared.openURL(URL(string:url!)!)
                }else{
                    if appSchema["url"] != "" {
                        UIApplication.shared.openURL(URL(string:appSchema["url"]! as String)!)
                    }
                }
                return false
            }
        }
        return true
    }
    func apiEvent(_ value: [String:String]){
        if value["func"] == "deviceId" {
            let callback = value["callback"]!.removingPercentEncoding!
            let value = WInfo.deviceId
            self.runScript("javascript:\(callback)('\(value)')")
        }else if value["func"] == "version" {
            let callback = value["callback"]!.removingPercentEncoding!
            let value = AppProp.appVersion
            self.runScript("javascript:\(callback)('\(value)')")
        }else if value["func"] == "os_version" {
            let callback = value["callback"]!.removingPercentEncoding!
            let value = UIDevice.current.systemVersion
            self.runScript("javascript:\(callback)('\(value)')")
        }else if value["func"] == "isGpsEnabled" {
            let callback = value["callback"]!.removingPercentEncoding!
            var value:String = "N"
            #if GPSENABLED
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied
                && CLLocationManager.locationServicesEnabled() {
                value = "Y"
            }
            #endif
            self.runScript("javascript:\(callback)('\(value)')")
        }else if value["func"] == "goGPSConfig" {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }else if value["func"] == "contact" {
            let callback = value["callback"]!.removingPercentEncoding!
            controllerCallback[CONTACT_CALLBACK] = callback
            let picker = ABPeoplePickerNavigationController()
            picker.peoplePickerDelegate = self
            self.controller.present(picker, animated: true, completion: {
            });
        }else if value["func"] == "shareUrl" {
            if value["params"] == nil {
                self.controller.view.makeToast("파라미터가 없습니다.")
                return
            }
            if let json = value["params"]?.jsonObject() {
                if json["url"] == nil {
                    return
                }
                let objectToShare = [ URL(string: json["url"] as! String)! ]
                let activity = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
                self.controller.present(activity, animated: true, completion: nil)
            }
        }
            //        else if value["func"] == "scanner" {
            //            let callback = value["callback"]!.removingPercentEncoding!
            //            controllerCallback[SCANNER_CALLBACK] = callback
            //            let scanner = WMScanner()
            //            scanner.readerDelegate = self
            //            self.controller.present(scanner, animated: true, completion: {
            //            });
            //        }
        else if value["func"] == "goSetting" {
            self.controller.performSegue(withIdentifier: "setting" ,  sender : self)
        }else if value["func"] == "goNotice" {
            self.controller.performSegue(withIdentifier: "noti" ,  sender : nil)
        }else if value["func"] == "browserUrl" {
            if let url = URL(string:value["params"]!.removingPercentEncoding! ) {
                UIApplication.shared.openURL(url)
            }
        }else if value["func"] == "marketingAgree" {
            RSHttp(controller:self.controller, showingPopup:false).req(
                ApiFormApp().ap("mode","get_push_agree_tot").ap("pack_name",AppProp.appId),
                successCb: { (resource) -> Void in
                    if let _callback = value["callback"] {
                        let callback = _callback.removingPercentEncoding!
                        let value = resource.body()["result"] as! String
                        self.runScript("javascript:\(callback)('\(value)')")
                    }
            },errorCb:{ (errorCode,resource) -> Void in}
            )
        }else if value["func"] == "marketingPopup" {
            if value["params"] == nil {
                self.controller.view.makeToast("파라미터가 없습니다.")
                return
            }
            if let json = value["params"]?.jsonObject() {
                if json["title"] == nil || json["content"] == nil {
                    return
                }
                let dialog = self.controller.createMarketingAlertV2(msg: json) { (yn) in
                    self.controller.setMarketingAgree(yn:yn,{})
                }
                self.controller.present(dialog, animated: false, completion: nil)
            }
        }
    }
    
    func popup(_ message:String){
        let alert = UIAlertController(title: "알림", message: message ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "확인" , style: UIAlertActionStyle.default, handler:nil))
        self.controller.present(alert,animated:true, completion: nil)
    }
    
    func popup(_ message:String,handler:@escaping ((UIAlertAction) -> Void)){
        let alert = UIAlertController(title: "알림", message: message ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "확인" , style: UIAlertActionStyle.default, handler:handler))
        self.controller.present(alert,animated:true, completion: nil)
    }
    
    func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        let contactNm = ABRecordCopyCompositeName(person).takeRetainedValue()
        let unmanagePhones = ABRecordCopyValue(person, kABPersonPhoneProperty)
        var returnPhone:String?
        if unmanagePhones != nil {
            let phones : ABMultiValue = unmanagePhones!.takeUnretainedValue() as ABMultiValue
            let allPhones = ABMultiValueCopyArrayOfAllValues(phones).takeRetainedValue() as NSArray
            for eachPhone in allPhones {
                if(returnPhone == nil || (eachPhone as AnyObject).hasPrefix("+821") || (eachPhone as AnyObject).hasPrefix("821") || (eachPhone as AnyObject).hasPrefix("01") || (eachPhone as AnyObject).hasPrefix("(01")){
                    returnPhone = eachPhone as? String
                }
            }
        }
        let returnObj = [ "name" : contactNm , "number" : returnPhone == nil ? "" : returnPhone! ] as [String : Any]
        self.callbackContact(returnObj)
    }
    
    
    //    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    //        if let scanResults = info[ZBarReaderControllerResults] as? ZBarSymbolSet {
    //            for symbol in scanResults {
    //                if let symbolFound = symbol as? ZBarSymbol {
    //                    let returnObj = [ "text" : symbolFound.data , "format" : symbolFound.typeName ] as [String : Any]
    //                    self.callbackZBar(returnObj)
    //                    self.controller.dismiss(animated: true, completion: nil)
    //                    break
    //
    //                }
    //
    //
    //            }
    //        }
    //    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.controller.dismiss(animated: true, completion: nil)
    }
    
    func runScript(_ script:String){}
    
    func callbackZBar(_ returnObj:[String:Any]){
        self.runScript("javascript:\(self.controllerCallback[self.SCANNER_CALLBACK]!)('\(toJSONString(returnObj))')")
        
    }
    func callbackContact(_ returnObj:[String:Any]){
        self.runScript("javascript:\(self.controllerCallback[self.CONTACT_CALLBACK]!)('\(toJSONString(returnObj))')")
    }
    
    func sharedUrl() {
        if let currentUrl = self.currentURL {
            let objectToShare = [currentUrl]
            let activity = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
            self.controller.present(activity, animated: true, completion: nil)
        }
    }
    
    
    var canGoForward:Bool{
        get{ return false }
    }
    var canGoBack:Bool{
        get{ return false }
    }
    var webView:UIView{
        get{ return UIView() }
    }
    var scrollView:UIScrollView{
        get{ return UIScrollView() }
    }
    func loadEngine(){}
    func loadRequest(_ request:URLRequest){}
    func goBack(){}
    func goForward(){}
    func reload(){}
    func clearHistory(){}
}


protocol WebControlDelegate {
    func webLoadedFinish(_ urlString:String?)
    func webLoadedCommit(_ urlString:String?)
    func hybridEvent(_ value: [String:AnyObject])
}

class WebEngineFactory{
    static func create(_ controller:BaseWebController) -> WebEngine {
        return EngineWK(controller)
    }
}
