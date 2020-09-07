//
//  KDSignInPhotoCell.h
//  kdweibo
//
//  Created by lichao_liu on 9/22/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDSignInPhotoCellDelegate <NSObject>

- (void)imagePostPreviewDidTapAtIndex:(NSUInteger)index;
- (void)imagePostPreviewDidTapAddedButton:(BOOL)tap;

@end

@interface KDSignInPhotoCell : KDTableViewCell

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UILabel *imageSizeLabel;
@property (nonatomic, strong) NSArray *assetURLs;

@property (nonatomic, assign) id<KDSignInPhotoCellDelegate> previewCelldelegate;

@end
