//
//  XTFolderCell.h
//  XT
//
//  Created by kingdee eas on 13-12-17.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FileModel;
@interface XTFolderCell : UITableViewCell

@property (nonatomic, assign) BOOL checked;
@property (nonatomic,retain) FileModel *file;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFile:(FileModel *)fileModel withPreview:(BOOL)isPreview;
- (void)setChecked:(BOOL)checked;
- (void)setChecked:(BOOL)checked animated:(BOOL)animated;

@end
