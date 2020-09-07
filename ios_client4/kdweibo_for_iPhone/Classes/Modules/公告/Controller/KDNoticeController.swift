//
//  KDNoticePopup.swift
//  kdweibo
//
//  Created by Darren Zheng on 2017/2/10.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

import UIKit

@objc protocol KDNoticeControllerDataSource {
    
    // 页面所在导航栏
    var noticeControllerNavigationController: UINavigationController? { get }
    // 组id
    var noticeControllerGroupId: String? { get }
    // 是否是组管理员
    var noticeControllerIsAdmin: Bool { get }
    // 是否有新公告通知
    var noticeControllerHasNewNotice: Bool { get }
    
}

@objc protocol KDNoticeControllerDelegate: KDNoticeBoxVCDelegate {}

class KDNoticeController: NSObject {
    
    weak var dataSource: KDNoticeControllerDataSource?
    weak var delegate: KDNoticeControllerDelegate?
    
    lazy var popup: KDNoticePopupVC = {
        $0.delegate = self
        return $0
    }(KDNoticePopupVC())
    
    lazy var box: KDNoticeBoxVC = {
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(KDNoticeBoxVC())
    
    var noticeModels = [KDNoticeModel]()
    var noticeListVC: KDNoticeListVC?
    
    enum LatestNoticeModelState {
        // 没公告
        case empty(isAdmin: Bool)
        // 有新公告
        case some(latestNoticeModel: KDNoticeModel?)
    }
    var latestNoticeModelState: LatestNoticeModelState? // nil: 还不知有没有新公告
    
}


// MARK: - Popup -

extension KDNoticeController: KDNoticePopupVCDelegate {
    
    var isPopupShowing: Bool {
        return popup.isPopupShowing
    }
    
    func showPopup() {
        popup.showPopup()
    }
    
    func noticePopupWillShow(_ popupVC: KDNoticePopupVC) {
        
//        if let groupId = dataSource?.noticeControllerGroupId {
//            
//            guard let serverModel = queryNoticeWithGroupId(groupId)?.serverModel
//                else { return }
//            if self.delegate != nil {
//                let model = KDNoticeModel()
//                model.serverModel = serverModel
//                self.latestNoticeModelState = LatestNoticeModelState.Some(latestNoticeModel: model)
//                self.popup.showPopup(model)
//                self.dataSource?.noticeControllerNavigationController?.topViewController?.view.endEditing(true)
//            }
//            
//        }
        
        fetchLatestNotice(groupId: dataSource?.noticeControllerGroupId, completion: { serverModel in
            guard let serverModel = serverModel
                else { return }
            if self.delegate != nil {
                let model = KDNoticeModel()
                model.serverModel = serverModel
                self.latestNoticeModelState = LatestNoticeModelState.some(latestNoticeModel: model)
                self.popup.showPopup(model)
                self.dataSource?.noticeControllerNavigationController?.topViewController?.view.endEditing(true)
            }
        })
        
    }
    
    func hidePopup() {
        popup.hidePopup()
    }
    
    func popupViewMoreButtonPressed(_ popupView: KDNoticePopupView) {
        toListVC()
        hidePopup()
//        KDEventAnalysis.event(groupnotice_notice_more)
    }
    
    func popupViewConfirmButtonPressed(_ popupView: KDNoticePopupView) {
        hidePopup()
//        KDEventAnalysis.event(groupnotice_notice_close)
    }
    
}


// MARK: - Box -

extension KDNoticeController: KDNoticeBoxVCDataSource, KDNoticeBoxVCDelegate {
    
    var noticeBoxViewMode: KDNoticeBoxMode {
        if let latestNoticeModelState = latestNoticeModelState {
            switch latestNoticeModelState {
            case .empty(let isAdmin):
                return .empty(isAdmin: isAdmin)
            case .some(let latestNoticeModel):
                return .normal(dataSource: latestNoticeModel)
            }
        } else {
            return .loading
        }
    }
    
