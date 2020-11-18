//
//  BaseController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class BaseController: UIViewController {
    @IBOutlet weak var topView: UIView?
    @IBOutlet var topTitle:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
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
    
    func createWarningAlert(_ confirm:@escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: "알림", message: "탈옥기기로 이 앱을 사용할 수 없습니다.\n앱을 종료합니다." ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "확인" , style: UIAlertActionStyle.default, handler:confirm))
        return alert
    }
    
    func createMarketingAlertV2(msg:[String:AnyObject], resp:@escaping ((String) -> Void)) -> RPopupController {
        let popupView = self.storyboard!.instantiateViewController(withIdentifier: "popup") as! SimplePopupController
        let popup = SimpleRPopupController(controlller: popupView)
        
        let title = msg["marketing_title"] as? String
        let content = msg["marketing_msg"] as? String
        
        popupView.pTitle.text = (title != nil) ? title : msg["title"] as? String
        popupView.pMessage.text = (content != nil) ? content : msg["content"] as? String
        popupView.confirmBtn.setTitle("동의", for: .normal)
        popupView.cancelBtn.setTitle("미동의", for: .normal)
        popupView.callback = resp
        popup.cancelable = false
        popup.delegate = self
        return popup
    }
    
    func getMarketingAlert(val: String, _ confirm:@escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let agree = val == "Y" ? "허용":"해제"
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.string(from: now)
        
        let alert = UIAlertController(title:"안내", message:"마케팅 푸시알림이 \(agree) 처리되었습니다.\n \(WInfo.appName) (\(dateFormatter.string(from: now)))" ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "확인" , style: UIAlertActionStyle.default, handler:confirm))
        present(alert,animated: false, completion: nil)
        
        return alert
    }
    
    
    func setMarketingAgree(yn:String,_ next:@escaping () -> Void){
        RSHttp(controller:self, showingPopup:false).req(
            [ApiFormApp().ap("mode","set_push_agree_tot").ap("pack_name",AppProp.appId).ap("marketing_agree",yn)],
            successCb: { (resource) -> Void in
                WInfo.firstProcess = false
                self.getMarketingAlert(val: yn,{(action) in
                    next()
                })
        },errorCb:{ (errorCode,resource) -> Void in
        }
        )
    }
    
    // [2]
    func createMarketingAlertRe(msg:[String:AnyObject], resp:@escaping ((String) -> Void)) -> RPopupController { // [1]
        let popupView = self.storyboard!.instantiateViewController(withIdentifier: "popup") as! SimplePopupController
        let popup = SimpleRPopupController(controlller: popupView)
        popupView.pTitle.text = msg["marketing_title_re"] as? String
        popupView.pMessage.text = msg["marketing_msg_re"] as? String
        popupView.confirmBtn.setTitle("동의", for: .normal)
        popupView.cancelBtn.setTitle("미동의", for: .normal)
        popupView.callback = resp
        popup.cancelable = false
        popup.delegate = self
        return popup
    }
}



class BaseWebController: BaseController {
    
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var statusOverlay: UIView!
    private var _engine:WebEngine?
    
    var engine:WebEngine {
        get{
            return _engine!
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        _engine = WebEngineFactory.create(self)
        _engine?.loadEngine()
    }
    
}


