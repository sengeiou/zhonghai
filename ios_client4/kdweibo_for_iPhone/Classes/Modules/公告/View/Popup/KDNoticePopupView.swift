//
//  KDNoticePopupView.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/12.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

// MARK: - Input -

@objc protocol KDNoticePopupViewDataSource {
    
    // 总标题
    var popupViewTitle: String? { get }
    
    // 更多按钮
    var popupViewMoreButtonTitle: String? { get }
    
    // 文章标题
    var popupViewContentTitle: String? { get }
    
    // 文章副标题
    var popupViewContentSubTitle: String? { get }
    
    // 文章正文
    var popupViewContent: String? { get }
    
    // 确认按钮文本
    var popupViewConfirmButtonTitle: String? { get }
    
}

// MARK: - Output -

@objc protocol KDNoticePopupViewDelegate {
    
    // 更多按钮按下
    func popupViewMoreButtonPressed(_ popupView: KDNoticePopupView)
    
    // 确认按钮按下
    func popupViewConfirmButtonPressed(_ popupView: KDNoticePopupView)
    
}

class KDNoticePopupView: UIView {
    
    // MARK: - Properties -

    weak var delegate: KDNoticePopupViewDelegate?
    weak var dataSource: KDNoticePopupViewDataSource? {
        didSet {
            update()
        }
    }
    
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    lazy var maskBgButton: UIButton = {
        $0.backgroundColor = UIColor.kdPopup()
        return $0
    }(UIButton())
    
    lazy var containerView: UIView = {
        $0.backgroundColor = UIColor.white
        $0.layer.cornerRadius = 8
        return $0
    }(UIView())
    
    lazy var titleLabel: UILabel = {
        $0.font = FS4
        $0.textColor = FC2
        $0.text = " "
        return $0
    }(UILabel())
    
