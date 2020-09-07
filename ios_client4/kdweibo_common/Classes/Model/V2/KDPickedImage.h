//
//  KDPickedImage.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-2.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDImageOptimizer.h"
#import "KDImageSize.h"

@protocol KDPickedImageDelegate;


@interface KDPickedImage : NSObject <KDImageOptimizationTaskDelegate> {
@private
//    id<KDPickedImageDelegate> delegate_;
    
    UIImage *pickedImage_;
    UIImage *thumbnail_;
    
    NSString *cachePath_;
    NSString *thumbnailPath_;
    
    KDImageSize *optimalSize_;
    KDImageSize *thumbnailSize_;
    
    BOOL generateThumbnail_;
    BOOL highResolutionEnable_;
    BOOL diskCacheEnable_;
}

@property (nonatomic, assign) id<KDPickedImageDelegate> delegate;

@property (nonatomic, retain) UIImage *pickedImage;
@property (nonatomic, retain, readonly) UIImage *thumbnail;

@property (nonatomic, retain) NSString *cachePath;
@property (nonatomic, retain) NSString *thumbnailPath;

@property (nonatomic, retain) KDImageSize *optimalSize;
@property (nonatomic, retain) KDImageSize *thumbnailSize;


@property (nonatomic, assign) BOOL generateThumbnail;
@property (nonatomic, assign) BOOL highResolutionEnable;
@property (nonatomic, assign) BOOL diskCacheEnable;


- (id) initWithImage:(UIImage *)pickedImage;

- (NSString *) cachePath:(BOOL)usingDefault;

- (void) optimal; 

- (void) store;
- (void) remove;

@end


@protocol KDPickedImageDelegate <NSObject>
@optional

- (void) didFinishOptimalPickedImage:(KDPickedImage *)pickedImage;

@end
