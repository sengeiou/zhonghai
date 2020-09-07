//
//  KDImageUploadTask.h
//  kdweibo
//
//  Created by Tan yingqi on 13-5-17.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDUploadTask.h"
#import "KDDocumentUploadTask.h"
@class KDImageSource;
@interface KDImageUploadTask : KDDocumentUploadTask {
    @protected
     KDImageSource *imageSource_;
}
@property(nonatomic,retain)KDImageSource *imageSource;
//+(KDImageUploadTask *)imageUploadTaskWithImageSource:(KDImageSource *)imageItem;
+ (KDImageUploadTask *)imageUploadTaskWithCompositeImageSource:(KDCompositeImageSource *)source ;
//- (NSString *)ids;
+ (KDImageUploadTask*)imageUploadTaskWithImageSourceArray:(NSArray *)array;
+ (KDImageUploadTask *)imageUploadTaskWithCompositeImageSource:(KDCompositeImageSource *)source;
@end