    lazy var moreButton: KDSimpleHighlightedButton = {
        $0.titleLabel?.font = FS4
        $0.setTitleColor(FC2, for: UIControlState())
        $0.addTarget(self, action: #selector(KDNoticePopupView.moreButtonPressed), for: UIControlEvents.touchUpInside)
        return $0
    }(KDSimpleHighlightedButton())
    
    lazy var arrow: UIImageView = {
        $0.image = UIImage(named: "appstore_tip_arrow")
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    func moreButtonPressed() {
        delegate?.popupViewMoreButtonPressed(self)
    }
    
    lazy var dividingLine: UIView = {
        $0.backgroundColor = UIColor.kdDividingLine()
        return $0
    }(UIView())
    
    lazy var contentTitleLabel: UILabel = {
        $0.font = FS2
        $0.textColor = FC1
        $0.numberOfLines = 0
        $0.text = " "
        return $0
    }(UILabel())
    
    lazy var contentSubtitleLabel: UILabel = {
        $0.font = FS7
        $0.textColor = FC2
        $0.text = " "
        return $0
    }(UILabel())
    
    lazy var contentTextView: UITextView = {
        $0.font = FS3
        $0.textColor = FC2
        $0.text = " "
        $0.isEditable = false
        $0.textContainer.lineFragmentPadding = 0
        $0.textContainerInset = UIEdgeInsets.zero
        $0.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
        return $0
    }(UITextView())
    
    lazy var glassMask: UIImageView = {
        return $0
    }(UIImageView())
    
    lazy var confirmButton: KDSimpleHighlightedButton = {
        $0.titleLabel?.font = FS3
        $0.setTitleColor(UIColor.white, for: UIControlState())
        $0.backgroundColor = FC5
        $0.layer.cornerRadius = 20
        $0.addTarget(self, action: #selector(KDNoticePopupView.confirmButtonPressed), for: UIControlEvents.touchUpInside)
        return $0
    }(KDSimpleHighlightedButton())
    
    func confirmButtonPressed() {
        if let delegate = delegate {
            delegate.popupViewConfirmButtonPressed(self)
        } else {
            containerView.alpha = 0
            maskBgButton.alpha = 0
            removeFromSuperview()
        }
    }

    // MARK: - Setup -
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func totalHeight(_ text: String?) -> CGFloat {
        guard let text = text
            else { return 0 }
        var totalHeight: CGFloat = 0
        
        totalHeight += 44
        totalHeight += 0.5
        totalHeight += 25
        totalHeight += CGFloat((FS2?.lineHeight)!)
        totalHeight += 6
        totalHeight += CGFloat((FS7?.lineHeight)!)
        totalHeight += 25
        totalHeight += KDString.heightForString(text, width: KDNoticePopupView.textMaximumWidth,font: FS3!)
        totalHeight += 50
        totalHeight += 44
        totalHeight += 15
        
        totalHeight = min(totalHeight, KDNoticePopupView.maximumHeight)
        
        return totalHeight
    }
    
    static let maximumWidth = KDFrame.screenWidth() - 20 * 2
    static let textMaximumWidth = maximumWidth - 20 * 2
    static let maximumHeight = maximumWidth * (85.0 / 67)
    static let titleTopMargin = (44 - (FS4?.lineHeight)!) / 2.0
    
    lazy var bindings: [String: AnyObject] = {
        return [
            "titleLabel": self.titleLabel,
            "moreButton": self.moreButton,
            "dividingLine": self.dividingLine,
            "contentTitleLabel": self.contentTitleLabel,
            "contentSubtitleLabel": self.contentSubtitleLabel,
            "contentTextView": self.contentTextView,
            "glassMask": self.glassMask,
            "confirmButton": self.confirmButton,
            "arrow": self.arrow,
        ]
    }()
    
    var metrics: [String: Any] {
        return [
            "titleTopMargin": KDNoticePopupView.titleTopMargin as AnyObject,
            "textViewBottomMargin": totalHeight(dataSource?.popupViewContent) == KDNoticePopupView.maximumHeight ? 5 : 50 as AnyObject
        ]
    }
    
    let vfls: [String] = [
        "V:|-titleTopMargin-[titleLabel(20)]-titleTopMargin-[dividingLine(1)]-25-[contentTitleLabel]-6-[contentSubtitleLabel(20)]-25-[contentTextView]-(<=textViewBottomMargin)-[confirmButton(44)]-15-|",
        "V:|[moreButton(44)]",
        "H:|-20-[titleLabel]-(>=0)-[moreButton]-8-[arrow(6)]-20-|",
        "V:|[arrow(44)]",
        "H:|-20-[dividingLine]-20-|",
        "H:|-20-[contentTitleLabel]-20-|",
        "H:|-20-[contentSubtitleLabel]-20-|",
        "H:|-20-[contentTextView]-20-|",
        "H:|-20-[confirmButton]-20-|",
        ]
    
    func setup() {
        addSubview(maskBgButton)
        addSubview(containerView)
        containerView.addSubviews([titleLabel, moreButton, dividingLine, contentTitleLabel, contentSubtitleLabel, contentTextView, glassMask, confirmButton, arrow])
        
        // 底部虚化
        gradientLayer.colors = [UIColor.init(white: 1, alpha: 0).cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1)
        containerView.layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Update -
    var currentConstraints = [NSLayoutConstraint]()
    func update() {
        
        if currentConstraints.count > 0 {
            removeConstraints(currentConstraints)
        }
        currentConstraints += kd_setupVFL([
            "containerView": containerView,
            "maskBgButton": maskBgButton
            ], metrics: [
                "width": KDNoticePopupView.maximumWidth as AnyObject,
                "height": totalHeight(dataSource?.popupViewContent) as AnyObject
            ], constraints: [
                "H:|[maskBgButton]|",
                "V:|[maskBgButton]|",
                "H:[containerView(width)]",
                "V:[containerView(height)]",
            ], delayInvoke: false)
        currentConstraints += [containerView.kd_setCenterX()]
        currentConstraints += [containerView.kd_setCenterY()]
        
        let maxLayoutStyle = totalHeight(dataSource?.popupViewContent) == KDNoticePopupView.maximumHeight
     
        currentConstraints += kd_setupVFL(bindings,
                                         metrics: metrics as [String : AnyObject],
                                         constraints: vfls,
                                         delayInvoke: false)
        
        contentTextView.isScrollEnabled = maxLayoutStyle
        
        guard let dataSource = dataSource
            else { return }
        
        titleLabel.text = dataSource.popupViewTitle
        moreButton.setTitle(dataSource.popupViewMoreButtonTitle, for: UIControlState())
        contentTitleLabel.text = dataSource.popupViewContentTitle
        contentSubtitleLabel.text = dataSource.popupViewContentSubTitle
        contentTextView.text = dataSource.popupViewContent
        confirmButton.setTitle(dataSource.popupViewConfirmButtonTitle, for: UIControlState())
        
        gradientLayer.frame = CGRect(x: 20.0, y: totalHeight(dataSource.popupViewContent) - 15 - 44 - 20, width: KDNoticePopupView.textMaximumWidth, height: 20)
        gradientLayer.isHidden = !maxLayoutStyle
    }
    
}

