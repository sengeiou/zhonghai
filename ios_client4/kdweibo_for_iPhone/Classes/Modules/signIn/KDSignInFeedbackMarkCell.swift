//
//  KDSignInFeedbackMarkCell.swift
//  kdweibo
//
//  Created by 张培增 on 2017/3/22.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

@objc protocol KDSignInFeedbackMarkCellDelegate {
    func changeFeedbackMark(_ content: String?)
}

class KDSignInFeedbackMarkCell: KDTableViewCell {
    
    var delegate: KDSignInFeedbackMarkCellDelegate?
    
    var markArray: NSArray = [] {
        didSet {
            self.markCollectionView.reloadData()
        }
    }

    lazy var flowLayout: KDCollectionViewLeftAlignedLayout = {
        return $0
    }(KDCollectionViewLeftAlignedLayout())
    
    lazy var markCollectionView: UICollectionView = {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = UIColor.white
        $0.isScrollEnabled = false
        $0.register(KDSignInFeedbackMarkItem.self, forCellWithReuseIdentifier: "FeedbackMarkItem")
        return $0
    }(UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout))
    
    // MARK: - setupView -
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(markCollectionView)
        kd_setupVFL([
            "markCollectionView" : markCollectionView
            ], constraints: [
                "H:|-12-[markCollectionView]-12-|",
                "V:|-20-[markCollectionView]-20-|"
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension KDSignInFeedbackMarkCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return markArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedbackMarkItem", for: indexPath) as! KDSignInFeedbackMarkItem
        cell.model = markArray.safeObjectAtIndex(indexPath.row) as? KDSignInFeedbackMarkItemModel
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = markArray.safeObjectAtIndex(indexPath.row) as? KDSignInFeedbackMarkItemModel {
            delegate?.changeFeedbackMark(model.mark)
        }
    }
    
}

extension KDSignInFeedbackMarkCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let model = markArray.safeObjectAtIndex(indexPath.row) as? KDSignInFeedbackMarkItemModel {
            return CGSize(width: model.markWidth + 2 * NSNumber.kdDistance1(), height: FS5!.lineHeight + NSNumber.kdDistance1())
        }
        else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return NSNumber.kdDistance1()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return NSNumber.kdDistance1()
    }
    
}
