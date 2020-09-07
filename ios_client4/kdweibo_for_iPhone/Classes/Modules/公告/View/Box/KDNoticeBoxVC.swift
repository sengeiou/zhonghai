//
//  KDNoticeBoxVC.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/20.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

protocol KDNoticeBoxVCDataSource: class, KDNoticeBoxViewDataSource {}

@objc protocol KDNoticeBoxVCDelegate: KDNoticeBoxViewDelegate {
    @objc optional func noticeBoxVCBoxWillShow(_ noticeBoxVC: KDNoticeBoxVC)
    func noticeBoxVCBoxDidShow(_ noticeBoxVC: KDNoticeBoxVC)
    func noticeBoxVCBoxDidHide(_ noticeBoxVC: KDNoticeBoxVC)
}

class KDNoticeBoxVC: NSObject {
    
    weak var dataSource: KDNoticeBoxVCDataSource? {
        didSet {
            box.dataSource = dataSource
        }
    }
    weak var delegate: KDNoticeBoxVCDelegate?
    
    lazy var box: KDNoticeBoxView = {
        $0.frame = self.boxHidingFrame
        $0.isHidden = true
        $0.delegate = self.delegate
        $0.dataSource = self.dataSource
        return $0
    }(KDNoticeBoxView())
    
    var isBoxShowing: Bool = false
    
    var boxHidingFrame: CGRect {
        return CGRect(x: 0, y: -109, width: KDFrame.screenWidth(), height: 109)
    }
    
    var boxShowingFrame: CGRect {
        return CGRect(x: 0, y: 60, width: KDFrame.screenWidth(), height: 109)
    }
    
    func addBoxInView(_ view: UIView) {
        view.addSubview(box)
    }
    
    func removeBox() {
        self.box.removeFromSuperview()
    }
    
    func showBox() {
        self.delegate?.noticeBoxVCBoxWillShow?(self)
        isBoxShowing = true
        box.isHidden = false
        box.frame = boxHidingFrame
        UIView.animate(withDuration: 0.25, animations: {
            self.box.frame = self.boxShowingFrame
            self.delegate?.noticeBoxVCBoxDidShow(self)
        }) 
    }
    
    func hideBox(animated: Bool) {
        self.isBoxShowing = false
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.box.frame = self.boxHidingFrame
                }, completion: { (complete) in
                    self.box.isHidden = true
                    self.delegate?.noticeBoxVCBoxDidHide(self)
            })
        } else {
            self.box.frame = self.boxHidingFrame
            self.box.isHidden = true
            self.delegate?.noticeBoxVCBoxDidHide(self)
        }
    }
    
}
