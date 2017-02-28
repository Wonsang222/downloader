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
        return UIScreen.mainScreen().bounds.width
    }
}
var SCREEN_HEIGHT:CGFloat{
    get{
        return UIScreen.mainScreen().bounds.height
    }
}
func CRectChangeWidth(rect:CGRect,width:CGFloat) -> CGRect{
    return CGRectMake(rect.origin.x, rect.origin.y, width, rect.size.height)
}

func CRectChangeHeight(rect:CGRect,height:CGFloat) -> CGRect{
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height)
}

func CRectChangeX(rect:CGRect,x:CGFloat) -> CGRect{
    return CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height)
}

func CRectChangeY(rect:CGRect,y:CGFloat) -> CGRect{
    return CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)
}
func toJSONString(dic:Dictionary<String,AnyObject>) -> String{
    do{
        let returnData = try NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions())
        return (NSString(data:returnData,encoding:NSUTF8StringEncoding) as! String).urlEncode()!
    }catch{
        return "{}"
    }

    
}
