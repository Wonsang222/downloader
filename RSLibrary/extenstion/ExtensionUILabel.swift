//
//  ExtensionUILabel.swift
//  bashow_p
//
//  Created by WISA on 2017. 3. 20..
//  Copyright © 2017년 WISA. All rights reserved.
//

import UIKit

extension UILabel {
    
    
    func wrapSize() -> CGRect{
        let source = text! as NSString
        let size = source.boundingRect(with: CGSize(width: self.rsWidth, height: CGFloat.greatestFiniteMagnitude),
                                       options: [.usesLineFragmentOrigin,.usesFontLeading],
                                       attributes: [NSFontAttributeName: self.font], context: nil)
        return size
    }
    
    func wrapSizeHeight() -> CGRect{
        let source = text! as NSString
        let size = source.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 100),
                                       options: [.usesLineFragmentOrigin,.usesFontLeading],
                                       attributes: [NSFontAttributeName: self.font], context: nil)
        return size
    }
    
    func adJustWrapSize(){
        let size = CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let textSize = self.sizeThatFits(size)
        self.rsWidth = textSize.width
        self.rsHeight = textSize.height
    }
    func adJustWrapHeightSize(){
        let size = CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let textSize = self.sizeThatFits(size)
        self.rsHeight = textSize.height
    }
    
    
    
}

