import UIKit

extension String {
    func urlEncode() -> String? {
        let escapedString = self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        return escapedString
    }
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func globalUrl() -> String {
        var temp = self.replace("http://m.", withString: "")
        temp = temp.replace("https://m.", withString: "")
        temp = self.replace("http://", withString: "")
        temp = temp.replace("https://", withString: "")
        return temp
    }
    
    
    func paramParse() -> [String:String] {
        var ret_val = [String:String]()
        let params = self.componentsSeparatedByString("&")
        for  param in params {
            let param_data = param.componentsSeparatedByString("=")
            if param_data.count > 1{
                ret_val[param_data[0]] = param_data[1]
            }
        }
        return ret_val
    }

}

