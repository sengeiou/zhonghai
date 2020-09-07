//
//  KDSignInActivityHintView.swift
//  kdweibo
//
//  Created by 张培增 on 2017/5/16.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

class KDSignInActivityHintView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        layer.cornerRadius = 15
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - model -
    var model: KDSignInActivityModel = KDSignInActivityModel() {
        didSet {
            modelDidSet()
        }
    }
    
    fileprivate func modelDidSet() {
        mainImageView.setImageWith(URL(string: KDImageSourceConfig.getImageSource(byPicId: model.picId).middle), placeholderImage: UIImage.kd_image(with: FC6))
        
        if model.btnBGColorNormal != nil && model.btnBGColorPress != nil {
            actionButton.setBackgroundImage(UIImage.kd_image(with: model.btnBGColorNormal), for: UIControlState())
            actionButton.setBackgroundImage(UIImage.kd_image(with: model.btnBGColorPress), for: .highlighted)
        }
        else {
            actionButton.backgroundColor = UIColor.clear
            actionButton.layer.borderWidth = 0.5
            actionButton.layer.borderColor = FC6?.cgColor
        }
        
        if model.btnTextColorNormal != nil && model.btnTextColorPress != nil {
            actionButton.setTitleColor(model.btnTextColorNormal, for: UIControlState())
            actionButton.setTitleColor(model.btnTextColorPress, for: .highlighted)
        }
        else {
            actionButton.setTitleColor(FC6, for: UIControlState())
            actionButton.setTitleColor(UIColor(red: 1, green: 1, blue:1, alpha:0.5), for: .highlighted)
        }
        
        if let btnText = model.btnText {
            actionButton.setTitle(btnText, for: UIControlState())
        }
        
    }
    
    // MARK: - show -
    func show() {
        
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        setupView(keyWindow)
        
    }
    
    fileprivate func setupView(_ view: UIView) {
        
//        view.addSubview(bgView)
//        kd_setupVFL([
//            "bgView" : bgView
//            ], constraints: [
//                "H:|[bgView]|",
//                "V:|[bgView]|"
//            ])
//        
//        view.addSubviews([self, closeButton])
//        kd_setupVFL([
//            "self" : self,
//            "closeButton" : closeButton
//            ], metrics: [
//                "width" :view.bounds.size.width * 0.775,
//                "height" : view.bounds.size.width * 0.775 / 0.8,
//                "buttonWidth" : 40,
//                "buttonHeight" : 40
//            ], constraints: [
//                "H:[self(width)]-(-15)-[closeButton(buttonWidth)]",
//                "V:[closeButton(buttonHeight)]-(-30)-[self(height)]"
//            ], delayInvoke: false)
//        self.kd_setCenterX()
//        self.kd_setCenterY()
//        
//        addSubviews([mainImageView, actionButton])
//        kd_setupVFL([
//            "mainImageView" : mainImageView,
//            "actionButton" : actionButton
//            ], constraints: [
//                "H:|[mainImageView]|",
//                "V:|[mainImageView]|",
//                "H:|-12-[actionButton]-12-|",
//                "V:[actionButton(44)]-14-|"
//            ])
//        
    }
    
    // MARK: - hide -
    fileprivate func hide() {
        bgView.removeFromSuperview()
        self.removeFromSuperview()
        closeButton.removeFromSuperview()
    }
    
    // MARK: - button method -
    func closeButtonPressed(_ sender: UIButton) {
        if let buttonDidClickedBlock = buttonDidClickedBlock {
            buttonDidClickedBlock(0)
        }
        hide()
    }
    
    func actionButtonPressed(_ sender: UIButton) {
        if let buttonDidClickedBlock = buttonDidClickedBlock {
            buttonDidClickedBlock(1)
        }
        hide()
    }
    
    var buttonDidClickedBlock: ((_ index: NSInteger) -> ())? = nil
    
    
    // MARK: - getter -
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.kdPopupBackground()
        return view
    }()

    lazy var mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.kd_image(with: FC6)
        return imageView
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "sign_tip_popup_close"), for: UIControlState())
        button.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, 10, 10)
        button.addTarget(self, action: #selector(KDSignInActivityHintView.closeButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.titleLabel?.font = FS3
        button.setTitle(ASLocalizedString("马上参与"), for: UIControlState())
        button.setTitleColor(FC6, for: UIControlState())
        button.setTitleColor(UIColor(red: 1, green: 1, blue:1, alpha:0.5), for: .highlighted)
        button.addTarget(self, action: #selector(KDSignInActivityHintView.actionButtonPressed(_:)), for: .touchUpInside)
        return button
    }()

}
