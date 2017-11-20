//
//  PermissionController.swift
//  wing
//
//  Created by WISA on 2017. 11. 14..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit

class PermissionController: BaseController{

    var callback:(()->Void)?
    @IBOutlet var gpsGuide:UILabel!
    @IBOutlet weak var top_content_view: UIView!
    @IBOutlet weak var bottom_content_view: UIView!
    @IBOutlet weak var location_view: UIView!
    @IBOutlet weak var title_app_name: UILabel!
    @IBOutlet weak var bottom_app_name: UILabel!
    @IBOutlet weak var bottom_authority_text: UILabel!
    @IBOutlet weak var authority_scroll_view: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize = UIScreen.main.bounds
        // 스크린 높이를 구한다
        // 탑 컨텐츠 + 바럼 컨텐츠 - 스크린 높이 = 미틀 컨텐츠 크기
       let middle_content_height = screenSize.height - (top_content_view.frame.height + bottom_content_view.frame.height)

        authority_scroll_view.frame = CGRect(
            x:authority_scroll_view.frame.origin.x,
            y:authority_scroll_view.frame.origin.y,
            width:authority_scroll_view.frame.width,
            height: middle_content_height
        )
        
        authority_scroll_view.contentSize = CGSize(width: authority_scroll_view.frame.width, height: 50*3+60 )
        
        title_app_name.text = AppProp.appName!+" 앱 이용을 위해 아래"
        bottom_app_name.text = "'필수접근 권한'은 "+AppProp.appName!+" 앱 실행을 위해 반드시 필요합니다."
        
        gpsGuide.sizeToFit()
        
        if(AppProp.gpsUseMessage != nil) {
            location_view.isHidden = false
            gpsGuide.text = AppProp.gpsUseMessage
            
        } else {
            location_view.isHidden = true
        }
        
    }
    
    @IBAction func confirm() {
        WInfo.confirmPermission = true
        hide()
    }
    
    func show(parent:UIViewController , callback: @escaping ()->Void){
        self.view.frame = parent.view.bounds
        parent.view.addSubview(self.view)
        self.view.alpha = 0
        self.view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIView.setAnimationCurve(UIViewAnimationCurve.easeIn)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }) { (finish) in
        }
        self.callback = callback
    }
    func hide(){
        UIView.setAnimationCurve(UIViewAnimationCurve.easeOut)
        UIView.animate(withDuration: 0.6, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            self.view.alpha = 0
        }) { (finish) in
            self.view.removeFromSuperview()
            self.callback?()
        }
    }
}
