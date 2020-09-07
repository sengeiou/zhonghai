//
//  KDDownloadCell.h
//  kdweibo
//
//  Created by Tan yingqi on 7/27/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDDownload.h"

@interface KDDownloadCell : UITableViewCell {
 @private    
    KDDownload *download_;

    UIImageView *kindImageView_;
    UILabel *filenameLabel_;
    UILabel *sizeLabel_;
    UIImageView *downloadedStateImageView_;
    UIImageView *cellAccessoryImageView_;
    
    BOOL _isShowAccessory;
}

@property (nonatomic, assign) BOOL isShowAccessory;
@property (nonatomic, readonly) UIImageView *cellAccessoryImageView;
@property(nonatomic, retain) KDDownload *download;

- (void)hideStateIndicator;
- (void)showStateIndicator;

+ (CGFloat)downloadCellHeight;

@end
