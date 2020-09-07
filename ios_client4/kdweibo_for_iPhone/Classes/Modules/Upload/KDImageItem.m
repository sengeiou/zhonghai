//
//  KDImageItem.m
//  kdweibo
//
//  Created by Tan yingqi on 13-5-16.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDImageItem.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface KDImageItem(){
    BOOL isloading;
}
@property(nonatomic,retain)ALAssetsLibrary *assetLibrary;
@end
@implementation KDImageItem
@synthesize url = url_;
@synthesize image = image_;
@synthesize delegate = delegate_;
@synthesize assetLibrary = assetLibrary_;

- (void)startLoad {
    [self loadThumbImage];
}

- (void)loadThumbImage {
    if (!isloading&&self.url&&!self.image) {
        isloading = YES;
        NSURL *theUrl=[NSURL URLWithString:self.url];
        [self.assetLibrary assetForURL:theUrl resultBlock:^(ALAsset *asset)  {
            isloading = NO;
            self.image=[UIImage imageWithCGImage:asset.thumbnail];
            if(self.delegate && [self.delegate respondsToSelector:@selector(thumbImageDidLoad:)] ) {
                [self.delegate thumbImageDidLoad:self.image];
            }
        }failureBlock:^(NSError *error) {
            NSLog(@"error=%@",error);
        }
         ];
    }
 
}
- (void)loadOrignImage {
    if(!isloading &&self.url) {
        NSURL *theUrl=[NSURL URLWithString:self.url];
        [self.assetLibrary assetForURL:theUrl resultBlock:^(ALAsset *asset)  {
            isloading = NO;
            UIImage *image =[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            if(self.delegate && [self.delegate respondsToSelector:@selector(orignImageDidLoad:)] ) {
                [self.delegate orignImageDidLoad:image];
            }
        }failureBlock:^(NSError *error) {
            NSLog(@"error=%@",error);
        }
         ];
    }   
}

- (ALAssetsLibrary *)assetLibrary {
    if(assetLibrary_ == nil) {
        assetLibrary_ = [[ALAssetsLibrary alloc] init];
    }
    return assetLibrary_;
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(assetLibrary_);
    //KD_RELEASE_SAFELY(url_);
    //KD_RELEASE_SAFELY(image_);
    //[super dealloc];
}
@end