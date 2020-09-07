//
//  KDChatNotraceTextView.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/3/30.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

final class KDChatNotraceTextView: UIView {
    
    lazy var contentTextView: KDExpressionLabel = {
        let type:KDExpressionLabelType = KDExpressionLabelType(KDExpressionLabelType_Expression | KDExpressionLabelType_URL | KDExpressionLabelType_PHONENUMBER | KDExpressionLabelType_EMAIL | KDExpressionLabelType_TOPIC | KDExpressionLabelType_Keyword)
        let textView = KDExpressionLabel.init(frame: CGRect.zero, andType: type, urlRespondFucIfNeed:nil)
        textView?.textAlignment = .center
        textView?.font = FS1
        textView?.textColor = FC1
        return textView!
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(contentTextView)
        contentTextView.mas_makeConstraints { make in
            make?.top.equalTo()(self.contentTextView.superview!.top)?.with().offset()(55)
            make?.left.equalTo()(self.contentTextView.superview!.left)?.with().offset()(24)
            make?.right.equalTo()(self.contentTextView.superview!.right)?.with().offset()(-24)
            make?.bottom.equalTo()(self.contentTextView.superview!.bottom)?.with().offset()(-55)
            return()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
