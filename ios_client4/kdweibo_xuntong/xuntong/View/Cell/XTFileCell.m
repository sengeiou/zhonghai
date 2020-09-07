//
//  XTFileCell.m
//  XT
//
//  Created by kingdee eas on 13-11-28.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTFileCell.h"
#import "XTRoundSelectStateView.h"
#import "FileModel.h"
#import "XTFileUtils.h"
#import "XTImageUtil.h"
#import "UIImage+XT.h"

@interface XTFileCell()
@property (nonatomic,strong) XTRoundSelectStateView *selectStateView;
@property (nonatomic,strong) UIImageView *separateLineImageView;
@property (nonatomic,strong) UIImageView *thumbnailPic;
@property (nonatomic,strong) UILabel *fileName;
@property (nonatomic,strong) UILabel *fileSize;
@property (nonatomic,strong) UILabel *createTime;
@property (nonatomic,strong) UILabel *ownerName;
@end

@implementation XTFileCell

@synthesize separateLineImageView,thumbnailPic,fileName,fileSize,createTime;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor kdBackgroundColor2];
        self.contentView.backgroundColor = self.backgroundColor;
        
        CGFloat cellHeight = 65.0;
        
        XTRoundSelectStateView *selectStateView = [[XTRoundSelectStateView alloc] initWithFrame:CGRectMake(15.0, (cellHeight - 20.0)/2, 20.0, 20.0)];
        self.selectStateView = selectStateView;
        [self.contentView addSubview:selectStateView];
        
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
        rect.size.width -= 115.0;
        rect.origin.y = rect.origin.y + CGRectGetHeight(rect);
        rect.size.height = 20.0;
        createTime = [[UILabel alloc] initWithFrame:rect];
        createTime.textColor = BOSCOLORWITHRGBA(0x808080, 1.0);
        createTime.backgroundColor = [UIColor clearColor];
        createTime.font = [UIFont systemFontOfSize:14.0];
        [createTime setAdjustsFontSizeToFitWidth:YES];
        [self.contentView addSubview:createTime];
        
        rect = createTime.frame;
        rect.origin.x = rect.origin.x + CGRectGetWidth(rect) + 10.0;
        rect.size.width = 40.0;
        fileSize = [[UILabel alloc] initWithFrame:rect];
        fileSize.textAlignment = NSTextAlignmentLeft;
        fileSize.textColor = BOSCOLORWITHRGBA(0x808080, 1.0);
        fileSize.backgroundColor = [UIColor clearColor];
        fileSize.font = [UIFont systemFontOfSize:14.0];
        fileSize.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:fileSize];
        
        _ownerName = [[UILabel alloc] initWithFrame:CGRectZero];
        _ownerName.textAlignment = NSTextAlignmentLeft;
        _ownerName.textColor = BOSCOLORWITHRGBA(0x808080, 1.0);
        _ownerName.backgroundColor = [UIColor clearColor];
        _ownerName.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:_ownerName];
        
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

- (void)setChecked:(BOOL)checked animated:(BOOL)animated
{
    _checked = checked;
    
    [self.selectStateView setSelected:checked animated:animated];
    
    [self setNeedsLayout];
}

- (void)setChecked:(BOOL)checked
{
    [self setChecked:checked animated:NO];
}

- (void)setIsPreview:(BOOL)isPreview
{
    if (_isPreview != isPreview) {
        _isPreview = isPreview;
    }
}

