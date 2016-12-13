//
//  MarketingPopupController.swift
//  NAIN
//
//  Created by WISA on 2016. 11. 22..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class MarketingPopupController: UIViewController,RPopupControllerDelegate,UIWebViewDelegate {

    
    @IBOutlet var webView:UIWebView?
    @IBOutlet var progress:UIActivityIndicatorView?
    var url:String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        progress?.hidden = false
        webView?.scrollView.alwaysBounceHorizontal = false
        webView?.scrollView.alwaysBounceVertical = false
     
        webView?.loadRequest(NSURLRequest(URL: NSURL(string: url!)!))
    }
    
    func autoKeyboardScroll() -> Bool {
        return false
    }
    
  
    
    func webViewDidFinishLoad(webView: UIWebView) {
        var frame = webView.frame
        frame.size.height = 1
        webView.sizeThatFits(CGSizeZero)
        let result = webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight;");
        let reslut_float = Float(result!)!
        heightChange(CGFloat(reslut_float))
        progress?.hidden = true

    }
    
    func heightChange(height:CGFloat) {
        if let popup:RPopupController = self.parentViewController as? RPopupController{
            popup.changeSize(height)
        }
    }
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.URL?.absoluteString
        if urlString!.containsString("wisamagic://marketing") {
            let dic = urlString!.replace("wisamagic://marketing?", withString: "").paramParse()
            if let popupController = self.parentViewController as? RPopupController {
                if dic["click"]  == "yes" {
                    popupController.dismissPopup({
                        popupController.resp!("Y")
                    })
                    
                }else if dic["click"] == "no" {
                    popupController.dismissPopup({
                        popupController.resp!("N")
                    })
                    
                }
            }
            return false
        }
        return true
    }
}

