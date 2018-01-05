//
//  BaseController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation
import AddressBook
import AddressBookUI
import ZBarSDK



class BaseController: UIViewController {

	@IBOutlet weak var topView: UIView?
    @IBOutlet var topTitle:UILabel?

    let CONTACT_CALLBACK = 40
    let SCANNER_CALLBACK = 50
    
    var controllerCallback:[Int:String] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tracker = (UIApplication.shared.delegate as! WAppDelegate).tracker {
            if let title = self.title {
                if !title.isEmpty{
                    tracker.set(kGAIScreenName, value: self.title!)
                    let builder = GAIDictionaryBuilder.createScreenView()
                    tracker.send(builder!.build() as [NSObject:AnyObject])
                }
            }
        }
        if let title = self.title {
            if !title.isEmpty{
                WisaTracker().page(self.title!)
            }
        }
        
        
    }
    
    
    @IBAction func doBack(_ sender:AnyObject){
        if self.navigationController != nil {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    
    func createMarketingDialog(_ url:String ,resp:@escaping ((String) -> Void)) -> RPopupController {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "push_agree_popup") as! MarketingPopupController
        controller.url = url
        let bizPoup = RPopupController(controlller: controller,height: 0)
        bizPoup.cancelable = false
        bizPoup.resp = resp
        return bizPoup
    }
    
    
    func createMarketingAlert(_ agree:@escaping ((UIAlertAction) -> Void),disagree:@escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: "알림", message: "해당기기로 이벤트, 상품할인 등의 정보를\n전송하려고 합니다." ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "동의" , style: UIAlertActionStyle.default, handler:agree))
        alert.addAction(UIAlertAction(title: "미동의" , style: UIAlertActionStyle.default, handler:disagree))
        return alert
    }
    func createMarketingAlertV2(resp:@escaping ((String) -> Void)) -> RPopupController {
        let popupView = self.storyboard!.instantiateViewController(withIdentifier: "popup") as! SimplePopupController
        let popup = SimpleRPopupController(controlller: popupView)
        popupView.pTitle.text = "알림"
        popupView.pMessage.text = "해당기기로 이벤트, 상품할인 등의 정보를\n전송하려고 합니다."
        popupView.confirmBtn.setTitle("동의", for: .normal)
        popupView.cancelBtn.setTitle("미동의", for: .normal)
        popupView.callback = resp
        popup.cancelable = false
        popup.delegate = self
        return popup
    }
    
    
   
    
    
}

class BaseWebViewController: BaseController,UIWebViewDelegate,ABPeoplePickerNavigationControllerDelegate,ZBarReaderDelegate {
    
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var statusOverlay: UIView?
    var webView:UIWebView!

    
    let paySchema = [
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

    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = UIWebView(frame: webViewContainer.bounds)
        webView.allowsInlineMediaPlayback = true
        
        if #available(iOS 9, *) {
            webView.allowsLinkPreview = false
            webView.allowsPictureInPictureMediaPlayback = true
        }
        webView.keyboardDisplayRequiresUserAction = false
        webView.delegate = self
        webView.autoresizingMask = [UIViewAutoresizing.flexibleHeight,UIViewAutoresizing.flexibleWidth]
        webView.scalesPageToFit = true
        webView.scrollView.delaysContentTouches = true
        webViewContainer.addSubview(webView)
    }
    
    func reloadPage(){
        self.webView.reload()
        
    }
    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        var backgroundSupported = false
        let device = UIDevice.current
        if device.responds(to: #selector(getter: UIDevice.isMultitaskingSupported)){
            backgroundSupported = device.isMultitaskingSupported;
        }
        if !backgroundSupported {
            popup("멀티테스킹을 지원하는 기기 또한 어플만 공인인증서비스가 가능합니다.")
            return true
        }
//        if request.URL!.absoluteString == "about:blank" {
//            UIWebView(frame: CGRectZero).loadRequest(request)
//            return false
//        }

        
        if request.url!.absoluteString.hasPrefix("wisamagic://event?json=") {
            let json = request.url?.absoluteString.replace("wisamagic://event?json=", withString: "")
            do{
                let json_decode = json!.removingPercentEncoding
                let value = try
                            JSONSerialization.jsonObject(
                            with: json_decode!.data(using: String.Encoding.utf8)!
                            ,options: JSONSerialization.ReadingOptions()) as! [String:AnyObject]
                hybridEvent(value)
            }catch{
                
            }
            return false
        }
        if request.url!.absoluteString.hasPrefix("wisamagic://api") {
            let api_string = request.url!.absoluteString.replace("wisamagic://api?", withString: "")
            self.baseHybridEvent(api_string.paramParse())
            return false
        }
        let returval = interceptWebView(request.url!)
        return returval
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        if webView.request == nil {
            return;
        }
        print("start " + webView.request!.url!.absoluteString)
        if !(self is NotiController) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let access_cookie_dic : [HTTPCookiePropertyKey:Any] = [
            HTTPCookiePropertyKey.domain : WInfo.appUrl.globalUrl() as AnyObject,
            HTTPCookiePropertyKey.path : "/" as AnyObject,
            HTTPCookiePropertyKey.name : "wisamall_access_device" as AnyObject,
            HTTPCookiePropertyKey.value : "APP",
            HTTPCookiePropertyKey.expires : Date().addingTimeInterval(60*60*24*365*300)
        ];
        let cookie:HTTPCookie = HTTPCookie(properties: access_cookie_dic)!
        HTTPCookieStorage.shared.setCookie(cookie)
