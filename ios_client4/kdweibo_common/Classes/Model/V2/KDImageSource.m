//
//  KDImageSource.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-29.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDImageSource.h"
#import "KDCache.h"
#import "NSDictionary+Additions.h"
#import "UIImage+Additions.h"
#import "NSString+Additions.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface KDImageSource()
@property(nonatomic,retain)ALAssetsLibrary *assetLibrary;
@end
@implementation KDImageSource

@synthesize fileId = fileId_;
@synthesize fileName = fileName_;
@synthesize fileType = fileType_;
@synthesize entityId = entityId_;
@synthesize thumbnail=thumbnail_;
@synthesize middle = middle_;
@synthesize original=original_;
@synthesize isUpload = isUpload_;
@synthesize rawFileUrl = rawFileUrl_;
@synthesize assetLibrary = assetLibrary_;
@synthesize noRawUrl = noRawUrl_;

- (id)init {
    self = [super init];
    if(self){
        fileId_ = nil;
        fileName_ = nil;
        fileType_ = nil;
        entityId_ = nil;
        thumbnail_ = nil;
        middle_ = nil;
        original_ = nil;
        noRawUrl_ = nil;
        isUpload_ = NO;
    }
    
    return self;
}
- (ALAssetsLibrary *)assetLibrary {
    if(assetLibrary_ == nil) {
        assetLibrary_ = [[ALAssetsLibrary alloc] init];
    }
    return assetLibrary_;
}

- (void)fetchThumbImage {
    if (self.thumbnail == nil && self.rawFileUrl) {
        NSURL *theUrl=[NSURL URLWithString:self.rawFileUrl];
        if ([[KDCache sharedCache] hasImageForURL:self.rawFileUrl imageType:KDCacheImageTypeThumbnail]) {
            self.thumbnail = self.rawFileUrl;
        }else {
            [self.assetLibrary assetForURL:theUrl resultBlock:^(ALAsset *asset)  {
                UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
                
                [[KDCache sharedCache] storeImage:image forURL:self.rawFileUrl imageType:KDCacheImageTypeThumbnail finishedBlock:^(BOOL success) {
                    self.thumbnail = self.rawFileUrl;
                }];
                
            }failureBlock:^(NSError *error) {
                NSLog(@"error=%@",error);
            }
            ];
        }
        
    }
}

