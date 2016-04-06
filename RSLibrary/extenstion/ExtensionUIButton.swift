//
//  ExtensionUIButton.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 4. 6..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

extension UIButton{
    
    func setImage(image: UIImage?, inFrame frame: CGRect?, forState state: UIControlState){
        self.setImage(image, forState: state)
        
        if(frame != nil){
            self.imageEdgeInsets = UIEdgeInsets(
                top: frame!.minY - self.frame.minY,
                left: frame!.minX - self.frame.minX,
                bottom: self.frame.maxY - frame!.maxY,
                right: self.frame.maxX - frame!.maxX
            )
        }
    }
    
}