//        progressView.setProgress(0, animated: false)
//        progressView.setProgress(0.8, animated: true)
//        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: { self.progressView.alpha = 1 }, completion: nil)
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if webView.request!.url!.absoluteString.hasSuffix("smpay.kcp.co.kr/card.do") {
            webView.stringByEvaluatingJavaScript(from: "document.getElementById('layer_mpi').contentWindow.open = function(url,frame,feature) { }")
        }
        
//        progressView.setProgress(1, animated: true)
//        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: { self.progressView.alpha = 0 }, completion: nil)

    }
    
    
    func hybridEvent(_ value: [String:AnyObject]){
        
    }
    
    func baseHybridEvent(_ value: [String:String]){
        if value["func"] == "deviceId" {
            let callback = value["callback"]!.removingPercentEncoding!
            let value = UIDevice.current.identifierForVendor!.uuidString
            webView.stringByEvaluatingJavaScript(from: "javascript:\(callback)('\(value)')")
        }else if value["func"] == "version" {
            let callback = value["callback"]!.removingPercentEncoding!
            let value = AppProp.appVersion
            webView.stringByEvaluatingJavaScript(from: "javascript:\(callback)('\(value)')")
        }else if value["func"] == "os_version" {
            let callback = value["callback"]!.removingPercentEncoding!
            let value = UIDevice.current.systemVersion
            webView.stringByEvaluatingJavaScript(from: "javascript:\(callback)('\(value)')")
        }else if value["func"] == "isGpsEnabled" {
            let callback = value["callback"]!.removingPercentEncoding!
            var value:String = "N"
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied
                && CLLocationManager.locationServicesEnabled() {
                value = "Y"
            }
            webView.stringByEvaluatingJavaScript(from: "javascript:\(callback)('\(value)')")
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
            let json = toJsonString(value["params"])
            if json["url"] == nil {
                return
            }
            let objectToShare = [ URL(string: json["url"] as! String)! ]
            let activity = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
            present(activity, animated: true, completion: nil)
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
        }else if value["func"] == "adbrixFirstTimeExperience" {
            let json = toJsonString(value["params"])
            EventAdbrix.firstTimeExperience(json)
        }else if value["func"] == "adbrixRetention" {
            let json = toJsonString(value["params"])
            EventAdbrix.retention(json)
        }else if value["func"] == "adbrixSetAge" {
            let json = toJsonString(value["params"])
            EventAdbrix.setAge(json)
        }else if value["func"] == "adbrixSetGender" {
            let json = toJsonString(value["params"])
            EventAdbrix.setGender(json)
        }else if value["func"] == "adbrixPurchase" {
            let json = toJsonString(value["params"])
            EventAdbrix.purchase(json)
        }else if value["func"] == "adbrixSetCustomCohort" {
            let json = toJsonString(value["params"])
            EventAdbrix.setCustomCohort(json)
        }
    }
    
    func toJsonString(_ json_decode:String?) -> [String:AnyObject]{
        do{
            let value = try
                JSONSerialization.jsonObject(
                    with: json_decode!.removingPercentEncoding!.data(using: String.Encoding.utf8)!
                    ,options: JSONSerialization.ReadingOptions()) as! [String:AnyObject]
            return value
        }catch{
            print(error)
            return [String:AnyObject]()
        }

    }
    
