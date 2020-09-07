//
//  KDAllDownloadedViewController.h
//  kdweibo
//
//  Created by Tan yingqi on 8/3/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDDownload.h"
#import "KDAttachmentMenuCell.h"

@interface KDAllDownloadedViewController : UIViewController <KDAttachmentMenuCellDelegate> {
 @private    
    NSMutableArray *dataSource_;
    NSInteger insertRow_;
    KDAttachmentMenuCell *menuCell_;
}
@end