- (void)getOriginalImage {
    if (self.middle)
        self.original = [self.middle stringByAppendingString:@"?original"];
    else
    {
        NSString *str = nil;
        if (self.thumbnail)
            str = self.thumbnail;
        else
            str = self.original;
        
        if (str) {
            
            NSString *original = nil;
            NSScanner *scanner = [NSScanner scannerWithString:str];
            if ([scanner scanUpToString:@"?" intoString:&original])
                self.original = [original stringByAppendingString:@"?original"];
        }
        
    }
}
- (void)fetchOrignImage:(void(^)(void))completionBlock {
    if (self.original == nil && self.rawFileUrl) {
        NSURL *theUrl=[NSURL URLWithString:self.rawFileUrl];
         NSString *url = [self.rawFileUrl stringByAppendingString:@"?origin"];
        if ([[KDCache sharedCache] hasImageForURL:url imageType:KDCacheImageTypeThumbnail]) {
            self.original = url;
            if (completionBlock) {
                completionBlock();
            }
        }else {
            [self.assetLibrary assetForURL:theUrl resultBlock:^(ALAsset *asset)  {
                
                UIImage *image =[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                image = [UIImage normalizedLocalImage:image];
                
                [[KDCache sharedCache] storeImage:image forURL:url imageType:KDCacheImageTypeOrigin finishedBlock:^(BOOL success) {
                    //self.thumbnail = self.rawFileUrl;
                    self.original = url;
                    if (completionBlock) {
                        completionBlock();
                    }
                }];
                
            }failureBlock:^(NSError *error) {
                NSLog(@"error=%@",error);
            }
             ];

        }
    }
}

- (NSString *)description {
    NSMutableString *body = [NSMutableString string];
    [body appendString:@"{"];
    [body appendFormat:@"\"thumbnail_pic\" : \"%@\", ", (thumbnail_ != nil) ? thumbnail_ : [NSNull null]];
    [body appendFormat:@"\"bmiddle_pic\" : \"%@\", ", (middle_ != nil) ? middle_ : [NSNull null]];
    [body appendFormat:@"\"original_pic\" : \"%@\"", (original_ != nil) ? original_ : [NSNull null]];
    [body appendFormat:@"\"fileType\" : \"%@\"", (fileType_ != nil) ? fileType_ : [NSNull null]];
    [body appendString:@"}"];
    
    return body;
}
/*
- (void)savePickedImage:(UIImage *)image {
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    //    NSString *tempPath = [[KDUtility defaultUtility] searchDirectory:KDApplicationTemporaryDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];
    //
    //    NSString *filename = [[NSDate date] formatWithFormatter:KD_DATE_ISO_8601_LONG_NUMERIC_FORMATTER];
    //    filename = [filename stringByAppendingFormat:@"_%@", [NSString randomStringWithWide:6]];
    //
    //    self.pickedImageCachePath = [tempPath stringByAppendingPathComponent:filename];
    //
    //    // thumbnail
    //    BOOL showedThumbnail = [self generateThumbnail:image];
    //
    //	// original image
    //    CGSize previewSize = CGSizeMake(800.0f, 600.0f);
    //	if(image.size.width > previewSize.width || image.size.height > previewSize.height){
    //        image = [image scaleToSize:previewSize type:KDImageScaleTypeFill];
    //	}
    //
    //	NSData *data = UIImageJPEGRepresentation(image, 1.0);
    //	BOOL created = [[NSFileManager defaultManager] createFileAtPath:self.pickedImageCachePath contents:data attributes:nil];
    //
    //	//
    //	NSDictionary *callbackInfo = [NSDictionary dictionaryWithObjectsAndKeys:
    //								  [NSNumber numberWithBool:created], @"created",
    //								  [NSNumber numberWithBool:showedThumbnail], @"showedThumbnail", nil];
    //
    //	[self performSelectorOnMainThread:@selector(didSavePickedImageWithInfo:) withObject:callbackInfo waitUntilDone:[NSThread isMainThread]];
    __block NSString *path = nil;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^(void){
        dispatch_sync(queue, ^(void) {
            NSString *tempPath = [[KDUtility defaultUtility] searchDirectory:KDApplicationTemporaryDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];
            
            NSString *filename = [[NSDate date] formatWithFormatter:KD_DATE_ISO_8601_LONG_NUMERIC_FORMATTER];
            filename = [filename stringByAppendingFormat:@"_%@", [NSString randomStringWithWide:6]];
            tempPath = [tempPath stringByAppendingPathComponent:filename];
            
            // thumbnail
            // BOOL showedThumbnail = [self generateThumbnail:image];
            //
            //	// original image
            UIImage *finalImage = image;
            CGSize previewSize = CGSizeMake(800.0f, 600.0f);
            if(image.size.width > previewSize.width || image.size.height > previewSize.height){
                finalImage = [image scaleToSize:previewSize type:KDImageScaleTypeFill];
            }
            
            NSData *data = UIImageJPEGRepresentation(finalImage, 1.0);
            BOOL created = [[NSFileManager defaultManager] createFileAtPath:tempPath
                                                                   contents:data attributes:nil];
            if (created) {
                path = tempPath;
            }
            
        });
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            [self imageDidSaved:path];
            
        });
        
    });
	
	//[pool release];
}
*/

- (NSString *)fileId {
    if (!fileId_) {
        //修正闪退bug 王松 2013-12-24 
        fileId_ = [NSString stringWithFormat:@"%lu",(unsigned long)self.hash];// retain];
    }
    return fileId_;
}

- (BOOL)isGifImage
{
    if (!self.fileType) 
        return NO;
    if ([self.fileType hasSuffix:@"image/gif"])
        return YES;
    return NO;
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(noRawUrl_);
    //KD_RELEASE_SAFELY(fileId_);
    //KD_RELEASE_SAFELY(fileName_);
    //KD_RELEASE_SAFELY(fileType_);
    //KD_RELEASE_SAFELY(entityId_);
    //KD_RELEASE_SAFELY(thumbnail_);
    //KD_RELEASE_SAFELY(middle_);
    //KD_RELEASE_SAFELY(original_);
    //KD_RELEASE_SAFELY(rawFileUrl_);
    
    //[super dealloc];
}

@end
