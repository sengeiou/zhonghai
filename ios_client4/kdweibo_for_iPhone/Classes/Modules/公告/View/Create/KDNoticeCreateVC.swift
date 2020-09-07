//
//  KDNoticeCreateVC.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/14.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//


protocol KDNoticeCreateVCDelegate: class {
    func noticeCreateVCPublishButtonPressed(_ noticeCreateVC: KDNoticeCreateVC)
}

class KDNoticeCreateVC: UIViewController {
    
    weak var delegate: KDNoticeCreateVCDelegate?
    
    lazy var titleTextFiled: UITextField = {
        $0.placeholder = ASLocalizedString("Notice_Title")
        $0.font = FS3
        $0.textColor = FC1
        $0.backgroundColor = UIColor.white
        $0.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        return $0
    }(UITextField())
    
    lazy var contentTextView: SZTextView = {
        $0.placeholder = ASLocalizedString("Notice_Content")
        $0.font = FS3
        $0.textColor = FC1
        $0.tintColor = FC5
        $0.delegate = self
        return $0
    }(SZTextView())
    
    lazy var counterBackgroundView: UIView = {
        $0.backgroundColor = UIColor.white
        return $0
    }(UIView())
    
    lazy var counterLabel: UILabel = {
        $0.font = FS7
        $0.textColor =  FC2
        $0.text = "500"
        $0.backgroundColor = UIColor.white
        return $0
    }(UILabel())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ASLocalizedString("Notice_Edit")
        view.backgroundColor = UIColor.kdBackgroundColor1()
        self.automaticallyAdjustsScrollViewInsets = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: ASLocalizedString("Notice_Publish"), style: UIBarButtonItemStyle.done, target: self, action: #selector(KDNoticeCreateVC.publishButtonPressed))
        
        view.addSubviews([titleTextFiled, contentTextView, counterBackgroundView, counterLabel])
        kd_setupVFL(bindings,
                    metrics: metrics,
                    constraints: vfls,
                    delayInvoke: false)
        
        KDWeiboAppDelegate.getAppDelegate().window?.makeKeyAndVisible()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextFiled.becomeFirstResponder()
    }
    
    
    func publishButtonPressed() {
        
        guard let title = titleTextFiled.text, title.characters.count > 0 else {
            KDPopup.showHUDToast(ASLocalizedString("Notice_Input_Title"))
            titleTextFiled.becomeFirstResponder()
            return
        }
        
        guard title.characters.count >= 4 else {
            KDPopup.showHUDToast(ASLocalizedString("Notice_Title_Less"))
            titleTextFiled.becomeFirstResponder()
            return
        }
        
        guard title.characters.count <= 40 else {
            KDPopup.showHUDToast(ASLocalizedString("Notice_Title_More"))
            titleTextFiled.becomeFirstResponder()
            return
        }
        
        guard let content = contentTextView.text, content.characters.count > 0 else {
            KDPopup.showHUDToast(ASLocalizedString("Notice_Input_Content"))
            contentTextView.becomeFirstResponder()
            return
        }
        
        guard content.characters.count >= 15 else {
            KDPopup.showHUDToast(ASLocalizedString("Notice_Content_Less"))
            contentTextView.becomeFirstResponder()
            return
        }
        
        guard content.characters.count <= 500 else {
            KDPopup.showHUDToast(ASLocalizedString("Notice_Content_More"))
            contentTextView.becomeFirstResponder()
            return
        }
        
        delegate?.noticeCreateVCPublishButtonPressed(self)
        
    }
    
    
    lazy var bindings: [String: AnyObject] = {
        return [
            "titleTextFiled" : self.titleTextFiled,
            "contentTextView" : self.contentTextView,
            "counterLabel": self.counterLabel,
            "counterBackgroundView": self.counterBackgroundView,
            ]
    }()
    
    var metrics: [String: AnyObject] {
        return [
            :
        ]
    }
    
    let vfls: [String] = [
        "V:|-72-[titleTextFiled(44)]-8-[contentTextView(180)]",
        "H:|[titleTextFiled]|",
        "H:|[contentTextView]|",
        "H:|[counterBackgroundView]|",
        "V:[contentTextView][counterBackgroundView(40)]",
        "H:[counterLabel]-12-|",
        "V:[contentTextView]-12-[counterLabel]",
        ]
    
}

// MARK: - TextView
extension KDNoticeCreateVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let count = 500 - textView.text.characters.count
        counterLabel.textColor = count < 0 ? FC4 : FC2
        counterLabel.text = "\(count)"
    }
    
}

