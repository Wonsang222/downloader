//
//  ExtensionUIView.swift
//  wing
//
//  Created by WISA on 2017. 11. 14..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit

var eventMap:[EventCarrier] = [EventCarrier]()


class EventCarrier : NSObject {
    
    var callback_object:(UIView)->Void
    
    init( callback : @escaping (UIView)-> Void ){
        self.callback_object = callback
        super.init()
    }
    
    @objc func clickObject(gesture:UITapGestureRecognizer){
        callback_object(gesture.view!)
    }
    
    
}


class ClickGesture : UITapGestureRecognizer{
    var eventCarrier:EventCarrier?
    
}

extension UIView{
    
    
    var rsX:CGFloat{
        get{
            return frame.origin.x
        }
        set {
            self.frame = self.frame.changeX(newValue)
        }
    }
    var rsY:CGFloat{
        get{
            return frame.origin.y
        }
        set{
            self.frame = self.frame.changeY(newValue)
        }
    }
    var rsWidth:CGFloat{
        get{
            return frame.size.width
        }
        set{
            self.frame = self.frame.changeWidth(newValue)
        }
    }
    var rsHeight:CGFloat{
        get{
            return frame.size.height
        }
        set{
            self.frame = self.frame.changeHeight(newValue)
        }
    }
    var rsEndX:CGFloat{
        get{
            return self.rsX + self.rsWidth
        }
    }
    var rsEndY:CGFloat{
        get{
            return self.rsY + self.rsHeight
        }
    }
    
    
    
    
    func removeAlView(){
        for view in self.subviews{
            view.removeFromSuperview()
        }
    }
    
    
    func onClick(callback: @escaping (UIView)-> Void){
        let eventCarrier = EventCarrier(callback: callback)
        let tap = ClickGesture(target:eventCarrier , action: #selector(EventCarrier.clickObject(gesture:)))
        tap.numberOfTapsRequired = 1
        tap.eventCarrier = eventCarrier
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
    }
    func clearOnClick(){
        self.isUserInteractionEnabled = false
        if let gestures = self.gestureRecognizers {
            for gesture in gestures {
                self.removeGestureRecognizer(gesture)
            }
        }
    }
    
    func stackLayout() -> CGFloat {
        var start:CGFloat = 0
        for sView in self.subviews{
            sView.rsY = start
            start += sView.frame.height
        }
        return start
    }
    
    func stackLayout(_ margins:[CGFloat]) -> CGFloat {
        var start:CGFloat = 0
        for (index,sView) in self.subviews.enumerated(){
            if sView.isHidden{
                continue
            }
            var margin:CGFloat = 0
            if (margins.count - 1) >= index {
                margin = margins[index]
            }
            //            if index != 0 {
            //                margin = self.subviews[index-1].isHidden ? 0 :
            //            }
            sView.rsY = start + margin
            start += (sView.frame.height + margin)
        }
        return start
    }
}
