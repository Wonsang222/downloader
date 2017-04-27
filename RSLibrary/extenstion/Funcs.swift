//
//  Funcs.swift
//  cloudadfp
//
//  Created by WISA on 2016. 9. 21..
//  Copyright © 2016년 WISA. All rights reserved.
//

import UIKit


var SCREEN_WIDTH:CGFloat{
    get{
        return UIScreen.main.bounds.width
    }
}
var SCREEN_HEIGHT:CGFloat{
    get{
        return UIScreen.main.bounds.height
    }
}
func CRectChangeWidth(_ rect:CGRect,width:CGFloat) -> CGRect{
    return CGRect(x: rect.origin.x, y: rect.origin.y, width: width, height: rect.size.height)
}

func CRectChangeHeight(_ rect:CGRect,height:CGFloat) -> CGRect{
    return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: height)
}

func CRectChangeX(_ rect:CGRect,x:CGFloat) -> CGRect{
    return CGRect(x: x, y: rect.origin.y, width: rect.size.width, height: rect.size.height)
}

func CRectChangeY(_ rect:CGRect,y:CGFloat) -> CGRect{
    return CGRect(x: rect.origin.x, y: y, width: rect.size.width, height: rect.size.height)
}
func toJSONString(_ dic:[String:Any]) -> String{
    do{
        let returnData = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions())
        return (NSString(data:returnData,encoding:String.Encoding.utf8.rawValue) as! String).urlEncode()!
    }catch{
        return "{}"
    }

    
}
