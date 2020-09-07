//
//  KDChatNotraceCDView.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/3/30.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

final class KDChatNotraceCDView: UIView {
    
    var timer = 0
    var clock: Timer?
    
    var onCountdownEnd:(() -> ())?
    
    lazy var cdLabel: UILabel = {
        let label = UILabel()
        label.font = FS1
        label.textColor = FC5
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        self.addSubview(cdLabel)
        cdLabel.mas_makeConstraints { make in
            make?.edges.equalTo()(self)?.with().insets()(UIEdgeInsets.zero)
            return()
        }
    }
    
    func countdown() {
        timer -= 1
        cdLabel.text = "\(timer)s"
        if timer <= 0 {
            clock?.invalidate()
            onCountdownEnd?()
            self.removeFromSuperview()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func startCounting() {
        clock = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(KDChatNotraceCDView.countdown), userInfo: nil, repeats: true)
        cdLabel.text = "\(timer)s"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
