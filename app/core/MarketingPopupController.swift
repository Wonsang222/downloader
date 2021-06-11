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
        progress?.isHidden = false
        webView?.scrollView.alwaysBounceHorizontal = false
        webView?.scrollView.alwaysBounceVertical = false
     
        webView?.loadRequest(URLRequest(url: URL(string: url!)!))
    }
    
    func autoKeyboardScroll() -> Bool {
        return false
    }
    
  
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        var frame = webView.frame
        frame.size.height = 1
        webView.sizeThatFits(CGSize.zero)
        let result = webView.stringByEvaluatingJavaScript(from: "document.body.offsetHeight;");
        let reslut_float = Float(result!)!
        heightChange(CGFloat(reslut_float))
        progress?.isHidden = true

    }
    
    func heightChange(_ height:CGFloat) {
        if let popup:RPopupController = self.parent as? RPopupController{
            popup.changeSize(height)
        }
    }
    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.url?.absoluteString
        if urlString!.contains("wisamagic://marketing") {
            let dic = urlString!.replace("wisamagic://marketing?", withString: "").paramParse()
            if let popupController = self.parent as? RPopupController {
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

