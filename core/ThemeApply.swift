//
//  WInfo.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class ThemeApply{

	static func applyAction(controller:UIController,button:UIButton,key:String){
		if key == "prev"{

		}else if key == "next"{

		}else if key == "reload"{

		}else if key == "home"{

		}else if key == "share"{

		}else if key == "push"{
			controller.performSegueWithIdentifier("noti" ,  sender : controller)
		}else if key == "tab"{

		}else if key == "setting"{
			controller.performSegueWithIdentifier("setting" ,  sender : controller)
		}
	}

}
