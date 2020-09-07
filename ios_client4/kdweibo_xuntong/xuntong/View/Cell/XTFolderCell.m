//
//  XTFolderCell.m
//  XT
//
//  Created by kingdee eas on 13-12-17.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTFolderCell.h"
#import "XTSelectStateView.h"
#import "FileModel.h"
#import "XTFileUtils.h"

@interface XTFolderCell()
@property (nonatomic,retain) XTSelectStateView *selectStateView;
@end

@implementation XTFolderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFile:(FileModel *)fileModel withPreview:(BOOL)isPreview
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _file = fileModel;
        //文件夹图标
        UIImage *image = [UIImage imageNamed:[XTFileUtils thumbnailImageWithExt:@"folder"]];
        UIImageView *thumbnailPic = [[UIImageView alloc] initWithImage:image];
        thumbnailPic.frame = CGRectMake(15.0, 7.0, 46.0, 46.0);
        [self.contentView addSubview:thumbnailPic];
        //名称
        UILabel *fileName = [[UILabel alloc] initWithFrame:CGRectMake(68.0, 15.0, 235.0, 30.0)];
        fileName.text = _file.name;
        fileName.textColor = BOSCOLORWITHRGBA(0x777777, 1.0);
        fileName.backgroundColor = [UIColor clearColor];
        fileName.font = [UIFont fontWithName:@"Arial" size:18.0];
        [self.contentView addSubview:fileName];
        //进入图标
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //底条
        UIImageView *separateLineImageView = nil;
        separateLineImageView = [[UIImageView alloc] initWithImage:[XTImageUtil cellSeparateLineImage]];
        CGRect frame = separateLineImageView.frame;
        frame.origin.x += 15.0;
        frame.origin.y += 60.0;
        separateLineImageView.frame = frame;
        [self.contentView addSubview:separateLineImageView];
        //选中效果
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xE5E5E5, 1.0);
        self.selectedBackgroundView = bgColorView;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
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

@end

