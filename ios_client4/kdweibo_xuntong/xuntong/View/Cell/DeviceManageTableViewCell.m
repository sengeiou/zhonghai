//
//  DeviceManageTableViewCell.m
//  kdweibo
//
//  Created by kingdee on 2019/5/21.
//  Copyright © 2019 www.kingdee.com. All rights reserved.
//

#import "DeviceManageTableViewCell.h"

@interface DeviceManageTableViewCell()
@property (nonatomic,strong) UIImageView *thumbnailPic;
@property (nonatomic,strong) UILabel *fileName;
@property (nonatomic,strong) UILabel *fileSize;
@property (nonatomic,strong) UILabel *createTime;

@property (nonatomic,strong) UILabel *updateTime;
@end
@implementation DeviceManageTableViewCell
@synthesize thumbnailPic,fileName,fileSize,createTime,updateTime;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor kdBackgroundColor2];
        self.contentView.backgroundColor = self.backgroundColor;
        
        CGFloat cellHeight = 68.0;
        
        thumbnailPic = [[UIImageView alloc] init];
        thumbnailPic.frame = CGRectMake(12.0, (cellHeight - 46.0)/2, 46.0, 46.0);
        
        [self.contentView addSubview:thumbnailPic];
        
        CGRect rect = thumbnailPic.frame;
        rect.origin.x = rect.origin.x + CGRectGetWidth(rect) + 10.0;
        rect.size.width = 320.0 - rect.origin.x - 15.0;
        rect.size.height = 26.0;
        fileName = [[UILabel alloc] initWithFrame:rect];
        fileName.textColor = FC1;
        fileName.backgroundColor = [UIColor clearColor];
        fileName.font = FS4;
        [self.contentView addSubview:fileName];
        
        rect = fileName.frame;
        rect.size.width -= 145.0;
        rect.origin.y = rect.origin.y + CGRectGetHeight(rect);
        rect.size.height = 20.0;
        createTime = [[UILabel alloc] initWithFrame:rect];
        createTime.textColor = FC1;
        createTime.backgroundColor = [UIColor clearColor];
        createTime.font = [UIFont systemFontOfSize:16.0];
        [createTime setAdjustsFontSizeToFitWidth:YES];
        [self.contentView addSubview:createTime];
        
        rect = createTime.frame;
        rect.origin.x = rect.origin.x + CGRectGetWidth(rect) + 10.0;
        rect.origin.y = 11+20;
        rect.size.height = 26.0;
        rect.size.width = 60.0;
        fileSize = [[UILabel alloc] initWithFrame:rect];
        fileSize.textAlignment = NSTextAlignmentLeft;
        fileSize.textColor = FC1;
        fileSize.backgroundColor = [UIColor clearColor];
        fileSize.font = [UIFont systemFontOfSize:14.0];
        fileSize.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:fileSize];
        
        
        rect = createTime.frame;
        rect.origin.x = rect.origin.x + CGRectGetWidth(rect) + 10.0;
        rect.origin.y = 11;
        rect.size.height = 46.0;
        rect.size.width = 320.0 - rect.origin.x ;
        updateTime = [[UILabel alloc] initWithFrame:rect];
        updateTime.textAlignment = NSTextAlignmentLeft;
        updateTime.textColor = FC1;
        updateTime.backgroundColor = [UIColor clearColor];
        updateTime.font = [UIFont systemFontOfSize:15.0];

        [self.contentView addSubview:updateTime];
        // _ownerName = [[UILabel alloc] initWithFrame:CGRectZero];
       // _ownerName.textAlignment = NSTextAlignmentLeft;
       // _ownerName.textColor = BOSCOLORWITHRGBA(0x808080, 1.0);
        //_ownerName.backgroundColor = [UIColor clearColor];
       // _ownerName.font = [UIFont systemFontOfSize:14.0];
       // [self.contentView addSubview:_ownerName];
        
        //底条
        //        separateLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0xDDDDDD, 1.0)]];
        //        separateLineImageView.frame = CGRectMake(.0, cellHeight - 0.5, 320.0, 0.5);
        //        [self.contentView addSubview:separateLineImageView];
        
        //选中效果
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xE5E5E5, 1.0);
        self.selectedBackgroundView = bgColorView;
    }
    
    return self;
}



- (void)setDeviceModel:(DeviceInfoModel *)deviceModel
{
    if (_deviceModel != deviceModel) {
        _deviceModel = deviceModel;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    
    CGRect thumbnailPicRect = thumbnailPic.frame;
    thumbnailPicRect.origin.x =  20.0;
    thumbnailPic.frame = thumbnailPicRect;
    
    CGRect fileNameRect = fileName.frame;
    fileNameRect.origin.x = thumbnailPicRect.origin.x + CGRectGetWidth(thumbnailPicRect) + 10.0;
    fileNameRect.size.width = CGRectGetWidth(self.bounds) - fileNameRect.origin.x - 15.0;
    fileName.frame = fileNameRect;
    
    CGFloat createWidth = CGRectGetWidth(fileNameRect);
    //if (_isPreview) {
        createWidth -= 145.0;
    //}
    
    CGRect createTimeRect = createTime.frame;
    createTimeRect.origin.x = fileNameRect.origin.x;
    createTimeRect.size.width = createWidth;
    createTime.frame = createTimeRect;
    
    if([_deviceModel.osVersion containsString:@"Android"]){
        thumbnailPic.image = [UIImage imageNamed:@"devi_android.png"];
        
    }else{
        thumbnailPic.image = [UIImage imageNamed:@"devi_ios.png"];
        
    }
    
   // if// (_file.fileExt && _file.fileExt.length>0 && [XTFileUtils isPhotoExt:_file.fileExt]) {
      //  NSString *url = [NSString stringWithFormat:@"%@%@%@%@", [[KDWeiboServicesContext defaultContext] serverBaseURL], @"/microblog/filesvr/", _file.fileId, @"?thumbnail"];
       // [thumbnailPic setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:[XTFileUtils thumbnailImageWithExt:_file.fileExt]]];
    //}else{
       // thumbnailPic.image = [UIImage imageNamed:[XTFileUtils thumbnailImageWithExt:_file.fileExt]];
   // }
    
    CGRect rect = fileSize.frame;
    rect.origin.x = CGRectGetMaxX(rect) +10.f;
    rect.size.width = CGRectGetWidth(self.bounds) - rect.origin.x - 15.f;
   // _ownerName.frame = rect;
    
    
    fileName.text = _deviceModel.brandName;
    updateTime.text =_deviceModel.lastUpdateTime;
    
        createTime.text     = _deviceModel.model;
    NSString *devicestr=[_deviceModel.deviceId lowercaseString];
    if([[[UIDevice uniqueDeviceIdentifier] lowercaseString] isEqualToString:devicestr]){
         fileSize.text       = @"当前设备";
        fileSize.hidden = NO;
        CGRect fileNameRect = updateTime.frame;
        fileNameRect.size.height = 26;
        fileNameRect.origin.y= 11;
        updateTime.frame = fileNameRect;
    }else{
        fileSize.hidden = YES;
    }
    
    
    
    
}

@end