    func noticeBoxVCBoxWillShow(_ noticeBoxVC: KDNoticeBoxVC) {
        // 改成从数据库拿
//        self.latestNoticeModelState = nil
//        if let groupId = dataSource?.noticeControllerGroupId {
//
//            guard let dataSource = self.dataSource else { return }
//            
//            guard let serverModel = queryNoticeWithGroupId(groupId)?.serverModel else {
//                self.latestNoticeModelState = LatestNoticeModelState.Empty(isAdmin: dataSource.noticeControllerIsAdmin)
//                self.box.dataSource = self
//                return
//            }
//            
//            let model = KDNoticeModel()
//            model.serverModel = serverModel
//            self.latestNoticeModelState = LatestNoticeModelState.Some(latestNoticeModel: model)
//            self.box.dataSource = self
//        }
//        box.dataSource = self
        
        self.latestNoticeModelState = nil
        fetchLatestNotice(groupId: dataSource?.noticeControllerGroupId, completion: { serverModel in
            
            guard let dataSource = self.dataSource else { return }
            
            guard let serverModel = serverModel else {
                self.latestNoticeModelState = LatestNoticeModelState.empty(isAdmin: dataSource.noticeControllerIsAdmin)
                self.box.dataSource = self
                return
            }
            
            let model = KDNoticeModel()
            model.serverModel = serverModel
            self.latestNoticeModelState = LatestNoticeModelState.some(latestNoticeModel: model)
            self.box.dataSource = self
        })
        box.dataSource = self
        
    }
    
    func noticeBoxVCBoxDidShow(_ noticeBoxVC: KDNoticeBoxVC) {
        self.delegate?.noticeBoxVCBoxDidShow(noticeBoxVC)
    }
    
    func noticeBoxVCBoxDidHide(_ noticeBoxVC: KDNoticeBoxVC) {
        self.delegate?.noticeBoxVCBoxDidHide(noticeBoxVC)
    }
    
    var isBoxShowing: Bool {
        return box.isBoxShowing
    }
    
    func addBoxInView(_ view: UIView) {
        box.addBoxInView(view)
    }
    
    func removeBox() {
        box.removeBox()
    }
    
    func showBox() {
        box.showBox()
    }
    
    func hideBox(animated: Bool) {
        box.hideBox(animated: animated)
    }
    
    func boxViewCreateButtonPressed(_ boxView: KDNoticeBoxView) {
//        KDEventAnalysis.event(session_groupnotice_set)
        toCreateVC()
        hideBox(animated: true)
    }
    
    func boxViewPressed(_ boxView: KDNoticeBoxView) {
        if let latestNoticeModelState = latestNoticeModelState {
            if case let LatestNoticeModelState.some(latestNoticeModel) = latestNoticeModelState {
                toDetailVC(noticeDetailVCDataSource: latestNoticeModel)
                hideBox(animated: true)
//                KDEventAnalysis.event(session_groupnotice_detail)
            }
        }
    }
    
}


// MARK: - List -

extension KDNoticeController: KDNoticeListVCDataSource, KDNoticeListVCDelegate {
    
    func noticeListVCOnViewDidLoad(_ noticeListVC: KDNoticeListVC) {
        self.noticeModels.removeAll()
        noticeListVC.dataSource = self
        
    }
    
    var noticeListVCMode: KDNoticeListMode {
        if noticeModels.count > 0 {
            if let dataSource = dataSource {
                return .list(isAdmin: dataSource.noticeControllerIsAdmin, data: noticeModels)
            } else {
                return .list(isAdmin: false, data: noticeModels)
            }
        } else {
            if let dataSource = dataSource {
                return .empty(isAdmin: dataSource.noticeControllerIsAdmin)
            } else {
                return .empty(isAdmin: false)
            }
        }
    }
    
    func noticeListVCFetchNew(_ noticeListVC: KDNoticeListVC) {
        self.noticeListVC = noticeListVC
        print(dataSource?.noticeControllerGroupId)
        fetchNoticeList(groupId: dataSource?.noticeControllerGroupId, noticeId: "", count: "10", completion: { serverModels in
            noticeListVC.headerEndRefreshing()
            guard let serverModels = serverModels
                else { return }
            self.noticeModels.removeAll()
            if serverModels.count > 0 {
                serverModels.forEach {
                    let model = KDNoticeModel()
                    model.serverModel = $0
                    self.noticeModels += [model]
                }
                self.noticeModels.sort{ $0.serverModel.createTime > $1.serverModel.createTime }
            }
            noticeListVC.dataSource = self
        })
        
    }
    
