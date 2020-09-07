//
//  KDFileSearchCell.m
//  kdweibo
//
//  Created by Gil on 15/1/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDFileSearchCell.h"
#import "RecordDataModel.h"
#import "XTImageUtil.h"
#import "XTFileUtils.h"
#import "RTLabel.h"
#import "ContactUtils.h"
#import "PersonDataModel.h"
#import "KDPersonCache.h"

@interface KDFileSearchCell ()
@property (nonatomic, strong) UIImageView *separateLineImageView;
@property (nonatomic, strong) UIImageView *thumbnailPic;
@property (nonatomic, strong) RTLabel *fileName;
@property (nonatomic, strong) UILabel *fileSize;
@property (nonatomic, strong) UILabel *createTime;
@property (nonatomic, strong) UILabel *ownerName;
@end

@implementation KDFileSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.thumbnailPic = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.thumbnailPic];
        
        self.fileName = [[RTLabel alloc] initWithFrame:CGRectZero];
        self.fileName.textColor = FC1;
        self.fileName.backgroundColor = [UIColor clearColor];
        self.fileName.font = FS4;
        [self.contentView addSubview:self.fileName];
        
        self.createTime = [[UILabel alloc] initWithFrame:CGRectZero];
        self.createTime.textColor = FC2;
        self.createTime.backgroundColor = [UIColor clearColor];
        self.createTime.font = FS6;
        [self.contentView addSubview:self.createTime];
        
        self.fileSize = [[UILabel alloc] initWithFrame:CGRectZero];
        self.fileSize.textColor = FC2;
        self.fileSize.backgroundColor = [UIColor clearColor];
        self.fileSize.font = FS6;
        [self.contentView addSubview:self.fileSize];
        
        self.ownerName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.ownerName.textColor = FC2;
        self.ownerName.backgroundColor = [UIColor clearColor];
        self.ownerName.font = FS6;
        [self.contentView addSubview:self.ownerName];
        
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        self.separatorLineInset = UIEdgeInsetsMake(0, 68, 0, 0);
    }
    
    return self;
}

- (void)setFile:(MessageFileDataModel *)file {
    if (_file != file) {
        _file = file;
        
        //异步获取文件拥有者
        
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            PersonSimpleDataModel *fromUser = [[KDPersonCache sharedPersonCache] personForKey:weakSelf.file.wbUserId];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(fromUser)
                {
                    weakSelf.ownerName.text = fromUser.personName;
                }else
                {
                    weakSelf.ownerName.text = @"";
                }
                [weakSelf setNeedsLayout];
            });
        });
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIImage *image = [UIImage imageNamed:[XTFileUtils thumbnailImageWithExt:self.file.ext]];
    self.thumbnailPic.image = image;
    self.thumbnailPic.frame = CGRectMake([NSNumber kdDistance1], (CGRectGetHeight(self.contentView.frame) - 44.0) / 2, 44.0, 44.0);
    
    CGFloat height = 20;
    if (isAboveiOS9) {
        height = 24.0;
    }
    CGRect frame = self.thumbnailPic.frame;
    self.fileName.text = self.file.highlightName.length > 0 ? self.file.highlightName : self.file.name;
    frame.origin.x = CGRectGetMaxX(frame) + [NSNumber kdDistance1];
    frame.size.width = ScreenFullWidth - CGRectGetMinX(frame) - [NSNumber kdDistance1];
    frame.size.height = height;
    self.fileName.frame = frame;
    
    //创建时间
    self.createTime.text = [ContactUtils xtDateFormatter:self.file.fileSendTime];
    [self.createTime sizeToFit];
    self.createTime.frame = CGRectMake(CGRectGetMinX(self.fileName.frame), CGRectGetMaxY(self.thumbnailPic.frame) - 16.0, CGRectGetWidth(self.createTime.frame), 16.0);
    self.createTime.textAlignment = NSTextAlignmentCenter;
    
    NSString *fs = [XTFileUtils fileSize:self.file.size];
    self.fileSize.text = fs;
    [self.fileSize sizeToFit];
    self.fileSize.frame = CGRectMake(CGRectGetMaxX(self.createTime.frame) + [NSNumber kdDistance1], CGRectGetMaxY(self.thumbnailPic.frame) - 16.0, CGRectGetWidth(self.fileSize.frame), 16.0);
    self.fileSize.textAlignment = NSTextAlignmentCenter;
    
    //文件创建者
    if (self.ownerName.text.length > 0)
    {
        [self.ownerName sizeToFit];
        self.ownerName.frame = CGRectMake(CGRectGetMaxX(self.fileSize.frame) + [NSNumber kdDistance1], CGRectGetMaxY(self.thumbnailPic.frame) - 16.0, CGRectGetWidth(self.ownerName.frame), 16.0);
        self.ownerName.textAlignment = NSTextAlignmentCenter;
    }
}

@end
