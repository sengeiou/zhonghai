//
//  KDImagePickerAssetCell.m
//  kdweibo
//
//  Created by 王 松 on 13-6-20.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDImagePickerAssetCell.h"

#define kTakeButtonTag (int)10001

@interface KDImagePickerAssetCell ()

- (void)addAssetViews;

@end

@implementation KDImagePickerAssetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageSize:(CGSize)imageSize numberOfAssets:(NSUInteger)numberOfAssets margin:(CGFloat)margin
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.imageSize = imageSize;
        self.numberOfAssets = numberOfAssets;
        self.margin = margin;
        self.backgroundColor = [UIColor clearColor];
        //        if (self.showTakeButton)
        //        {
        //            KDImagePickerAssetView *cameraAssetView = (KDImagePickerAssetView *)[self.contentView viewWithTag:0];
        //            cameraAssetView.bIsCameraView = YES;
        //        }
        
        [self addAssetViews];
    }
    
    return self;
}

- (void)setAssets:(NSArray *)assets
{
    
    NSLog(@"showTakeButton----》%d",self.showTakeButton);
    
    
    
//    [_assets release];
    _assets = assets;// retain];
    
    // Set assets
    for(NSUInteger i = 0; i < self.numberOfAssets; i++) {
        
        int tag = (int)i + 1;
        if (self.showTakeButton) {
            KDImagePickerAssetView *assetView = (KDImagePickerAssetView *)[self.contentView viewWithTag:1];
            assetView.asset = nil;
            assetView.bIsCameraView = self.showTakeButton;
            tag = tag + 1;
        }
        
        
        KDImagePickerAssetView *assetView = (KDImagePickerAssetView *)[self.contentView viewWithTag:tag];
        assetView.bIsCameraView = NO;
        if(i < self.assets.count) {
            assetView.hidden = NO;
            
            assetView.asset = [self.assets objectAtIndex:i];
        } else {
            assetView.hidden = YES;
        }
    }
    
    
    if (self.showTakeButton) {
        [self.contentView viewWithTag:kTakeButtonTag].hidden = NO;
    }else {
        [self.contentView viewWithTag:kTakeButtonTag].hidden = YES;
    }
    
    
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    
    // Set property
    for(UIView *subview in self.contentView.subviews) {
        if([subview isMemberOfClass:[KDImagePickerAssetView class]]) {
            [(KDImagePickerAssetView *)subview setAllowsMultipleSelection:self.allowsMultipleSelection];
        }
    }
}

- (void)dealloc
{
//    [_assets release];
    
    //[super dealloc];
}


#pragma mark - Instance Methods

- (void)addAssetViews
{
    // Remove all asset views
    for(UIView *subview in self.contentView.subviews) {
        if([subview isMemberOfClass:[KDImagePickerAssetView class]] || ([subview isMemberOfClass:[UIButton class]] && subview.tag == kTakeButtonTag)) {
            [subview removeFromSuperview];
        }
    }
    
    // Add asset views
    for(NSUInteger i = 0; i < self.numberOfAssets; i++) {
        
        // Calculate frame
        CGFloat offset = (self.margin + self.imageSize.width) * i;
        CGRect assetViewFrame = CGRectMake(offset + self.margin, self.margin, self.imageSize.width, self.imageSize.height);
        
        // Add asset view
        KDImagePickerAssetView *assetView = [[KDImagePickerAssetView alloc] initWithFrame:assetViewFrame];
        assetView.delegate = self;
        assetView.tag = 1 + i;
        assetView.autoresizingMask = UIViewAutoresizingNone;
        
        [self.contentView addSubview:assetView];
//        [assetView release];
    }
    
    CGRect assetViewFrame = CGRectMake(self.margin, self.margin, self.imageSize.width, self.imageSize.height);
    UIButton *takeButton = [[UIButton alloc] initWithFrame:assetViewFrame];
    takeButton.tag = kTakeButtonTag;
    [takeButton setImage:[UIImage imageNamed:@"dm_img_sendpic"] forState:UIControlStateNormal];
    [self.contentView addSubview:takeButton];
    [takeButton addTarget:self.delegate action:@selector(takePhotoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [takeButton release];
}

- (void)selectAssetAtIndex:(NSUInteger)index
{
    KDImagePickerAssetView *assetView = (KDImagePickerAssetView *)[self.contentView viewWithTag:(index + 1)];
    assetView.selected = YES;
}

- (KDImagePickerAssetView *)assetAtIndex:(NSUInteger)index
{
    return (KDImagePickerAssetView *)[self.contentView viewWithTag:(index + 1)];
}

- (void)deselectAssetAtIndex:(NSUInteger)index
{
    KDImagePickerAssetView *assetView = (KDImagePickerAssetView *)[self.contentView viewWithTag:(index + 1)];
    assetView.selected = NO;
}

- (void)selectAllAssets
{
    for(UIView *subview in self.contentView.subviews) {
        if([subview isMemberOfClass:[KDImagePickerAssetView class]]) {
            if(![(KDImagePickerAssetView *)subview isHidden]) {
                [(KDImagePickerAssetView *)subview setSelected:YES];
            }
        }
    }
}

- (void)deselectAllAssets
{
    for(UIView *subview in self.contentView.subviews) {
        if([subview isMemberOfClass:[KDImagePickerAssetView class]]) {
            if(![(KDImagePickerAssetView *)subview isHidden]) {
                [(KDImagePickerAssetView *)subview setSelected:NO];
            }
        }
    }
}


#pragma mark - QBImagePickerAssetViewDelegate

- (BOOL)assetViewCanBeSelected:(KDImagePickerAssetView *)assetView
{
    return [self.delegate assetCell:self canSelectAssetAtIndex:(assetView.tag - 1)];
}

- (void)assetView:(KDImagePickerAssetView *)assetView didChangeSelectionState:(BOOL)selected
{
    [self.delegate assetCell:self didChangeAssetSelectionState:selected atIndex:(assetView.tag - 1)];
}

- (void)didTouchPreviewWithAssetView:(KDImagePickerAssetView *)assetView
{
    [self.delegate assetCell:self didTouchPreviewWithTag:assetView.tag - 1];
}

@end