- (void)setFile:(DocumentFileModel *)file
{
    if (_file != file) {
        _file = file;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.selectStateView.hidden = _isPreview;
    
    CGRect thumbnailPicRect = thumbnailPic.frame;
    thumbnailPicRect.origin.x = _isPreview ? 12.0 : 50.0;
    thumbnailPic.frame = thumbnailPicRect;
    
    CGRect fileNameRect = fileName.frame;
    fileNameRect.origin.x = thumbnailPicRect.origin.x + CGRectGetWidth(thumbnailPicRect) + 10.0;
    fileNameRect.size.width = CGRectGetWidth(self.bounds) - fileNameRect.origin.x - 15.0;
    fileName.frame = fileNameRect;
    
    CGFloat createWidth = CGRectGetWidth(fileNameRect);
    if (_isPreview) {
        createWidth -= 115.0;
    }
    
    CGRect createTimeRect = createTime.frame;
    createTimeRect.origin.x = fileNameRect.origin.x;
    createTimeRect.size.width = createWidth;
    createTime.frame = createTimeRect;
    
    if (_file.fileExt && _file.fileExt.length>0 && [XTFileUtils isPhotoExt:_file.fileExt]) {
        NSString *url = [NSString stringWithFormat:@"%@%@%@%@", [[KDWeiboServicesContext defaultContext] serverBaseURL], @"/microblog/filesvr/", _file.fileId, @"?thumbnail"];
        [thumbnailPic setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:[XTFileUtils thumbnailImageWithExt:_file.fileExt]]];
    }else{
        thumbnailPic.image = [UIImage imageNamed:[XTFileUtils thumbnailImageWithExt:_file.fileExt]];
    }
    
    CGRect rect = fileSize.frame;
    rect.origin.x = CGRectGetMaxX(rect) +10.f;
    rect.size.width = CGRectGetWidth(self.bounds) - rect.origin.x - 15.f;
    _ownerName.frame = rect;
    
    
    fileName.text = _file.fileName;
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];

    NSString *ct = [formatter stringFromDate:_file.time];
    NSString *fs = [XTFileUtils fileSize:[NSString stringWithFormat:@"%lu",(unsigned long)_file.length]];
    NSString *wn = _file.ownerName;
    wn = wn?wn:@"";
    
    if (_isPreview) {
        createTime.text     = ct;
        fileSize.text       = fs;
        _ownerName.text     = wn;
    }
    else{
        createTime.text     = [NSString stringWithFormat:@"%@ | %@ | %@",ct,fs,wn];
        fileSize.text       =@"";
        _ownerName.text     = @"";
    }
}
@end


@interface XTFoldCell()
@property (nonatomic,strong) UIImageView *separateLineImageView;
@property (nonatomic,strong) UIImageView *thumbnailPic;
@property (nonatomic,strong) UILabel *fileName;
@end

@implementation XTFoldCell

@synthesize separateLineImageView,thumbnailPic,fileName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor kdBackgroundColor2];
        self.contentView.backgroundColor = self.backgroundColor;
        
        CGFloat cellHeight = 65.0;
        
        //文件夹图标
        UIImage *image = [UIImage imageNamed:[XTFileUtils folderImage]];
        thumbnailPic = [[UIImageView alloc] initWithImage:image];
        thumbnailPic.backgroundColor = [UIColor clearColor];
        thumbnailPic.frame = CGRectMake(12.0, (cellHeight - 46.0)/2, 46.0, 46.0);
        [self.contentView addSubview:thumbnailPic];
        
        CGRect rect = thumbnailPic.frame;
        rect.origin.x = rect.origin.x + CGRectGetWidth(rect) + 10.0;
        rect.origin.y += (CGRectGetHeight(rect) - 30.0)/2;
        rect.size.width = 320.0 - rect.origin.x - 30.0;
        rect.size.height = 30.0;
        //名称
        fileName = [[UILabel alloc] initWithFrame:rect];
        fileName.textColor = [UIColor blackColor];
        fileName.backgroundColor = [UIColor clearColor];
        fileName.font = [UIFont boldSystemFontOfSize:16.0];
        [self.contentView addSubview:fileName];
        
        //进入图标
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
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

- (void)setFold:(FoldModel *)fold
{
    if (_fold != fold) {
        _fold = fold;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    fileName.text = _fold.name;
}

@end
