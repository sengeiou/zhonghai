//
//  KDTrendEditorViewController.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-8-1.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDSearchViewControllerNew.h"
#import "KDRequestWrapper.h"
#import "KDSearchBar.h"


@protocol KDTrendEditorViewControllerDelegate;
@class KDActivityIndicatorView;

@interface KDTrendEditorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, 
KDSearchViewControllerNewDelegate, KDRequestWrapperDelegate, KDSearchBarDelegate> {
 @private
//    id<KDTrendEditorViewControllerDelegate> delegate_;
    
    NSArray *displayTopics_;
    NSArray *topics_;
    NSArray *topicsIndex_; // for search
    
    UITableView *tableView_;
    
    KDActivityIndicatorView *activityView_;
    UIButton *searchButton_; // weak reference
    
    struct {
        unsigned int initialized:1;
        unsigned int hasCustomTopic:1;
    }viewControllerFlags_;
}

@property(nonatomic, assign) id<KDTrendEditorViewControllerDelegate> delegate;

@end

@protocol KDTrendEditorViewControllerDelegate <NSObject>
@optional

- (void)trendEditorViewController:(KDTrendEditorViewController *)tevc didPickTopicText:(NSString *)topicText;

@end
