import UIKit

extension String {
    func urlEncode() -> String? {
        let escapedString = self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        return escapedString
    }


	func toColor () -> UIColor {
		var cString:String = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString

		if (cString.hasPrefix("#")) {
			cString = cString.substringFromIndex(advance(cString.startIndex, 1))
		}

		if ((cString.characters.count) != 6) {
			return UIColor.grayColor()
		}

		var rgbValue:UInt32 = 0
		NSScanner(string: cString).scanHexInt(&rgbValue)

		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
}
