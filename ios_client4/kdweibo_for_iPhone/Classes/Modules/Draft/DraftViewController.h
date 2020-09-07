//
//  DraftViewController.h
//  TwitterFon
//
//  Created by kingdee on 11-6-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDDraft;

@protocol KDDraftViewControllerDelegate;

@interface DraftViewController : UIViewController<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>{
@private
    NSMutableArray *drafts_;
    NSUInteger selectedIndex_;
    
    struct {
        unsigned int viewDidDisappear:1;
        
    }draftViewControllerFlags_;
}

- (void) reloadDB;
- (void) reloadData;

- (void) didSaveDraftToDatabase:(KDDraft *)draft;
- (void) didPostDraft:(KDDraft *)draft succeed:(BOOL)succeed;
- (void) draftIsSending:(KDDraft *)draft;

@end

@protocol KDDraftViewControllerDelegate <NSObject>
@optional

- (void) draftViewController:(DraftViewController *)dvc didPickDraft:(KDDraft *)draft;

@end
