//
//  MGWKSubWebController.swift
//  wing
//
//  Created by 이동철 on 2018. 1. 11..
//  Copyright © 2018년 JooDaeho. All rights reserved.
//
import WebKit
import UIKit

class MGWKSubWebController: BaseController, WKUIDelegate,WKNavigationDelegate, UIScrollViewDelegate  {
    
    var startUrl:String?
    var controllToggle: Bool = true
    var scrollBefore: CGFloat = 0.0
    var scrollDistance: CGFloat = 0.0
    
    var webViewSubContainer: UIView!
    var webView: WKWebView!
    
    // top navi
    var topNavigationView: UIView!
    // title label
    var webTitle: UILabel!
    // title url
    var webUrl: UILabel!
    // bottom navi
    @IBOutlet var bottomNavigationView: UIView?
    // pre btn
    @IBOutlet var preButton: UIButton?
    // next btn
    @IBOutlet var nextButton: UIButton?
    
    @IBOutlet var shareButton: UIButton?
    
    var statusBarSize:CGFloat{
        get{
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    
    var bottomNavibarHeight: CGFloat {
        get {
            return 40 + Tools.safeArea()
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        webView.goBack();
    }
    
    @IBAction func goNext(_ sender: Any) {
        webView.goForward()
    }
    
    @IBAction func shareContent(_ sender: Any) {
        if let currentUrl = webView.url {
            let objectToShare = [currentUrl]
            let activity = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
            self.present(activity, animated: true, completion: nil)
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
        
        ["schema" : "cloudpay", "url" : "itms://itunes.apple.com/app/id847268987"], //외환카드 , 하나카드
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
        ["schema" : "kakaotalk", "url" : "https://itunes.apple.com/kr/app/%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1-kakaotalk/id362057947?mt=8"], // 카카오톡
        ["schema" : "kakaolink", "url" : "https://itunes.apple.com/kr/app/%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1-kakaotalk/id362057947?mt=8"], // 카카오링크
        ["schema" : "kakaobizchat", "url" : "https://itunes.apple.com/kr/app/%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1-kakaotalk/id362057947?mt=8"], // 카카오비즈챗
        ["schema" : "supertoss", "url" : "https://itunes.apple.com/kr/app/%ED%86%A0%EC%8A%A4/id839333328?mt=8"], // 토스
    ]
    
    func loadedView(url: URLRequest, config: WKWebViewConfiguration) -> WKWebView {
        
        Bundle.main.loadNibNamed("InAppNavi", owner: self, options: nil)

        webViewSubContainer = UIView()
        topNavigationView = UIView()
        webTitle = UILabel()
        webUrl = UILabel()
        
        let dismissBtn = UIButton()
        
        webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        if #available(iOS 9.0, *) {
            //            webView.allowsLinkPreview = true
        }
        self.view.bounds = UIScreen.main.bounds
        webViewSubContainer.bounds = self.view.bounds
        self.view.addSubview(webViewSubContainer)
        
        webViewSubContainer.center = self.view.center
        
        topNavigationView.frame = CGRect(x: 0.0, y:0, width: webViewSubContainer.bounds.width, height: 50 + statusBarSize)
        topNavigationView.backgroundColor = UIColor.white
        topNavigationView.addSubview(dismissBtn)
        dismissBtn.frame = CGRect(x: 0, y: statusBarSize, width: 50.0, height: 50.0)
        dismissBtn.setImage(UIImage(named: "ic_navi_back.png"), for: .normal)
        dismissBtn.onClick { (view) in
            self.dismiss(animated: true, completion: nil)
            self.webView.evaluateJavaScript("window.close()", completionHandler: nil)
        }
        webTitle.frame = CGRect(x: 50, y: 11+statusBarSize, width: topNavigationView.bounds.width, height: 15.0)
        webUrl.frame = CGRect(x: 50, y: 11+statusBarSize+15, width: topNavigationView.bounds.width, height: 13.0)
        webTitle.font = webTitle.font.withSize(14.0)
        webUrl.font = webUrl.font.withSize(11.0)
        webTitle.textColor = UIColor(hexString: "#333333")
        webUrl.textColor = UIColor(hexString: "#9494949")
        webTitle.textAlignment = .left
        webUrl.textAlignment = .left

        webTitle.text = "읽어들이는중"
        webUrl.isHidden = true
        webTitle.frame = CGRect(x: 50, y: 10+statusBarSize, width: topNavigationView.bounds.width, height: 29.0)
        topNavigationView.backgroundColor = UIColor(hexString: "#f7f7f7")
        topNavigationView.addSubview(webTitle)
        topNavigationView.addSubview(webUrl)
        topNavigationView.addSubview(Tools.border1px(parent: topNavigationView, color: "#b9b9b9"))

        bottomNavigationView?.rsWidth = webViewSubContainer.frame.width
        bottomNavigationView?.rsY = webViewSubContainer.frame.height - 40
        if #available(iOS 11.0, *) {
            print("safeAreaInsets \(Tools.safeArea())")

            bottomNavigationView?.rsHeight = (bottomNavigationView?.frame.height)! + Tools.safeArea()
            bottomNavigationView?.rsY = webViewSubContainer.frame.height - (40 + Tools.safeArea())
        }
        
        webView.scrollView.contentInset = UIEdgeInsetsMake(topNavigationView.bounds.height - statusBarSize, 0.0, 0.0, 0.0)

//        webView.backgroundColor = UIColor.black
        webView.frame.origin = CGPoint(x: 0.0, y: 0.0)
        webView.frame = webViewSubContainer.bounds
        print("height : \(webViewSubContainer.bounds) \(self.view.bounds)")
        // wkwebview 에서는 기본적으로 오프셋이 잡히는경우가 있다.
        webView.scrollView.contentInset = UIEdgeInsetsMake(50, 0, 40, 0)
        
        webView.load(url)
        
        // 웹뷰는 컨테이너가 아니다. 안에 뷰를 넣지말자
        webViewSubContainer?.addSubview(webView)
        webViewSubContainer?.addSubview(topNavigationView)
        webViewSubContainer?.addSubview(bottomNavigationView!)
        return webView
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlString = navigationAction.request.url?.absoluteString {
            if urlString.hasPrefix("tel:") || urlString.hasPrefix("mailto:") {
                UIApplication.shared.openURL(navigationAction.request.url!)
                decisionHandler(.cancel)
            } else if !self.handleSchema(urlString) {
                decisionHandler(.cancel)
            } else if !self.handleItunes(urlString) {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
                return ;
            }
            
        } else {
            decisionHandler(.allow)
            return ;
        }
        
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
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webTitle.frame = CGRect(x: 50, y: 11+statusBarSize, width: topNavigationView.bounds.width, height: 29.0)
        webTitle.text = "읽어들이는중"
        webUrl.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webTitle.frame = CGRect(x: 50, y: 11+statusBarSize, width: topNavigationView.bounds.width, height: 15.0)
        if webView.title == "" {
            webTitle.text = webView.url?.host
        }else{
            webTitle.text = webView.title
        }
        webUrl.text = webView.url?.host
        webUrl.isHidden = false
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("inapp didcommit")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("inapp didfail : : \(error)")
    }
    func webViewDidClose(_ webView: WKWebView) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let moveY = scrollView.contentOffset.y < -self.topNavigationView!.frame.height ? -self.topNavigationView!.frame.height : scrollView.contentOffset.y
        let dy = moveY - self.scrollBefore
        self.scrollBefore = moveY
        if self.scrollDistance > 20 && controllToggle {
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.topNavigationView.rsY = -self.topNavigationView.frame.height
                self.bottomNavigationView?.rsY = +self.webViewSubContainer.frame.height + Tools.safeArea()
            })
            self.controllToggle = false
            self.scrollDistance = 0
        } else if self.scrollDistance < -20 && !controllToggle {
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.topNavigationView.rsY = 0
                self.bottomNavigationView?.rsY = self.webViewSubContainer.frame.height - self.bottomNavibarHeight
            })
            self.controllToggle = true
            self.scrollDistance = 0
        }
        
        if controllToggle && dy>0  || (!controllToggle && dy<0) {
            self.scrollDistance += dy
        }
    }
}
