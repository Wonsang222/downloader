//
//  WSettingController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class WSettingController: BaseController {

    @IBOutlet weak var curVersion: UILabel!
    @IBOutlet weak var newVersion: UILabel!
    @IBOutlet weak var orderSwitch: UISwitch!
    @IBOutlet weak var eventSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        curVersion.text = AppProp.appVersion
        RSHttp(controller:self).req(
                ApiFormApp().ap("mode","get_agree").ap("pack_name", AppProp.appId),
                ApiFormApp().ap("mode","version_chk").ap("pack_name", AppProp.appId)
            ,
            successCb: { (resource) -> Void in
                let mode = resource.params["mode"]!
                if mode == "version_chk" {
                    let version = resource.body()["version"] as! String
                    self.newVersion.text = version
                }else {
                    let json = resource.body()["result"] as! [String:AnyObject]
                    let order_push_agree = json["order_push_agree"] as! String
                    let notice_push_agree = json["notice_push_agree"] as! String
                    
                    self.orderSwitch.setOn(order_push_agree == "Y" ? true : false, animated: false)
                    self.eventSwitch.setOn(notice_push_agree == "Y" ? true : false, animated: false)
                }
            }
        )
        
        self.orderSwitch.addTarget(self, action:#selector(WSettingController.switchChange(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        self.eventSwitch.addTarget(self, action:#selector(WSettingController.switchChange(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
    }

    
    func switchChange(sender:UISwitch){
        let event = eventSwitch.on ? "Y" : "N"
        let order = orderSwitch.on ? "Y" : "N"
        
        RSHttp(controller:self).req(
            ApiFormApp().ap("mode","set_agree")
                .ap("pack_name", AppProp.appId)
                .ap("notice_push_agree", event)
                .ap("order_push_agree", order)
            ,
            successCb: { (resource) -> Void in
               
            }
        )
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}

