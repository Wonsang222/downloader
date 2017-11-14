//
//  ExtenstionRect.swift
//  wing
//
//  Created by WISA on 2017. 11. 14..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit

extension CGRect{
    
    func changeY(_ y:CGFloat) -> CGRect{
        var returnVal = self
        returnVal.origin.y = y
        return returnVal
    }
    func changeX(_ x:CGFloat) -> CGRect{
        var returnVal = self
        returnVal.origin.x = x
        return returnVal
    }
    func changeWidth(_ width:CGFloat) -> CGRect{
        var returnVal = self
        returnVal.size.width = width
        return returnVal
    }
    func changeHeight(_ height:CGFloat) -> CGRect{
        var returnVal = self
        returnVal.size.height = height
        return returnVal
    }
    
    
}


