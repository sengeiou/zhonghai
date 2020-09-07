//
//  KDImagePickerAssetView.m
//
//  Created by 王 松 on 13-6-20.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDImagePickerAssetView.h"

@interface KDImagePickerAssetView ()

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImageView *overlayImageView;
@property (nonatomic, retain) UIImageView *imageViewUncheck;

- (UIImage *)thumbnail;
- (UIImage *)tintedThumbnail;

@end

@implementation KDImagePickerAssetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self) {
        /* Initialization */
        // Image View
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

//
        
        [self addSubview:_imageView];
        
        UIImageView *imageViewUncheck = [[UIImageView alloc] initWithFrame:CGRectMake(Width(self.frame)-3-22 , 3, 22, 22)];// autorelease];
        imageViewUncheck.contentMode = UIViewContentModeScaleAspectFill;
        imageViewUncheck.clipsToBounds = YES;
        imageViewUncheck.image = [UIImage imageNamed:@"img_btn_check_normal"];
        imageViewUncheck.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageViewUncheck];
        self.imageViewUncheck = imageViewUncheck;
        
        // Overlay Image View
        UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Width(self.frame)-3-22 , 3, 22, 22)];
        overlayImageView.contentMode = UIViewContentModeScaleAspectFill;
        overlayImageView.clipsToBounds = YES;
        overlayImageView.image = [UIImage imageNamed:@"task_editor_finish"];
        overlayImageView.hidden = YES;
        overlayImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:overlayImageView];
        self.overlayImageView = overlayImageView;
//        [overlayImageView release];
    }
    
    return self;
}
- (void)layoutSubviews
{
    
    if (self.bIsCameraView) {
        _imageView.layer.borderColor = RGBCOLOR(210.f, 210.f, 210.f).CGColor;
        _imageView.layer.borderWidth = .5f;
        _imageView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setBIsCameraView:(BOOL)bIsCameraView
{
    _bIsCameraView = bIsCameraView;
    if (self.bIsCameraView) {
        _imageView.layer.borderColor = UIColorFromRGB(0xD2D2D2).CGColor;
        _imageView.layer.borderWidth = .5f;
        _imageView.backgroundColor = [UIColor whiteColor];
        self.imageViewUncheck.hidden = YES;
        
    }else
    {
        self.imageViewUncheck.hidden = NO;
        
    }
}

- (void)setAsset:(ALAsset *)asset
{
//    [_asset release];
    _asset = asset;// retain];
    
    // Set thumbnail image
    self.imageView.image = [self thumbnail];

}

- (void)setSelected:(BOOL)selected
{
    if(self.allowsMultipleSelection) {
        self.overlayImageView.hidden = !selected;
    }
    [self setNeedsDisplay];
}

- (BOOL)selected
{
    return !self.overlayImageView.hidden;
}

- (void)dealloc
{
//    [_asset release];
//    
//    [_imageView release];
//    [_overlayImageView release];
//    [_imageViewUncheck release];
    //[super dealloc];
}


#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate assetViewCanBeSelected:self] && !self.allowsMultipleSelection) {
        self.imageView.image = [self tintedThumbnail];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate assetViewCanBeSelected:self]) {
        self.selected = !self.selected;
        
        if(self.allowsMultipleSelection) {
            self.imageView.image = [self thumbnail];
        } else {
            self.imageView.image = [self tintedThumbnail];
        }
        
        [self.delegate assetView:self didChangeSelectionState:self.selected];
    } else {
        if(self.allowsMultipleSelection && self.selected) {
            self.selected = !self.selected;
            self.imageView.image = [self thumbnail];
            
            [self.delegate assetView:self didChangeSelectionState:self.selected];
        } else {
            self.imageView.image = [self thumbnail];
        }
        
        [self.delegate assetView:self didChangeSelectionState:self.selected];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.imageView.image = [self thumbnail];
}


#pragma mark - Instance Methods

- (UIImage *)thumbnail
{
    return [UIImage imageWithCGImage:[self.asset thumbnail]];
}

- (UIImage *)tintedThumbnail
{
    UIImage *thumbnail = [self thumbnail];
    
    UIGraphicsBeginImageContext(thumbnail.size);
    
    CGRect rect = CGRectMake(0, 0, thumbnail.size.width, thumbnail.size.height);
    [thumbnail drawInRect:rect];
    
    [[UIColor colorWithWhite:0 alpha:0.5] set];
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceAtop);
    
    UIImage *tintedThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tintedThumbnail;
}

@end
