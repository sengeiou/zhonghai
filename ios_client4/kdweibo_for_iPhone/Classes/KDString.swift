//
//  KDString.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/16.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

class KDString: NSObject {
    
    class func cleanString(_ text: String) -> String {
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    class func heightForString(_ text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }
    
    class func widthForString(_ text: String, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: UIScreen.main.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.width
    }
    
    /**
     等同于Objective-C的str.length > 0
     
     - parameter str: source string
     
     - returns: is not null && not empty string
     */
    class func isSolidString(_ str: String?) -> Bool {
        if let str = str {
            return !str.isEmpty
        } else {
            return false
        }
    }
    
    class func substringWithNSRange(_ range: NSRange, text: String?) -> String? {
        guard let text = text, range.location != NSNotFound && (range.location + range.length <= (text as NSString).length)
            else { return nil }
        return (text as NSString).substring(with: range)
    }
    
}
