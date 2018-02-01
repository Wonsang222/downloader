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
    
    func webViewDidClose(_ webView: WKWebView) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scroll \(scrollView.contentOffset.y)")
        
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
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//
//    }
}
