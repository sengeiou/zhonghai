//
//  KDHelpDetailView.swift
//  kdweibo
//
//  Created by 张培增 on 2017/4/11.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

final class KDHelpDetailCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        $0.textColor = FC6
        return $0
    }(UILabel())
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        
        contentView.addSubviews([titleLabel])
        kd_setupVFL([
            "titleLabel" : titleLabel
            ], constraints: [
                "H:|-12-[titleLabel]-12-|"
            ])
        titleLabel.kd_setCenterY()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

final class KDHelpDetailView: UIView {
    
    lazy var triangleImageView: UIImageView = {
        $0.image = UIImage(named: "message_bg_triangle")
        return $0
    }(UIImageView())
    
    lazy var helpView: UIView = {
        $0.backgroundColor = UIColor(rgb: 0x0C213F, alpha: 0.8)
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        return $0
    }(UIView())
    
    lazy var detailTableView: UITableView = {
        $0.isScrollEnabled = false
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.backgroundColor = UIColor.clear
        $0.register(KDHelpDetailCell.self, forCellReuseIdentifier: "HelpDetailCell")
        return $0
    }(UITableView(frame: CGRect.zero, style: .plain))
    
    var detailFont = FS7
    var helpViewWidth = 0
    var helpViewHeight = 0
    
    var detailArray = [[String]]() {
        didSet {
            var detailCount = 0
            for arr in detailArray {
                detailCount += arr.count
            }
            helpViewHeight = (detailCount * Int(ceil((detailFont?.lineHeight)!))) + 24
            if detailArray.count > 1 {
                helpViewHeight += (detailArray.count - 1) * 9
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        helpView.addSubviews([detailTableView])
        kd_setupVFL([
            "detailTableView" : detailTableView
            ], constraints: [
                "H:|[detailTableView]|",
                "V:|-12-[detailTableView]-12-|"
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hide()
    }
    
    // MARK: - show and hide method -
    func showAtOrigin(_ origin: CGPoint) {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        let helpViewLeft = (origin.x - CGFloat(helpViewWidth / 2)) > 12 ? (origin.x - CGFloat(helpViewWidth / 2)) : 12
        
        self.addSubviews([triangleImageView, helpView])
        kd_setupVFL([
            "triangleImageView" : triangleImageView,
            "helpView" : helpView
            ], metrics: [
                "triangleLeft" : origin.x - CGFloat(4) as AnyObject,
                "triangleTop" : origin.y as AnyObject,
                "helpViewWidth" : helpViewWidth as AnyObject,
                "helpViewHeight" : helpViewHeight as AnyObject,
                "helpViewLeft" : helpViewLeft as AnyObject
            ], constraints: [
                "H:|-triangleLeft-[triangleImageView(8)]",
                "H:|-helpViewLeft-[helpView(helpViewWidth)]",
                "V:|-triangleTop-[triangleImageView(4)][helpView(helpViewHeight)]"
            ], delayInvoke: false)
        
        keyWindow.addSubview(self)
        kd_setupVFL([
            "self" : self
            ], constraints: [
                "H:|[self]|",
                "V:|[self]|"
            ])
    }
    
    func hide() {
        triangleImageView.removeFromSuperview()
        helpView.removeFromSuperview()
        self.removeFromSuperview()
    }
}

extension KDHelpDetailView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailArray[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return detailFont!.lineHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 9
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = tableView.backgroundColor
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpDetailCell") as! KDHelpDetailCell
        cell.titleLabel.text = detailArray[indexPath.section][indexPath.row]
        cell.titleLabel.font = detailFont
        return cell
    }
    
}