    func noticeListVCFetchOld(_ noticeListVC: KDNoticeListVC) {
        self.noticeListVC = noticeListVC
        if let lastNoticeId = noticeModels.last?.serverModel.noticeId {
            fetchNoticeList(groupId: dataSource?.noticeControllerGroupId, noticeId: lastNoticeId, count: "10", completion: { serverModels in
                noticeListVC.footerEndRefreshing()
                guard let serverModels = serverModels
                    else { return }
                if serverModels.count == 0 {
                    noticeListVC.removeFooter()
                }
                
                if serverModels.count > 0 {
                    serverModels.forEach {
                        let model = KDNoticeModel()
                        model.serverModel = $0
                        self.noticeModels += [model]
                    }
                    self.noticeModels.sort{ $0.serverModel.createTime > $1.serverModel.createTime }
                    noticeListVC.dataSource = self
                }
            })
        }
        
    }
    
    func noticeListVCCreateButtonPressed(_ noticeListVC: KDNoticeListVC) {
        self.noticeListVC = noticeListVC
        toCreateVC()
    }
    
//<<<<<<< HEAD
//    
//    func noticeListVC(noticeListVC: KDNoticeListVC, didPressIndex: Int) {
//=======
    func noticeListVC(_ noticeListVC: KDNoticeListVC, didPressIndex: Int) {
//        KDEventAnalysis.event(groupnotice_detail)
        if didPressIndex < noticeModels.count {
            let model = noticeModels[didPressIndex]
            toDetailVC(noticeDetailVCDataSource: model)
        }
    }
    
}


// MARK: - Navigation -

extension KDNoticeController {
    
    func toCreateVC() {
        dataSource?.noticeControllerNavigationController?.pushViewController({
            $0.delegate = self
            return $0
            }(KDNoticeCreateVC()), animated: true)
    }
    
    func toListVC() {
        dataSource?.noticeControllerNavigationController?.pushViewController({
            $0.delegate = self
            $0.dataSource = self
            return $0
            }(KDNoticeListVC()), animated: true)
    }
    
    func toDetailVC(noticeDetailVCDataSource: KDNoticeDetailVCDataSource?) {
        dataSource?.noticeControllerNavigationController?.pushViewController({
            $0.delegate = self
            $0.isAdminDataSource = self
            $0.dataSource = noticeDetailVCDataSource
            return $0
            }(KDNoticeDetailVC()), animated: true)
    }
    
}


// MARK: - Server -

extension KDNoticeController {
    
    func fetchNoticeList(groupId: String?, noticeId: String?, count: String?, completion: @escaping ([KDNoticeServerModel]?) -> Void) {
        KDOpenAPIClientWrapper.sharedInstance.listNotice(groupId, noticeId: noticeId, count: count, completion: { (succ, errorMsg, data) in
            if (succ) {
                let data = data as? [AnyObject]
                var models = [KDNoticeServerModel]()
                for dict in data! {
                    if let dict = dict as? [String: AnyObject] {
                        models += [KDNoticeServerModel(dict: dict)]
                    }
                }
                
                completion(models)
            } else {
                completion(nil)
            }
            
        })
        
        
//        KDNoticeListRequest(groupId: groupId, noticeId: noticeId, count: count).startCompletionBlockWithSuccess( { (request: KDRequest?) -> Void in
//            completion(request?.resultModels as? [KDNoticeServerModel])
//            }, failure: { request in
//                completion(nil)
//        })
    }
    
