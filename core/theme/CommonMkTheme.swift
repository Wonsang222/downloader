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
    var uiData:[String:AnyObject]
    
    
    init(controller:UIViewController, object:[String:AnyObject]){
        self.uiData = object["ui_data"] as! [String:AnyObject]
        self.viewController = controller
    }
    
    
    func applayMain(){
        
    }
    func applyNavi(){
        
    }
    func preferredStatusBarStyle() -> UIStatusBarStyle{
        return .Default
    }
    
    
    func applyAction(button:UIButton,key:String){
        if key == "prev"{
            button.addTarget(self.viewController , action: #selector(WMainController.onPrevClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "next"{
            button.addTarget(self.viewController , action: #selector(WMainController.onNextClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "reload"{
            button.addTarget(self.viewController , action: #selector(WMainController.onReloadClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "home"{
            button.addTarget(self.viewController , action: #selector(WMainController.onHomeClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "share"{
            button.addTarget(self.viewController , action: #selector(WMainController.onShareClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "push"{
            button.addTarget(self.viewController , action: #selector(WMainController.onPushClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "tab"{
        }else if key == "setting"{
            button.addTarget(self.viewController , action: #selector(WMainController.onSettingClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
            
        }
    }

}
