//
//  KDPhotoPreviewController.h
//  kdweibo
//
//  Created by lichao_liu on 15/3/14.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDPhotoPreviewControllerDelegate;

@interface KDPhotoPreviewController : UIViewController
@property (nonatomic, assign) id<KDPhotoPreviewControllerDelegate> photoPreviewDelegate;
@property (nonatomic, strong) NSMutableArray *assetArray;
@property (nonatomic, strong) NSMutableArray *cacheArray;
@property (nonatomic, assign) BOOL isDeleteCache;//在这个页面中删除在其他controller中无法删除的缓存
- (void)clickedPreviewImageViewAtIndex:(NSInteger)index assetArray:(NSArray *)assetArray cacheArray:(NSArray *)cacheArray;
@end


@protocol KDPhotoPreviewControllerDelegate <NSObject>

- (void)photoPreviewDone:(BOOL)isDone info:(NSDictionary *)info previewController:(KDPhotoPreviewController *)preview;


@end