//
//  KDImageOptimizationTask.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-15.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDImageSize.h"
#import "KDCacheUtlities.h"

@protocol KDImageOptimizationTaskDelegate;

@class KDImageOptimizationTask;


////////////////////////////////////////////////////////////////////////////////////

enum {
	KDImageOptimizationPriorityVeryLow = -10,
	KDImageOptimizationPriorityLow = -5,
	KDImageOptimizationPriorityNormal = 0,
	KDImageOptimizationPriorityMedium = 3,
	KDImageOptimizationPriorityHigh = 5,
	KDImageOptimizationPriorityVeryHigh = 10
};

typedef NSUInteger KDImageOptimizationPriority;


////////////////////////////////////////////////////////////////////////////////////

enum {
    KDImageOptimizationTypeNormal = KDCacheImageTypeNormal,
    
    KDImageOptimizationTypeThumbnail = KDCacheImageTypeThumbnail,
    KDImageOptimizationTypeMiddle = KDCacheImageTypeMiddle,
    KDImageOptimizationTypePreview = KDCacheImageTypePreview,
    KDImageOptimizationTypePreviewBlur = KDCacheImageTypePreviewBlur,
    
    KDImageOptimizationTypeMinimumOptimal,
    KDImageOptimizationTypeGif = 99
};

typedef NSUInteger KDImageOptimizationType;


////////////////////////////////////////////////////////////////////////////////////

extern NSString * const kKDImageOptimizationTaskCropedImage;

////////////////////////////////////////////////////////////////////////////////////

typedef void (^KDImageOptimizationCompletionBlock)(KDImageOptimizationTask *task, id generatedImage);


////////////////////////////////////////////////////////////////////////////////////

@interface KDImageOptimizationTask : NSObject {
@private
//    id<KDImageOptimizationTaskDelegate> delegate_;
    
    NSString *imagePath_; // the image path and image only one object works, If the they are both not nil, then the image object will be use. 
    UIImage *image_;
    NSData *data_;
    
    KDImageOptimizationType optimizationType_;
    KDImageSize *imageSize_;
    KDImageOptimizationPriority priority_;
    
    NSString *cacheKey_;
    
    KDImageOptimizationCompletionBlock completionBlock_;
    
    id userInfo_;   // must be an object
}

@property (nonatomic, weak) id<KDImageOptimizationTaskDelegate> delegate;

@property (nonatomic, retain) NSString *imagePath;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSData *data;

@property (nonatomic, assign) KDImageOptimizationType optimizationType;
@property (nonatomic, retain) KDImageSize *imageSize;
@property (nonatomic, assign) KDImageOptimizationPriority priority;

@property (nonatomic, retain, readonly) NSString *cacheKey;

@property (nonatomic, copy) KDImageOptimizationCompletionBlock completionBlock;

@property (nonatomic, retain) id userInfo;

- (id) initWithDelegate:(id<KDImageOptimizationTaskDelegate>)delegate 
              imagePath:(NSString *)imagePath 
              imageSize:(KDImageSize *)imageSize 
               userInfo:(id)userInfo;

- (id) initWithDelegate:(id<KDImageOptimizationTaskDelegate>)delegate 
                  image:(UIImage *)image 
              imageSize:(KDImageSize *)imageSize 
               userInfo:(id)userInfo;
- (id) initWithDelegate:(id<KDImageOptimizationTaskDelegate>)delegate
                  gif:(NSData *)data
              imageSize:(KDImageSize *)imageSize
               userInfo:(id)userInfo;

- (UIImage *) getRawImage;
- (NSData *) getGifData;
@end



@protocol KDImageOptimizationTaskDelegate <NSObject>
@required

- (void) willDropImageOptimizationTask:(KDImageOptimizationTask *)task;

// Please use KDImageOptimizationTaskCropedImage key to retrieve the image when action did succeed,
// Otherwise the object for this key does not exists.
- (void) imageOptimizationTask:(KDImageOptimizationTask *)task didFinishedOptimizedImageWithInfo:(NSDictionary *)info;

@optional

- (void) willStartImageOptimizationTask:(KDImageOptimizationTask *)task;

@end



