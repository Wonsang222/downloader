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

}
