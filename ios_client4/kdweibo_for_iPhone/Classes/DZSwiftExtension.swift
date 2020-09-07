//
//  DZSwiftExtension.swift
//  kdweibo
//
//  Created by Darren Zheng on 15/12/30.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

import Foundation

let kd_StatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
let kd_StatusBarAndNaviHeight: CGFloat = 44.0 + kd_StatusBarHeight
let kd_BottomSafeAreaHeight: CGFloat = UIDevice.isRunningAtiPhoneX() ? 34.0 : 0

func delay(_ delay:Double, _ closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func dz_bindStringValue(fromDict: [String: AnyObject], toObj: NSObject, withKey: String) {
    if let value = fromDict[withKey] {
        toObj.setValue("\(value)", forKey: withKey)
    }
}

// MARK: - NSDictionary
extension NSDictionary {
    // 取出字典中的值并转换成Decode String, 用于网络JSON解包 #20151230
    func dz_toStringForKey(_ key: String) -> (String) {
        if let anyValue = self[key] {
            //            let stringValue = "\(anyValue)"
            //            if let decodedString = stringValue.stringByRemovingPercentEncoding {
            //                return decodedString
            //            } else {
            //                return stringValue
            //            }
            return "\(anyValue)"
        } else {
            return ""
        }
    }
}


// MARK: - UIColor
extension UIColor {
    // How to use hex colour values in Swift
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
}

extension UIImageView {
    // 变圆
    func toRound()->() {
        self.layer.cornerRadius = self.frame.size.height/2
        self.layer.masksToBounds = true
    }
    
}

extension UIImage {
    
    var heightDivideWidthRatio: CGFloat {
        return self.size.height / self.size.width
    }
    
    var widthDivideHeightRatio: CGFloat {
        return self.size.width / self.size.height
    }
}

// MARK: - UIDevice
extension UIDevice {
    // How to determine iphone model in Swift?
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}

extension NSArray {
    func safeObjectAtIndex(_ index : NSInteger) -> AnyObject? {
        if index > self.count - 1 {
            return nil;
        }
        return self.object(at: index) as AnyObject
    }
}

extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addShadow(shadowColor: UIColor,
                               shadowOffset: CGSize,
                               shadowOpacity: Float,
                               shadowRadius: CGFloat) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}

extension CALayer {
    func addShadow(shadowColor: UIColor,
                               shadowOffset: CGSize,
                               shadowOpacity: Float,
                               shadowRadius: CGFloat) {
        self.shadowColor = shadowColor.cgColor
        self.shadowOffset = shadowOffset
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
    }
}