    func fetchLatestNotice(groupId: String?, completion: @escaping ((KDNoticeServerModel?) -> Void)) {
        KDOpenAPIClientWrapper.sharedInstance.newestNotice(groupId, completion: { (succ, errorMsg, data) in
            if (succ) {
                if (data != nil) {
                    let serverModel = KDNoticeServerModel(dict: data as? [String: AnyObject])
                    completion(serverModel)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
            
        })
        
//        KDNoticeNewestRequest(groupId: groupId).startCompletionBlockWithSuccess( { (request: KDRequest?) -> Void in
//            completion(request?.resultModel as? KDNoticeServerModel)
//            }, failure: { request in
//                completion(nil)
//                
//        })
    }
    
    func createNotice(groupId: String?, title: String?, content: String?, completion: @escaping (Bool) -> Void) {
        
        KDOpenAPIClientWrapper.sharedInstance.createNotice(groupId, title: title, content: content, completion: { (succ, errorMsg, data) in
            if (succ) {
                completion(true)
            } else {
                completion(false)
            }
            
        })
        
//        KDNoticeCreateRequest(groupId: groupId, title: title, content: content).startCompletionBlockWithSuccess( { (request: KDRequest?) -> Void in
//            completion(true)
//            }, failure: { request in
//                completion(false)
//        })
    }
    
    func deleteNotice(noticeId: String?, completion: @escaping (Bool) -> Void) {
        
        KDOpenAPIClientWrapper.sharedInstance.deleteNotice(noticeId, completion: { (succ, errorMsg, data) in
            if (succ) {
                completion(true)
            } else {
                completion(false)
            }
            
        })
        
        
//        KDNoticeDeleteRequest(noticeId: noticeId).startCompletionBlockWithSuccess( { (request: KDRequest?) -> Void in
//            completion(true)
//            }, failure: { request in
//                completion(false)
//        })
    }
    
}


// MARK: - CreateVC -

extension KDNoticeController: KDNoticeCreateVCDelegate {
    
    func noticeCreateVCPublishButtonPressed(_ noticeCreateVC: KDNoticeCreateVC) {
        KDPopup.showHUD()
        noticeCreateVC.view.endEditing(true)
//        KDEventAnalysis.event(groupnotice_publish)
        createNotice(groupId: dataSource?.noticeControllerGroupId, title: noticeCreateVC.titleTextFiled.text, content: noticeCreateVC.contentTextView.text) { succ in
            if succ {
                KDPopup.showHUDSuccess(ASLocalizedString("Notice_Create_Succ"))
                delay(1, {
                    noticeCreateVC.navigationController?.popViewController(animated: true)
                    self.noticeListVC?.headerBeginRefreshing()
                    if self.isBoxShowing {
                        self.showBox()
                    }
                })
            } else {
                KDPopup.showHUDToast(ASLocalizedString("Notice_Create_Succ"))
            }
        }
    }
    
}


// MARK: - Detail VC -

extension KDNoticeController: KDNoticeDetailVCDelegate, KDNoticeDetailVCIsAdminDataSource {
    
    func noticeDetailVCDeleteButtonPressed(_ noticeDetailVC: KDNoticeDetailVC) {
        KDPopup.showAlert(title: ASLocalizedString("Notice_Delete_Confirm"), message: nil, buttonTitles: [ASLocalizedString("Global_Cancel"), ASLocalizedString("Mark_delete")], destructiveIndex: 1) { (index) in
            if index == 1 {
//                KDEventAnalysis.event(groupnotice_delete)
                if let noticeId = noticeDetailVC.dataSource?.noticeDetailVCNoticeId {
                    self.deleteNotice(noticeId: noticeId, completion: { succ in
                        if succ {
                            KDPopup.showHUDSuccess(ASLocalizedString("XTChatDetailViewController_Delete_Success"))
                            delay(1, {
                                noticeDetailVC.navigationController?.popViewController(animated: true)
                                self.noticeListVC?.headerBeginRefreshing()
                                if self.isBoxShowing {
                                    self.showBox()
                                }
                            })
                        } else {
                            KDPopup.showHUDToast(ASLocalizedString("XTChatDetailViewController_Delete_Fail"))
                        }
                    })
                }
            }
        }
    }
    
    var noticeDetailVCIsAdmin: Bool {
        if let dataSource = dataSource {
            return dataSource.noticeControllerIsAdmin
        } else {
            return false
        }
    }
    
}

extension KDNoticeController {
    
    func queryNoticeWithGroupId(_ groupId: String?) -> KDNoticeModel? {
//        guard let groupId = groupId else {
//            return nil
//        }
//        return XTDataBaseDao.sharedDatabaseDaoInstance().queryNoticeWithGroupId(groupId)?.noticeModel
        
        return nil;
    }
    
}

