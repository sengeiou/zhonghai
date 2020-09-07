//
//  MJPhoto.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "MJPhoto.h"

@implementation MJPhoto

#pragma mark 截图
- (UIImage *)capture:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)setSrcImageView:(UIImageView *)srcImageView
{
    _srcImageView = srcImageView;
    _placeholder = srcImageView.image;
    
    if (srcImageView.clipsToBounds) {
        _capture = [self capture:srcImageView];
    }
}
-(void)setIsOriginalPic:(NSString *)isOriginalPic
{
    if (_isOriginalPic != isOriginalPic) {
        _isOriginalPic =  isOriginalPic;
    }
}
-(void)setDirection:(NSInteger)direction
{
    if (_direction != direction) {
        _direction =  direction;
    }
}
-(void)setPhotoLength:(NSString *)photoLength
{
    if (_photoLength != photoLength) {
        _photoLength =  photoLength;
    }
}
-(void)setMidPictureUrl:(NSURL *)midPictureUrl
{
    if (_midPictureUrl != midPictureUrl) {
        _midPictureUrl = midPictureUrl;
    }
}

-(BOOL)isQRCodeImage
{
    __weak __typeof(self) weakSelf = self;
    
    //已经检查过是否二维码，就不再检验了
    if(self.isQRImage != 0)
    {
        if(self.isQRImage == 1)
            return YES;
        
        return NO;
    }
    
    
    //检测是否为二维码,添加菜单
    if(self.image == nil)
        return NO;
    
    NSString *url = [weakSelf scanQRWithImage:self.image];
    if(url.length>0)
    {
        self.isQRImage = 1;
        return YES;
    }
    else
    {
        self.isQRImage = -1;
        return NO;
    }
}

- (NSString *)scanQRWithImage:(UIImage *)srcImage {
    if (!isAboveiOS8) {
        return nil;
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];
    
    NSString *result = nil;
    NSArray *features = [detector featuresInImage:image];
    
    if (features.count) {
        for (CIFeature *feature in features) {
            if ([feature isKindOfClass:[CIQRCodeFeature class]]) {
                result = ((CIQRCodeFeature *)feature).messageString;
                break;
            }
        }
    }
    
    return result;
}
@end