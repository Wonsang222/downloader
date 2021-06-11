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
    
    
    func makeFillImage(_ parent:UIView) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: parent.frame.width*2, height: parent.frame.height*2))
        let context = UIGraphicsGetCurrentContext();
        context!.setFillColor(UIColor.clear.cgColor);
        context!.fill(CGRect(x: 0,y: 0,width: parent.bounds.width*UIScreen.main.scale,height: parent.bounds.height*UIScreen.main.scale));
        self.draw(in: CGRect(
            x: parent.frame.width - self.size.width/2.0,
            y: parent.frame.height - self.size.height/2.0,
            width: self.size.width,
            height: self.size.height))
        let returnVal = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return returnVal!
    }
    
    func makeFillImageV2(_ parent:UIView) -> UIImage {
        let parentSizeScale = CGSize(width: parent.frame.width*UIScreen.main.scale, height: parent.frame.height*UIScreen.main.scale)
        let scale_factor:CGFloat = 3.0/UIScreen.main.scale
        UIGraphicsBeginImageContext(parentSizeScale)
        let context = UIGraphicsGetCurrentContext();
        context!.setFillColor(UIColor.clear.cgColor);
        context!.fill(CGRect(x: 0,y: 0,width: parent.bounds.width*UIScreen.main.scale,height: parent.bounds.height*UIScreen.main.scale));
        let resize_width = self.size.width/scale_factor
        let resize_height = self.size.height/scale_factor
        self.draw(in: CGRect(
            x: (parentSizeScale.width - resize_width)/2,
            y: (parentSizeScale.height - resize_height)/2,
            width: resize_width,
            height: resize_height))
        let returnVal = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return returnVal!
    }
    
    func tintWithColor(_ color:UIColor)->UIImage {
        
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.translateBy(x: 0.0, y: -self.size.height)
        
        // multiply blend mode
        context!.setBlendMode(.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context!.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context!.fill(rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
    
    
}
