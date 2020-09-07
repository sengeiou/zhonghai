//
//  KDChatCombineCell.swift
//  kdweibo
//
//  Created by Darren Zheng on 7/23/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//

class KDChatCombineCell: KDChatDialogBaseCell, KDChatCombineDetailVCDataSource {
    
    // MARK: 标题
    lazy var combineTitleLabel: UILabel = {
        let label = UILabel()
        label.font = FS3
        label.textColor = FC1
        return label
    }()
    
    // MARK: 内容
    lazy var combineContentLabel0: UILabel = {
        let label = UILabel()
        label.font = FS6
        label.textColor = FC2
        label.numberOfLines = 4
        return label
    }()
    
    // MARK: 内容
    lazy var combineContentLabel1: UILabel = {
        let label = UILabel()
        label.font = FS6
        label.textColor = FC2
        label.numberOfLines = 4
        return label
    }()
    
    // MARK: 内容
    lazy var combineContentLabel2: UILabel = {
        let label = UILabel()
        label.font = FS6
        label.textColor = FC2
        label.numberOfLines = 4
        return label
    }()
    
    // MARK: 内容
    lazy var combineContentLabel3: UILabel = {
        let label = UILabel()
        label.font = FS6
        label.textColor = FC2
        return label
    }()

    // MARK: -------- Inheritance Chain --------
    
    override func updateCell(_ chatVC: XTChatViewController, tableView: UITableView, dataInternal: BubbleDataInternal) {
        super.updateCell(chatVC, tableView: tableView, dataInternal: dataInternal)
        updateBubbleImage(bubbleImageView, direction: dataInternal.record.msgDirection, blueBorder: true)
        
        for v in bubbleImageView.subviews {
            if v.tag == 1210 {
                v.removeFromSuperview()
            }
        }
        if let model = dataInternal.record.param?.paramObject as? MessageCombineForwardDataModel {
            combineTitleLabel.text = model.title
            var array = model.content.components(separatedBy: "\n")
            array = array.filter { $0.characters.count != 0 }
            if array.count > 0 {
                for (index, contentPerLine) in array.enumerated() {
                    let label = UILabel()
                    label.font = FS6
                    label.textColor = FC2
                    label.tag = 1210
                    bubbleImageView.addSubview(label)
                    label.mas_makeConstraints { make in
                        var offset = CGFloat(label.font.lineHeight) * CGFloat(index) + CGFloat(3) * CGFloat(index)
                        offset += 10
                        make?.top.equalTo()(self.combineTitleLabel.bottom)?.with().offset()(offset)
                        make?.left.equalTo()(label.superview!.left)?.with().offset()(12)
                        make?.right.equalTo()(label.superview!.right)?.with().offset()(-12)
                        return()
                    }
                    label.text = contentPerLine
                }
                
                let offSet = -(CGFloat((FS6?.lineHeight)!) * CGFloat(array.count) + CGFloat(3) * CGFloat(array.count - 1) + 10 + 12)
                combineTitleLabel.mas_updateConstraints{ make in
                    make?.bottom.equalTo()(self.combineTitleLabel.superview!.bottom)?.with().offset()(offSet)
                }
                
            }

        }
        
        unowned let chatVC = chatVC
        onTap = { gestureRecognizer in
            //KDEventAnalysis.event(event_merge_chatlog_open)
            let detailVC = KDChatCombineDetailVC()
            detailVC.record = dataInternal.record
            detailVC.dataSource = self
            chatVC.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func chatViewController() -> XTChatViewController? {
        return chatVC
    }

    
    override func setupCell() {
        super.setupCell()
        
        bubbleImageView.addSubview(combineTitleLabel)
        combineTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(self.combineTitleLabel.superview!.top)?.with().offset()(12)
            make?.left.equalTo()(self.combineTitleLabel.superview!.left)?.with().offset()(12)
            make?.right.equalTo()(self.combineTitleLabel.superview!.right)?.with().offset()(-12)
            make?.height.mas_equalTo()(self.combineTitleLabel.font.lineHeight)
            make?.width.mas_equalTo()(KDChatConstants.bubbleContentLabelMaxWidth)
            make?.bottom.equalTo()(self.combineTitleLabel.superview!.bottom)?.with().offset()(-12)

            return()
        }
        
    }
    

}
