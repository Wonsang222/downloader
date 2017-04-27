//
//  CommonMkTheme.swift
//  magicapp
//
//  Created by WISA on 2017. 2. 28..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit


class CommonMkTheme {
    
    var viewController:UIViewController
    var uiData:[String:Any]
    
    
    init(controller:UIViewController, object:[String:Any]){
        self.uiData = object["ui_data"] as! [String:Any]
        self.viewController = controller
    }
    
    
    func applayMain(){
        
    }
    func applyNavi(){
        
    }
    func preferredStatusBarStyle() -> UIStatusBarStyle{
        return .default
    }
    
    
    func applyAction(_ button:UIButton,key:String){
        if key == "prev"{
            button.addTarget(self.viewController , action: #selector(WMainController.onPrevClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "next"{
            button.addTarget(self.viewController , action: #selector(WMainController.onNextClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "reload"{
            button.addTarget(self.viewController , action: #selector(WMainController.onReloadClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "home"{
            button.addTarget(self.viewController , action: #selector(WMainController.onHomeClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "share"{
            button.addTarget(self.viewController , action: #selector(WMainController.onShareClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "push"{
            button.addTarget(self.viewController , action: #selector(WMainController.onPushClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "tab"{
        }else if key == "setting"{
            button.addTarget(self.viewController , action: #selector(WMainController.onSettingClick(_:)) , for: UIControlEvents.touchUpInside)
            
        }
    }

}
