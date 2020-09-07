//
//  KDImageSource.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
////@protocol KDImageSourceDelegate<NSObject>
////@optional
//
//- (void)orignImageDidFetch:(UIImage *)image;
//@end
@interface KDImageSource : NSObject {
 @private
    NSString *fileId_;
    NSString *fileName_;
    NSString *fileType_;
    NSString *entityId_;
    NSString *thumbnail_;
    NSString *middle_;
    NSString *original_;
    NSString *noRawUrl_;
    BOOL isUpload_;
}

@property(nonatomic, retain)NSString *fileId;
@property(nonatomic, retain)NSString *fileName;
@property(nonatomic, retain)NSString *fileType;
@property(nonatomic, retain)NSString *entityId;
@property(nonatomic, retain) NSString *thumbnail;
@property(nonatomic, retain) NSString *middle;
@property(nonatomic, retain) NSString *original;
@property(nonatomic, retain)NSString *noRawUrl;
@property(nonatomic, assign)BOOL isUpload;
@property(nonatomic, retain)NSString *rawFileUrl;
- (void)fetchThumbImage;
- (void)fetchOrignImage:(void(^)(void))completionBlock;
- (void)getOriginalImage;
- (BOOL)isGifImage;
@end
