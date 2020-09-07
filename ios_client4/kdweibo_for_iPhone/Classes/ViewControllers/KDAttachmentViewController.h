//
//  KDAttachmentViewController.h
//  kdweibo
//
//  Created by Tan yingqi on 7/27/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface KDAttachmentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSArray *dataSource_;
    id attachmentSourceObj_;
}

- (id)initWithSource:(id)source;
@end
