//
//  KDAgoraPersonCell.swift
//  kdweibo
//
//  Created by lichao_liu on 16/5/20.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDAgoraPersonCell: UICollectionViewCell {
    
    var isCreate: Bool = false
    var blueLayer: CALayer?
    var grayLayer: CALayer?
    
    lazy var headerImageView: UIImageView = {
        let headImageView = KDRoundImageView()
        headImageView.image = XTImageUtil.headerDefaultImage()
        return headImageView
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = FC2
        label.font = FS6
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 2
        label.frame = CGRect(x: 0, y: 70, width: 100,height: 25);
        return label
    }()
    
    lazy var muteMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0x04142a)
        view.alpha = 0.6
        view.layer.cornerRadius = 55 / 2
        view.layer.masksToBounds = true
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "phone_btn_mute_small")
        view.addSubview(imageView)
        imageView.mas_makeConstraints { make in
            make?.centerX.mas_equalTo()(view.mas_centerX)
            make?.centerY.mas_equalTo()(view.mas_centerY)
            make?.height.mas_equalTo()(30)
            make?.width.mas_equalTo()(21)
        }
        
        view.isHidden = true
        
        return view;
    }()
    
    lazy var handsUpMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 55 / 2
        view.layer.masksToBounds = true
        
        let maskView = UIView()
        maskView.backgroundColor = UIColor(rgb: 0x04142a)
        maskView.alpha = 0.6
        maskView.layer.cornerRadius = 55 / 2
        maskView.layer.masksToBounds = true
        view.addSubview(maskView)
        maskView.mas_makeConstraints{ make in
            make?.edges.mas_equalTo()(view)?.with().insets()(UIEdgeInsets.zero)
        }
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "phone_btn_handsUp_small")
        view.addSubview(imageView)
        imageView.mas_makeConstraints { make in
            make?.centerX.mas_equalTo()(view.mas_centerX)
            make?.centerY.mas_equalTo()(view.mas_centerY)
            make?.height.mas_equalTo()(30)
            make?.width.mas_equalTo()(21)
        }
        
        view.isHidden = true
        
        return view;
    }()
    
    var agoraModel:KDAgoraModel?{
        didSet{
            var imageURL:URL? = nil
            if let agoraModel = agoraModel {
                if agoraModel.person == nil && KDString.isSolidString(agoraModel.account) {
                    agoraModel.person = KDCacheHelper.person(forKey: agoraModel.account);
                }
                if let person = agoraModel.person{
                    if person.hasHeaderPicture(){
                        var url:String = person.photoUrl;
                        let range = url.range(of: "?")
                        if range?.lowerBound != range?.upperBound{
                            url = url + "&spec=180"
                        }else{
                            url = url + "?spec=180"
                        }
                        imageURL = URL(string: url)
                    }
                    if imageURL != nil{
                        headerImageView.setImageWith(imageURL, placeholderImage: UIImage(named: "user_default_portrait"))
                    }else{
                        headerImageView.image = UIImage(named: "user_default_portrait")
                    }
                    if(!self.isCreate)
                    {
                        usernameLabel.text = person.personName ?? ""
                        usernameLabel.textColor = FC2
                    }
                    else{
                        let attributeStr = NSMutableAttributedString(string: " \(person.personName ?? "")", attributes: [NSFontAttributeName:FS6])
                        attributeStr.dz_setImage(withName: "app_pic_initiator_normal", range: NSMakeRange(0, 0))
                        attributeStr.dz_setFont(FS6)
                        attributeStr.dz_setTextAlignment(NSTextAlignment.center)
                        attributeStr.dz_setBaselineOffset(-2, range: NSMakeRange(0, 1))
                        usernameLabel.attributedText = attributeStr
                        usernameLabel.sizeToFit()
                        usernameLabel.frame = CGRect(x: 0, y: 70, width: 100,height: 25)
                        usernameLabel.textColor = UIColor.kdTextColor10()
                    }
                }
                
                self.volumeType = agoraModel.volumeType;
                
                self.changeMute(agoraModel.mute)
                
                self.setNeedsLayout()
            }
        }
    }
    
    fileprivate var volumeType: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(headerImageView)
        headerImageView.mas_makeConstraints { make in
            make?.width.mas_equalTo()(55)
            make?.height.mas_equalTo()(55)
            make?.centerX.equalTo()(self.contentView.centerX)?.offset()(0)
            make?.top.equalTo()(self.contentView.top)?.offset()(10)
        }
        headerImageView.addSubview(muteMaskView)
        muteMaskView.mas_makeConstraints { make in
            make?.edges.mas_equalTo()(self.headerImageView)?.with().insets()(UIEdgeInsets.zero)
        }
        headerImageView.addSubview(handsUpMaskView)
        handsUpMaskView.mas_makeConstraints { make in
            make?.edges.mas_equalTo()(self.headerImageView)?.with().insets()(UIEdgeInsets.zero)
        }
        self.contentView.addSubview(usernameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KDAgoraPersonCell{
    
    func changeMute(_ mute: Int) -> Void {
        //mute 0发言 1举手 2静音
        if mute == 2 {
            self.muteMaskView.isHidden = false
            self.handsUpMaskView.isHidden = true
            
            self.stopAnimation()
        }
        else if mute == 0 {
            self.muteMaskView.isHidden = true
            self.handsUpMaskView.isHidden = true
            
            //add灰色圈
            let color =  UIColor.kdBackgroundColor7()
            if self.grayLayer == nil {
                self.grayLayer = setUpGrayLayer(self.contentView.layer, size: CGSize(width: 60.5, height: 60.5), tintColor: color!)
            }
            
            self.startAnimation(self.volumeType)
        }
        else if mute == 1 {
            self.handsUpMaskView.isHidden = false
            self.muteMaskView.isHidden = true
            
            self.stopAnimation()
        }
    }
    
    func startAnimation(_ volume: Int) -> Void {
//        let distance = (volumeType == 0 ? 0 : Float(volumeType) * 1.0 / 255)
        let distance = (volume == 0 ? 0 : Float(volume) * 1.0 / 255)
        if(distance >= 0){
            let color =  UIColor.kdTextColor10()
            
            if self.blueLayer == nil {
                self.blueLayer = setUpAnimationInLayer(self.contentView.layer, size: CGSize(width: 60.5, height: 60.5), tintColor:color!, fromValue: 0, toValue: distance)
            }
            else {
                let animation = self.blueLayer?.animation(forKey: "strokeEnd") as? CABasicAnimation
                if let basicAnimation = animation {
                    let oldValue = (basicAnimation.toValue as? Float) ?? 0.0
                    if oldValue != distance {
                        if let blueLayer = self.blueLayer {
                            blueLayer.removeFromSuperlayer()
                            self.blueLayer = nil;
                        }
                        self.blueLayer = setUpAnimationInLayer(self.contentView.layer, size: CGSize(width: 60.5, height: 60.5), tintColor:color!, fromValue: oldValue, toValue: distance)
                    }
                }
            }
        }
        else {
            if let blueLayer = self.blueLayer {
                blueLayer.removeFromSuperlayer()
                self.blueLayer = nil;
            }
        }
    }
    
    func setUpAnimationInLayer(_ superLayer:CALayer,size:CGSize,tintColor:UIColor,fromValue:Float,toValue:Float) -> CALayer {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = 0.3
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        let circle = CAShapeLayer()
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.contentView.frame.size.width / 2, y: 10 + 55/2), radius: size.height/2, startAngle: CGFloat(M_PI/2), endAngle: CGFloat(5/2 * Float(M_PI)), clockwise: true)
        circle.fillColor = nil
        circle.strokeColor = tintColor.cgColor
        circle.lineWidth = 2.5
        circle.path = circlePath.cgPath
        circle.add(animation, forKey: "strokeEnd")
        superLayer.addSublayer(circle)
        superLayer.insertSublayer(circle, below: headerImageView.layer)
        return circle
    }
    
    func setUpGrayLayer(_ superLayer:CALayer,size:CGSize,tintColor:UIColor) -> CALayer {
        let circle = CAShapeLayer()
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.contentView.frame.size.width / 2, y: 10 + 55/2), radius: size.height/2, startAngle: CGFloat(M_PI/2), endAngle: CGFloat(5/2 * Float(M_PI)), clockwise: true)
        circle.fillColor = nil
        circle.strokeColor = tintColor.cgColor
        circle.lineWidth = 2.5
        circle.path = circlePath.cgPath
        superLayer.addSublayer(circle)
        superLayer.insertSublayer(circle, below: headerImageView.layer)
        return circle
    }
    
    func stopAnimation() -> Void {
        if let blueLayer = self.blueLayer{
            blueLayer.removeFromSuperlayer()
            self.blueLayer = nil
        }
        
        if let grayLayer = self.grayLayer {
            grayLayer.removeFromSuperlayer()
            self.grayLayer = nil
        }
    }
}
