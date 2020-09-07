//
//  KDChatCombineVoiceCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/8/18.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

@objc protocol KDChatCombineTextCellDelegate {
    @objc optional func voiceCell(_ cell: KDChatCombineVoiceCell, didTapVoiceView voiceView: BubbleVoiceView)
}

class KDChatCombineVoiceCell: KDChatCombineBaseCell, KDCommonAudioCell {
    
    weak var delegate: KDChatCombineTextCellDelegate?
    // MARK: 语音
    lazy var voiceView: BubbleVoiceView = {
        let voiceView = BubbleVoiceView()
        voiceView.backgroundColor = UIColor.clear
        voiceView.isUserInteractionEnabled = false
        voiceView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)

        return voiceView
    }()
    
    lazy var voiceButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = FC5;//UIColor.whiteColor()
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(KDChatCombineVoiceCell.voiceButtonPressed), for: .touchUpInside)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.kdDividingLine().cgColor
        return button
    }()
    
    // MARK: 秒数
    lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white
        return label
    }()
    
    func voiceButtonPressed() {
        delegate?.voiceCell?(self, didTapVoiceView: voiceView)
    }
    
    var voiceViewWidth: MASConstraint?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(voiceButton)
        voiceButton.mas_makeConstraints { make in
            make?.top.equalTo()(self.timeLabel.bottom)?.with().offset()(12)
            make?.left.equalTo()(self.headView.right)?.with().offset()(12)
            self.voiceViewWidth = make?.width.mas_equalTo()(self.voiceWidthForLength(self.msgLen))
            make?.height.mas_equalTo()(44)
            make?.bottom.equalTo()(self.voiceButton.superview!.bottom)?.with().offset()(-12)
        }
        
        voiceView.messageDirection = MessageDirectionRight
        voiceButton.addSubview(voiceView)
        voiceView.mas_makeConstraints { make in
            make?.left.equalTo()(self.voiceView.superview!.left)?.with().offset()(12)
            make?.width.mas_equalTo()(12)
            make?.height.mas_equalTo()(19)
            make?.centerY.equalTo()(self.voiceView.superview!.centerY)
            return()
        }
        
        voiceButton.addSubview(timerLabel)
        timerLabel.mas_updateConstraints{ make in
            make?.right.equalTo()(self.timerLabel.superview!.right)?.with().offset()(-8)
            make?.centerY.equalTo()(self.timerLabel.superview!.centerY)
        }
    }
    
    func voiceWidthForLength(_ msgLen: CGFloat) -> CGFloat {
        let a = 100.0 * (min(msgLen, 60.0) / 60.0) + 59.0
        let b = KDFrame.screenWidth() - (12 + 12 + 44) * 2
        return min(a, b)
    }
    
    var msgLen: CGFloat = 60 {
        didSet {
            voiceViewWidth?.uninstall()
            voiceButton.mas_updateConstraints{ make in
                self.voiceViewWidth = make?.width.mas_equalTo()(self.voiceWidthForLength(self.msgLen))
            }
            timerLabel.text = "\(Int(msgLen))\""
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
