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
    
    
    func makeFillImage(parent:UIView) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(parent.frame.width*2, parent.frame.height*2))
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context!, UIColor.clearColor().CGColor);
        CGContextFillRect(context!,CGRectMake(0,0,parent.bounds.width*UIScreen.mainScreen().scale,parent.bounds.height*UIScreen.mainScreen().scale));
        self.drawInRect(CGRectMake(
            parent.frame.width - self.size.width/2.0,
            parent.frame.height - self.size.height/2.0,
            self.size.width,
            self.size.height))
        let returnVal = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return returnVal!
    }
    
    func makeFillImageV2(parent:UIView) -> UIImage {
        let scale_factor:CGFloat = 3.0/UIScreen.mainScreen().scale
        UIGraphicsBeginImageContext(CGSizeMake(parent.frame.width*UIScreen.mainScreen().scale, parent.frame.height*UIScreen.mainScreen().scale))
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context!, UIColor.clearColor().CGColor);
        CGContextFillRect(context!,CGRectMake(0,0,parent.bounds.width*UIScreen.mainScreen().scale,parent.bounds.height*UIScreen.mainScreen().scale));
        let resize_width = self.size.width/scale_factor
        let resize_height = self.size.height/scale_factor
        
        self.drawInRect(CGRectMake(
            parent.frame.width - resize_width/2.0,
            parent.frame.height - resize_height/2.0,
            resize_width,
            resize_height))
        let returnVal = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return returnVal!
    }
    
    func tintWithColor(color:UIColor)->UIImage {
        
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        CGContextScaleCTM(context!, 1.0, -1.0)
        CGContextTranslateCTM(context!, 0.0, -self.size.height)
        
        // multiply blend mode
        CGContextSetBlendMode(context!, .Multiply)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        CGContextClipToMask(context!, rect, self.CGImage!)
        color.setFill()
        CGContextFillRect(context!, rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
    
    
}
