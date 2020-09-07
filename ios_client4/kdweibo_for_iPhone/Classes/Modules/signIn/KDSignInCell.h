//
//  KDSignInCell.h
//  kdweibo
//
//  Created by 王 松 on 13-8-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDPhotoSignInPhotoCollectionView.h"

typedef enum SigninStyle {
    kSigninStyleGray = 0,
    kSigninStyleBlue
} SigninStyle;

typedef enum ButtonTag {
    kSignInDeleteButtonTag = 1001,
    kSignInWeiboButtonTag = 1002,
    KSignInAddSignInPoint = 1003,
    kdSignInFailuredBtnTag = 1004
} ButtonTag;

typedef enum {
    kStatusNormal = 0,
    kStatusLeftExpanded,
    kStatusLeftExpanding,
    kStatusRightExpanded,
    kStatusRightExpanding,
} kStatus;

typedef enum {
    KDCellDirectionNone = 0,
    KDCellDirectionRight,
    KDCellDirectionLeft,
} KDCellDirection;

@class KDSignInCell;

@protocol KDSignInCellDelegate <NSObject>

- (void)cellDidReveal:(KDSignInCell *)cell;

- (void)cellDidClicked:(KDSignInCell *)cell withTag:(NSUInteger)tag;

@end

@class KDSigninCellInnerView;

#import "KDSignInRecord.h"

@interface KDSignInCell : UITableViewCell

@property(nonatomic, assign) SigninStyle cellStyle;

@property(nonatomic, assign) id <KDSignInCellDelegate> delegate;

@property(nonatomic, strong) KDSigninCellInnerView *innerView;

@property(nonatomic, assign) id <KDPhotoSignInPhotoCollectionViewDelegate> photoSignInCollectionViewDelegate;

/**
 *  设置显示消息
 *
 *  @param record 显示消息
 */
@property(nonatomic, strong) KDSignInRecord *record;

/**
 *  根据显示消息计算cell高度
 *
 *  @param record
 *
 *  @return 返回高度
 */
+ (CGFloat)cellHeightByRecord:(KDSignInRecord *)record;

/**
 *  根据显示消息计算cell高度
 *
 *  @param record
 *  @param min    最小高度
 *
 *  @return 返回高度
 */
+ (CGFloat)cellHeightByString:(NSString *)record withMinHeigh:(CGFloat)min;

+ (CGFloat)cellHeightByContentString:(NSString *)record withMinHeigh:(CGFloat)min;

/**
 *  将cell划回
 */
- (void)slideInContentView;

/**
 *  将cell划出
 */
- (void)slideOutContentView;

/**
 *  设置是否允许左划手势
 *
 *  @param enable
 */
- (void)setGestureEnable:(BOOL)enable;
@end

@interface KDSigninCellInnerView : UIView <UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIView *bgView;

@property(nonatomic, strong) UIView *clipBoundView;

@property(nonatomic, strong) UIView *dotView;

@property(nonatomic, strong) UILabel *timeLabel;

@property(nonatomic, strong) UILabel *signTypeLabel;

@property(nonatomic, strong) UILabel *contentLabel;

@property(nonatomic, strong) UIImageView *signInFailureImageView;

@property(nonatomic, strong) UIView *bottomLeftView;

@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property(nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property(nonatomic, assign) CGFloat initialHorizontalCenter;

@property(nonatomic, assign) CGFloat initialTouchPositionX;

@property(nonatomic, assign) CGFloat originalCenter;

@property(nonatomic, assign) kStatus currentStatus;

@property(nonatomic, assign) BOOL revealing;

@property(nonatomic, assign) KDCellDirection lastDirection;

@property(nonatomic, strong) KDSignInRecord *record;

@property(nonatomic, assign) SigninStyle cellStyle;

@property(nonatomic, assign) id <KDSignInCellDelegate> delegate;

@property(nonatomic, assign) KDSignInCell *cell;

@property(nonatomic, strong) KDPhotoSignInPhotoCollectionView *photoCollectionView;

@property(nonatomic, assign) id <KDPhotoSignInPhotoCollectionViewDelegate> photoSignInCollectionViewDelegate;

@property (nonatomic, strong) UILabel *locationNameLabel;

/**
 *  将cell划回
 */
- (void)slideInContentView;

/**
 *  将cell划出
 */
- (void)slideOutContentView;

/**
 *  设置是否允许左划手势
 *
 *  @param enable
 */
- (void)setGestureEnable:(BOOL)enable;

@end
