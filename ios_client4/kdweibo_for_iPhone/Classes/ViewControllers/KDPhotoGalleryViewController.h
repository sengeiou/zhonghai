//
//  KDPhotoGalleryViewController.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "KDImageSourceProtocol.h"
#import "KDTileView.h"

#import "KDPhotoTileViewCell.h"
#import "KDPhotoOriginView.h"

@protocol KDPhotoGalleryViewControllerDataSource;

@interface KDPhotoGalleryViewController : UIViewController <MFMailComposeViewControllerDelegate, UIScrollViewDelegate, KDTileViewDataSource, KDImageSourceLoader, KDPhotoTileViewCellDelegate, KDPhotoOriginViewDelegate, UIActionSheetDelegate> {
@private
//    id<KDPhotoGalleryViewControllerDataSource> dataSource_;
//    id<KDImageDataSource> imageDataSource_;
    
    NSArray *photoSourceURLs_;
	NSUInteger currentIndex_;
    
    UIView *headerBar_;
	KDTileView *tileView_;
    KDPhotoOriginView *originView_;
    
	NSTimer *tapTimer_;
	NSTimer *refreshTimer_;
    
    CGSize optimalPreviewSize_;
    
    BOOL statusBarVisible_;
    UIStatusBarStyle normalBarStyle_;
    
	struct {
		unsigned int disappearedBars;
        
    }photoGalleryFags_;
}

@property (nonatomic, assign) id<KDPhotoGalleryViewControllerDataSource> dataSource;

@property (nonatomic, retain) NSArray *photoSourceURLs;

@property (nonatomic, assign) NSUInteger currentIndex;

// 2013.12.2 by Tan Yingqi 增加imageDatasource 属性
@property (nonatomic, retain)id<KDImageDataSource> imageDataSource;

@end


@protocol KDPhotoGalleryViewControllerDataSource <NSObject>
@required

- (id<KDImageDataSource>) imageSourceForPhotoGalleryViewController:(KDPhotoGalleryViewController *)photoGalleryViewController;

@end



