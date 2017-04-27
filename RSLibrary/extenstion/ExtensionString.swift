import UIKit

extension String {
    func urlEncode() -> String? {
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        return escapedString
    }
    func escapeString() -> String {
        let escapedString = self.replacingOccurrences(of: "\"", with: "\\\"")
        return escapedString
    }
    
    func replace(_ target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func globalUrl() -> String {
        var temp = self.replace("http://", withString: "")
        temp = temp.replace("https://", withString: "")
        let index = temp.range(of: ":",options: NSString.CompareOptions.literal)
        if index != nil {
            temp = temp.substring(to: index!.lowerBound)
        }
        return temp
    }
    
    
    func paramParse() -> [String:String] {
        var ret_val = [String:String]()
        let params = self.components(separatedBy: "&")
        for  param in params {
            let param_data = param.components(separatedBy: "=")
            if param_data.count > 1{
                ret_val[param_data[0]] = param_data[1]
            }
        }
        return ret_val
    }

}

