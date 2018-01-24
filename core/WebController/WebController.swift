//
//  WebController.swift
//  wing
//
//  Created by WISA on 2018. 1. 8..
//  Copyright © 2018년 JooDaeho. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBook
import AddressBookUI
import ZBarSDK
import AVKit
import AVFoundation

class WebController : BaseController,ABPeoplePickerNavigationControllerDelegate,ZBarReaderDelegate {
    
    let CONTACT_CALLBACK = 40
    let SCANNER_CALLBACK = 50
    var controllerCallback:[Int:String] = [:]
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var statusOverlay: UIView!
    
    
    var webViewCanGoForward:Bool{
        get{
            return false
        }
    }
    var webViewCanGoBack:Bool{
        get{
            return false
        }
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
        ["schema" : "paypin", "url" : ""] // 페이핀
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
        if url == nil && url!.hasSuffix("exec_file=member/logout.exe.php") {
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

            self.present(playerController, animated: true, completion: {
                    playerController.player?.play();
            })
            return false
        }
        
        if url!.hasPrefix("https://kauth.kakao.com/oauth/authorize?") {
            
            print("kakao oauth pass")
            
        }
        
//        if url!.hasSuffix("/member/login.php") {
//            let deadlineTime = DispatchTime.now() + .milliseconds(500)
//            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
//
//            })
//        }
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
        if url!.hasPrefix("http://itunes.apple.com/us/app/") {
            UIApplication.shared.openURL(URL(string:url!)!)
            return false
        }
        if url!.hasPrefix("http://itunes.apple.com/kr/app/") {
            UIApplication.shared.openURL(URL(string:url!)!)
            return false
        }
        if url!.hasPrefix("itms-appss://") {
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
                hybridEvent(value)
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
                    UIApplication.shared.openURL(URL(string:appSchema["url"]! as String)!)
                }
                return false
            }
        }
        return true
    }
    func hybridEvent(_ value: [String:AnyObject]){
        
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
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied
                && CLLocationManager.locationServicesEnabled() {
                value = "Y"
            }
            self.runScript("javascript:\(callback)('\(value)')")
        }else if value["func"] == "goGPSConfig" {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }else if value["func"] == "contact" {
            let callback = value["callback"]!.removingPercentEncoding!
            controllerCallback[CONTACT_CALLBACK] = callback
            let picker = ABPeoplePickerNavigationController()
            picker.peoplePickerDelegate = self
            self.present(picker, animated: true, completion: {
            });
        }else if value["func"] == "shareUrl" {
            if value["params"] == nil {
                self.view.makeToast("파라미터가 없습니다.")
                return
            }
            if let json = value["params"]?.jsonObject() {
                if json["url"] == nil {
                    return
                }
                let objectToShare = [ URL(string: json["url"] as! String)! ]
                let activity = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
                present(activity, animated: true, completion: nil)
            }
        }else if value["func"] == "scanner" {
            let callback = value["callback"]!.removingPercentEncoding!
            controllerCallback[SCANNER_CALLBACK] = callback
            let scanner = WMScanner()
            scanner.readerDelegate = self
            self.present(scanner, animated: true, completion: {
            });
        }else if value["func"] == "goSetting" {
            self.performSegue(withIdentifier: "setting" ,  sender : self)
        }else if value["func"] == "goNotice" {
            self.performSegue(withIdentifier: "noti" ,  sender : nil)
        }else if value["func"] == "browserUrl" {
            if let url = URL(string:value["params"]!.removingPercentEncoding! ) {
                UIApplication.shared.openURL(url)
            }
        }else if value["func"] == "adbrixFirstTimeExperience" {
            if let json = value["params"]?.jsonObject() {
                EventAdbrix.firstTimeExperience(json)
            }
        }else if value["func"] == "adbrixRetention" {
            if let json = value["params"]?.jsonObject() {
                EventAdbrix.retention(json)
            }
        }else if value["func"] == "adbrixSetAge" {
            if let json = value["params"]?.jsonObject() {
                EventAdbrix.setAge(json)
            }
        }else if value["func"] == "adbrixSetGender" {
            if let json = value["params"]?.jsonObject() {
                EventAdbrix.setGender(json)
            }
        }else if value["func"] == "adbrixPurchase" {
            if let json = value["params"]?.jsonObject() {
                EventAdbrix.purchase(json)
            }
        }else if value["func"] == "adbrixSetCustomCohort" {
            if let json = value["params"]?.jsonObject() {
                EventAdbrix.setCustomCohort(json)
            }
        }
    }
    
    func popup(_ message:String){
        let alert = UIAlertController(title: "알림", message: message ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "확인" , style: UIAlertActionStyle.default, handler:nil))
        self.present(alert,animated:true, completion: nil)
    }
    
    func popup(_ message:String,handler:@escaping ((UIAlertAction) -> Void)){
        let alert = UIAlertController(title: "알림", message: message ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "확인" , style: UIAlertActionStyle.default, handler:handler))
        self.present(alert,animated:true, completion: nil)
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
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let scanResults = info[ZBarReaderControllerResults] as? ZBarSymbolSet {
            for symbol in scanResults {
                if let symbolFound = symbol as? ZBarSymbol {
                    let returnObj = [ "text" : symbolFound.data , "format" : symbolFound.typeName ] as [String : Any]
                    self.callbackZBar(returnObj)
                    self.dismiss(animated: true, completion: nil)
                    break
                    
                }
                
                
            }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func runScript(_ script:String){}
    
    func callbackZBar(_ returnObj:[String:Any]){
        self.runScript("javascript:\(self.controllerCallback[self.SCANNER_CALLBACK]!)('\(toJSONString(returnObj))')")

    }
    func callbackContact(_ returnObj:[String:Any]){
        self.runScript("javascript:\(self.controllerCallback[self.CONTACT_CALLBACK]!)('\(toJSONString(returnObj))')")
    }
    
    func webLoadedFinish(_ urlString:String?){
    }
    func webLoadedCommit(_ urlString:String?) {
    }
    func loadRequest(_ request:URLRequest){
    }

}