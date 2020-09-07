//
//  KDVoteViewController.h
//  kdweibo
//
//  Created by Guohuan Xu on 3/30/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDVoteView.h"
#import "MBProgressHUD.h"
#import "KDRequestWrapper.h"

@interface KDVoteViewController : UIViewController<KDVoteViewDelegate, KDRequestWrapperDelegate>

@property(retain,nonatomic) NSString *voteId;

@end
