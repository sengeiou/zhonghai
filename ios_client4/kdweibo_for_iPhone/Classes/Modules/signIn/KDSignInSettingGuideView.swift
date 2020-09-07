//
//  KDSignInSettingGuideView.swift
//  kdweibo
//
//  Created by 张培增 on 2017/1/9.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDSignInSettingGuideView: UIView {
    
    var touchRect : CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    var type : NSInteger = 0 {
        didSet {
            setUpViewWithType(type: type)
        }
    }
    
    var actionBlock : (() -> ())? = nil
    
    lazy var fingerImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "sign_tip_guide_finger")
        return imageView
    }()
    
    lazy var textLabel : UILabel = {
        let label = UILabel()
        label.textColor = FC6
        label.font = UIDevice.isRunningOveriPhone6() ? FS2 : FS4
        return label
    }()
    
    lazy var iKnowButton : UIButton = {
        let button = UIButton()
        
        let normalStr = NSMutableAttributedString(string: ASLocalizedString("我知道了"))
        normalStr.dz_setTextAlignment(.center)
        normalStr.dz_setTextColor(FC6)
        normalStr.dz_setFont(FS4)
        normalStr.dz_setUnderline()
        button.setAttributedTitle(normalStr, for: UIControlState())
        
        let highlightedStr = NSMutableAttributedString(string: ASLocalizedString("我知道了"))
        highlightedStr.dz_setTextAlignment(.center)
        highlightedStr.dz_setTextColor(UIColor(rgb: 0xFFFFFF, alpha: 0.5))
        highlightedStr.dz_setFont(FS4)
        highlightedStr.dz_setUnderline()
        button.setAttributedTitle(highlightedStr, for: .highlighted)
        
        button.addTarget(self, action: #selector(iKnowBtnDidPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        addSubview(fingerImageView)
        addSubview(textLabel)
        addSubview(iKnowButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        //绘制背景
        let context : CGContext = UIGraphicsGetCurrentContext()!
        UIColor(rgb: 0x0C213F, alpha: 0.8).set()
        context.addRect(rect)
        context.fillPath()
        
        //绘制点击区域
        context.setBlendMode(.clear)
        if type == 0 {
            //绘制矩形的点击区域
            context.addRect(touchRect)
        }
        else {
            //绘制圆角矩形的点击区域
            let bezierPath = UIBezierPath(roundedRect: touchRect, cornerRadius: 30)
            context.addPath(bezierPath.cgPath)
        }
        context.fillPath()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // MARK: 风险点
        if let touch = touches.first {
            let locationPoint = touch.location(in: self)
            if touchRect.contains(locationPoint) {
                if let block = actionBlock {
                    block()
                    self.removeFromSuperview()
                }
            }
        }
    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        //可能有bug
////        guard let locationPoint = ((touches as NSSet).anyObject() as AnyObject).location(in: self) else {
////            return
////        }
//        
//        if touchRect.contains(FloatingPoint) {
//            if let block = actionBlock {
//                block()
//                self.removeFromSuperview()
//            }
//        }
//    }
    
    func setUpViewWithType(type: NSInteger) {
        let screenWidth = UIScreen.main.bounds.size.width
        
        switch type {
        case 0:
            touchRect = CGRect(x: 0, y: 102, width: screenWidth, height: 60)
            
            fingerImageView.frame = CGRect(x: 48, y: touchRect.maxY + 9, width: 16, height: 19)
            
            textLabel.text = ASLocalizedString("点击签到组管理,可按部门设置签到点")
            textLabel.textAlignment = .left
        case 1:
            touchRect = CGRect(x: screenWidth - 78 - (UIDevice.isRunningOveriPhone6() ? 14 : 6), y: 26, width: 78, height: 32)
            
            fingerImageView.frame = CGRect(x: screenWidth - 16 - 30, y: touchRect.maxY + 9, width: 16, height: 19)
            
            textLabel.text = ASLocalizedString("点击“高级设置”,为团队设置弹性考勤时间")
            textLabel.textAlignment = .right
        default:
            break
        }
        
        textLabel.frame = CGRect(x: NSNumber.kdDistance1(), y: touchRect.maxY + 39, width: screenWidth - 2 * NSNumber.kdDistance1(), height: 20)
        iKnowButton.frame = CGRect(x: screenWidth - 70 - NSNumber.kdDistance1(), y: textLabel.frame.maxY + 24, width: 70, height: 20)
        
        addFingerAnimation()
    }
    
    func addFingerAnimation() {
        UIView.beginAnimations("position", context: nil)
        UIView.setAnimationDuration(0.2)
        UIView.setAnimationRepeatCount(HUGE)
        UIView.setAnimationRepeatAutoreverses(true)
        
        let center = self.fingerImageView.center;
        self.fingerImageView.center = CGPoint(x: center.x, y: center.y + 6);
        
        UIView.commitAnimations()
    }
    
    func iKnowBtnDidPressed(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
}
