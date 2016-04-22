//
//  ExtenstionUIImage.swift
//  magicapp
//
//  Created by 조상연 on 2016. 4. 7..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import Foundation

import UIKit

extension UIImage{
    
    
    func makeFillImage(parent:UIView,bgColor:UIColor) -> UIImage {
        
        
        UIGraphicsBeginImageContext(CGSizeMake(parent.frame.width*2, parent.frame.height*2))
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, bgColor.CGColor);
        
        CGContextFillRect(context,CGRectMake(0,0,parent.bounds.width*UIScreen.mainScreen().scale,parent.bounds.height*UIScreen.mainScreen().scale));
        self.drawInRect(CGRectMake(
            parent.frame.width - self.size.width/2.0,
            parent.frame.height - self.size.height/2.0,
            self.size.width,
            self.size.height))
        let returnVal = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return returnVal
        
    }
    
    
}