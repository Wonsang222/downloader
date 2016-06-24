//
//  WisaTracker.swift
//  magicapp
//
//  Created by WISA on 2016. 6. 22..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import Foundation

class WisaTracker {
    
    
    func page(page:String){
        RSHttp(controller:nil,progress:false,showingPopup:false).req(
            ApiFormApp().ap("mode","set_statistic")
                .ap("pack_name",AppProp.appId)
                .ap("page",page)
        )
    }
    
}
