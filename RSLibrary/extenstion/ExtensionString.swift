import UIKit

extension String {
    func urlEncode() -> String? {
        let escapedString = self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        return escapedString
    }

}
