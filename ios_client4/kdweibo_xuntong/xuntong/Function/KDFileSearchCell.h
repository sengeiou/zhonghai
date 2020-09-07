//
//  KDFileSearchCell.h
//  kdweibo
//
//  Created by Gil on 15/1/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"

@class MessageFileDataModel;
@class RTLabel;
@interface KDFileSearchCell : KDTableViewCell

@property (nonatomic, strong) MessageFileDataModel *file;

@property (nonatomic, strong, readonly) UIImageView *thumbnailPic;
@property (nonatomic, strong, readonly) RTLabel *fileName;
@property (nonatomic, strong, readonly) UILabel *fileSize;
@property (nonatomic, strong, readonly) UILabel *createTime;
@property (nonatomic, strong, readonly) UILabel *ownerName;

@end
