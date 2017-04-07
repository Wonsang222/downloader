//
//  EventAdbrix.swift
//  magicapp
//
//  Created by WISA on 2017. 4. 7..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit

class EventAdbrix {
    
    
    static func firstTimeExperience(param:[String:AnyObject]){
        if !AppProp.isAdbrix {
            return
        }
        if let fParam = param["param"] as? String{
            AdBrix.firstTimeExperience(param["name"] as! String, param: fParam)
        }else{
            AdBrix.firstTimeExperience(param["name"] as! String)
        }
    }
    static func retention(param:[String:AnyObject]){
        if !AppProp.isAdbrix {
            return
        }
        if let fParam = param["param"] as? String{
            AdBrix.retention(param["name"] as! String, param: fParam)
        }else{
            AdBrix.retention(param["name"] as! String)
        }
    }
    static func setAge(param:[String:AnyObject]){
        if !AppProp.isAdbrix {
            return
        }
        let age:Int = param["age"] as! Int
        IgaworksCore.setAge(Int32(age))
    }
    static func setGender(param:[String:AnyObject]){
        if !AppProp.isAdbrix {
            return
        }
        let gender = param["gender"] as! String
        if gender == "M" {
            IgaworksCore.setGender(IgaworksCoreGenderMale)
        }else{
            IgaworksCore.setGender(IgaworksCoreGenderFemale)
        }
    }
    static func purchase(param:[String:AnyObject]){
        if !AppProp.isAdbrix {
            return
        }
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
        
        AdBrix.purchase(param["orderId"] as! String, productsInfos: products, paymentMethod: AdBrix.paymentMethod(UInt(AdbrixPaymentMethod.AdBrixPaymentMobilePayment.rawValue)))
    }
    
    static func setCustomCohort(param:[String:AnyObject]){
        if !AppProp.isAdbrix {
            return
        }
        let index = param["index"] as! Int
        if let type = AdBrixCustomCohortType(rawValue: index) {
            AdBrix.setCustomCohort(type, filterName: param["value"] as! String)
        }
    }
    
    static func currencyValue(value:String) -> UInt{
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