/*
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.request.URL != nil {
            if !navigationAction.request.URL!.absoluteString.isEmpty {
                
                if navigationAction.request.URL!.absoluteString.hasPrefix("https://smpay.kcp.co.kr") {
                    return nil
                }else{
//                    let subWebView = WKWebView(frame: self.webView.frame, configuration: configuration)
//                    subWebView.loadRequest(navigationAction.request)
                    UIApplication.sharedApplication().openURL(navigationAction.request.URL!)
//                    self.webViewContainer.addSubview(subWebView)
//                    return subWebView
                }
                
            }
        }
        return nil;
    }
    
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        progressView.setProgress(Float(webView.estimatedProgress), animated: true)
//        let javascript = "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
//        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        print("error \(error)")
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        progressView.setProgress(1, animated: true)
        UIView.animateWithDuration(0.3, delay: 1, options: .CurveEaseInOut, animations: { self.progressView.alpha = 0 }, completion: nil)
    }
    
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        let alertController = UIAlertController(title: "알림", message: message,
                                                preferredStyle: UIAlertControllerStyle.Alert);
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) {
            _ in completionHandler()}
        );
        
        self.presentViewController(alertController, animated: true, completion: {});
    }
    
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        
        let alertController = UIAlertController(title: "확인", message: message,
                                                preferredStyle: UIAlertControllerStyle.Alert);
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            _ in completionHandler(true)}
        );
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            _ in completionHandler(false)}
        );
        
        self.presentViewController(alertController, animated: true, completion: {});
        
    }
    
   
    /*
     Smshinhanansimclick      // 스마트 신한 URL 스키마
     shinhan-sr-ansimclick     // 신마트 신한앱 URL 스키마
     smhyundaiansimclick      // 현대카드 URL 스키마
     nonghyupcardansimclick   // NH 안심클릭 URL 스키마
     paypin                    // PAYPIN URL 스키마
     ispmobile                 // ISPMOBILE URL 스키마
     */
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler:
        (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.URL!.absoluteString.hasPrefix("tel:") || navigationAction.request.URL!.absoluteString.hasPrefix("mailto:"){
            UIApplication.sharedApplication().openURL(navigationAction.request.URL!)
            decisionHandler(.Cancel)
            return
        }
        decisionHandler(.Allow)
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
    }
    
 */
    
    
     
    func interceptWebView(_ url:URL) -> Bool {
        if url.absoluteString.hasSuffix("exec_file=member/logout.exe.php") {
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
        let device = UIDevice.current
        if !device.isMultitaskingSupported {
            popup("멀티테스킹을 지원하는 기기 또는 어플만  공인인증서비스가 가능합니다.")
            return false;
        }

        if url.absoluteString.hasPrefix("smartxpay-transfer://"){
            if UIApplication.shared.canOpenURL(URL(string:"smartxpay-transfer://")!) {
                UIApplication.shared.openURL(url)
            }else{
                popup("확인버튼을 누르시면 스토어로 이동합니다.",handler: { action in
                    let itunes = "https://itunes.apple.com/kr/app/seumateu-egseupei-gyejwaiche/id393794374?mt=8"
                    UIApplication.shared.openURL(URL(string:itunes)!)
                })
            }
            return false
        }
        if url.absoluteString.hasPrefix("paypin://MP_2APP"){
            if UIApplication.shared.canOpenURL(URL(string:"paypin://MP_2APP")!) {
                UIApplication.shared.openURL(url)
            }else{
                popup("확인버튼을 누르시면 스토어로 이동합니다.")
            }
            return false
        }
        if url.absoluteString.hasPrefix("smartxpay-transfer://"){
            if UIApplication.shared.canOpenURL(URL(string:"smartxpay-transfer://")!) {
                UIApplication.shared.openURL(url)
            }else{
                popup("확인버튼을 누르시면 스토어로 이동합니다.")
            }
            return false
        }
        
        
        
        if url.absoluteString.hasPrefix("https://itunes.apple.com/kr/app/") {
            UIApplication.shared.openURL(url)
            return false
        }
        if url.absoluteString.hasPrefix("https://itunes.apple.com/us/app/") {
            UIApplication.shared.openURL(url)
            return false
        }
        if url.absoluteString.hasPrefix("http://itunes.apple.com/us/app/") {
            UIApplication.shared.openURL(url)
            return false
        }
        if url.absoluteString.hasPrefix("http://itunes.apple.com/kr/app/") {
            UIApplication.shared.openURL(url)
            return false
        }
        if url.absoluteString.hasPrefix("itms-appss://") {
            UIApplication.shared.openURL(url)
            return false
        }
        
        for appSchema in paySchema {
            if url.absoluteString.hasPrefix(appSchema["schema"]! as String) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }else{
                    UIApplication.shared.openURL(URL(string:appSchema["url"]! as String)!)
                }
                return false
            }
        }
        return true
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
        self.webView.stringByEvaluatingJavaScript(from: "javascript:\(self.controllerCallback[self.CONTACT_CALLBACK]!)('\(toJSONString(returnObj))')")
        
    }
    
    

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print( )
        if let scanResults = info[ZBarReaderControllerResults] as? ZBarSymbolSet {
            for symbol in scanResults {
                if let symbolFound = symbol as? ZBarSymbol {
                    let returnObj = [ "text" : symbolFound.data , "format" : symbolFound.typeName ] as [String : Any]
                    self.webView.stringByEvaluatingJavaScript(from: "javascript:\(self.controllerCallback[self.SCANNER_CALLBACK]!)('\(toJSONString(returnObj))')")
                    self.dismiss(animated: true, completion: nil)
                    break
                    
                }
            
            
            }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

