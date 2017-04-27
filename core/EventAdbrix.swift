//
//  EventAdbrix.swift
//  magicapp
//
//  Created by WISA on 2017. 4. 7..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit

class EventAdbrix {
    
    
    static func firstTimeExperience(_ param:[String:AnyObject]){
        #if ADBRIX
        if let fParam = param["param"] as? String{
            AdBrix.firstTimeExperience(param["name"] as! String, param: fParam)
        }else{
            AdBrix.firstTimeExperience(param["name"] as! String)
        }
        #endif
    }
    static func retention(_ param:[String:AnyObject]){
        #if ADBRIX
        if let fParam = param["param"] as? String{
            AdBrix.retention(param["name"] as! String, param: fParam)
        }else{
            AdBrix.retention(param["name"] as! String)
        }
        #endif
    }
    static func setAge(_ param:[String:AnyObject]){
        #if ADBRIX
        let age:Int = param["age"] as! Int
        IgaworksCore.setAge(Int32(age))
        #endif
    }
    static func setGender(_ param:[String:AnyObject]){
        #if ADBRIX
        let gender = param["gender"] as! String
        if gender == "M" {
            IgaworksCore.setGender(IgaworksCoreGenderMale)
        }else{
            IgaworksCore.setGender(IgaworksCoreGenderFemale)
        }
        #endif
    }
    static func purchase(_ param:[String:AnyObject]){
        #if ADBRIX
        var productModels = [AdBrixCommerceProductModel]()
        let products = param["products"] as! [[String:AnyObject]]
        for product in products {
            let categorys = product["category"] as! [String]
            var categoryModel:AdBrixCommerceProductCategoryModel?
            if categorys.count > 0 {
                categoryModel = AdBrixCommerceProductCategoryModel.create(categorys[0])
            }
            if categorys.count > 1 {
                categoryModel = AdBrixCommerceProductCategoryModel.create(categorys[0], category2: categorys[1])
            }
            if categorys.count > 2 {
                categoryModel = AdBrixCommerceProductCategoryModel.create(categorys[0], category2: categorys[1], category3: categorys[2])
            }
            if categorys.count > 3 {
                categoryModel = AdBrixCommerceProductCategoryModel.create(categorys[0], category2: categorys[1], category3: categorys[2], category4: categorys[3])
            }
            if categorys.count > 4 {
                categoryModel = AdBrixCommerceProductCategoryModel.create(categorys[0], category2: categorys[1], category3: categorys[2], category4: categorys[3], category5: categorys[4])
            }
            let productModel = AdBrix.createCommerceProductModel(product["productId"] as! String,
                                                                 productName: product["productNm"] as! String,
                                                                 price: product["price"] as! Double,
                                                                 discount: product["discount"] as! Double,
                                                                 quantity: UInt(product["quantity"] as! Int),
                                                                 currencyString:AdBrix.currencyName(currencyValue(product["currency"] as! String)),
                                                                 category: categoryModel!,
                                                                 extraAttrsMap: nil)
            productModels.append(productModel)
        }
        if productModels.count == 1 {
            AdBrix.purchase(param["orderId"] as! String, product: productModels[0], paymentMethod: AdBrix.paymentMethod(UInt(AdbrixPaymentMethod.AdBrixPaymentMobilePayment.rawValue)))
        }else{
            AdBrix.purchase(param["orderId"] as! String, productsInfos: productModels, paymentMethod: AdBrix.paymentMethod(UInt(AdbrixPaymentMethod.AdBrixPaymentMobilePayment.rawValue)))
            
        }
        #endif
    }
    
    static func setCustomCohort(_ param:[String:AnyObject]){
        #if ADBRIX
        let index = param["index"] as! Int
        if let type = AdBrixCustomCohortType(rawValue: index) {
            AdBrix.setCustomCohort(type, filterName: param["value"] as! String)
        }
        #endif
    }
    
    static func currencyValue(_ value:String) -> UInt{
        if value == "KRW" {
            return UInt(AdBrixCurrencyType.KRW.rawValue)
        }else if value == "USD" {
            return UInt(AdBrixCurrencyType.USD.rawValue)
        }else if value == "JPY" {
            return UInt(AdBrixCurrencyType.JPY.rawValue)
        }else if value == "EUR" {
            return UInt(AdBrixCurrencyType.EUR.rawValue)
        }else if value == "GBP" {
            return UInt(AdBrixCurrencyType.GBP.rawValue)
        }else if value == "CHY" {
            return UInt(AdBrixCurrencyType.CNY.rawValue)
        }else if value == "TWD" {
            return UInt(AdBrixCurrencyType.TWD.rawValue)
        }else if value == "HKD" {
            return UInt(AdBrixCurrencyType.HKD.rawValue)
        }
        return UInt(AdBrixCurrencyType.KRW.rawValue)
    }
    
}
