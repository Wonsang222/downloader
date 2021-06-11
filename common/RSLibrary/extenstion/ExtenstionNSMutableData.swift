import UIKit

extension NSMutableData{
	
	func appendString(_ string: String){
		let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
	}
}

