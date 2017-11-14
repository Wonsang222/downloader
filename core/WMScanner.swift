//
//  WMScaner.swift
//  magicapp
//
//  Created by WISA on 2017. 10. 30..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit
import ZBarSDK

extension ZBarSymbolSet: Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}


class WMScanner : ZBarReaderViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.view.subviews);
        self.view.subviews[2].removeFromSuperview()
        self.view.subviews[1].removeFromSuperview()
//
        self.readerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)

        let views = Bundle.main.loadNibNamed("WMScannerView", owner: self, options: nil)!
        let topView = views[1] as! UIView
        let overlap = views[0] as! UIView
        topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 66)
        overlap.frame = CGRect(x: 0, y: topView.frame.height, width: self.view.frame.width, height: self.view.frame.height - topView.frame.height)
        self.view.addSubview(topView)
        self.view.addSubview(overlap)
        
    }
    
    @IBAction func doBack(_ sender:AnyObject){
        self.readerDelegate.imagePickerControllerDidCancel?( UIImagePickerController() )
        self.dismiss(animated: true, completion: nil)
    }
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        UIApplication.shared.statusBarStyle = .default
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        UIApplication.shared.statusBarStyle = .lightContent
//    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}
