//
//  KDStatusTimelineProvider.m
//  kdweibo
//
//  Created by laijiandong on 12-10-11.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatusTimelineProvider.h"

#import "KDStatus.h"
#import "KDStatusContentView.h"
#import "KDSession.h"
#import "KDDefaultViewControllerContext.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

@implementation KDStatusTimelineProvider 

@synthesize viewController=viewController_;
@synthesize showAccurateGroupName=showAccurateGroupName_;

- (id)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        viewController_ = viewController;
        showAccurateGroupName_ = NO;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark utility methods for
- (CGFloat)calculateStatusContentHeight:(KDStatus *)status inTableView:(UITableView *)tableView bodyViewPosition:(KDStatusBodyViewDisplayPosition)p {
    static NSString *keyForHeight = @"StatusHeight";
    CGFloat height = [[status propertyForKey:keyForHeight] floatValue];
    
    if(height <= 0.0f) {
        height = [KDStatusContentView calculateStatusContentHeight:status bodyViewPosition:p];
    }
    
    [status setProperty:@(height) forKey:keyForHeight];
    
    return height;
}

- (CGFloat)calculateStatusContentHeight:(KDStatus *)status inTableView:(UITableView *)tableView{
    static NSString *keyForHeight = @"StatusHeight";
    CGFloat height = [[status propertyForKey:keyForHeight] floatValue];
    
    if(height <= 0.0f) {
        height = [KDStatusContentView calculateStatusContentHeight:status];
    }
    
    [status setProperty:@(height) forKey:keyForHeight];
    
    return height;
}

- (KDTimelineStatusCell *)timelineStatusCellInTableView:(UITableView *)tableView status:(KDStatus *)status bodyViewPosition:(KDStatusBodyViewDisplayPosition)p {
    static NSString *CellIdentifier = @"Cell";
    
    KDTimelineStatusCell *cell = nil;//(KDTimelineStatusCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
    cell = [[KDTimelineStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        cell.containerView.contentView.bodyView.thumbnailDelegate = self;
        
        if (showAccurateGroupName_) {
            cell.containerView.contentView.footerView.showAccurateGroupName = YES;
        }
//    }
    
    KDStatusBodyViewDisplayStyle style = KDStatusBodyViewDisplayStyleNone;
    if (KDTimelinePresentationPatternImagePreview == [KDSession globalSession].timelinePresentationPattern) {
        style = KDStatusBodyViewDisplayStyleThumbnail;
    }
    
    cell.containerView.contentView.bodyView.style = style;
    cell.containerView.contentView.bodyView.position = p;
    
    cell.status = status;
    
    if(!tableView.dragging && !tableView.decelerating){
        [KDAvatarView loadImageSourceForTableView:tableView withAvatarView:cell.avatarView];
        
        // load the thumbnail if need
        KDThumbnailView2 *thumbnailView = cell.containerView.thumbnailView;
        if(!thumbnailView.hasThumbnail && !thumbnailView.loadThumbnail){
            [thumbnailView setLoadThumbnail:YES];
        }
    }
    
    return cell;

}

- (KDTimelineStatusCell *)timelineStatusCellInTableView:(UITableView *)tableView status:(KDStatus *)status {
    return [self timelineStatusCellInTableView:tableView status:status bodyViewPosition:KDStatusBodyViewDisplayPositionNormal];
}

// load the user avatar and thumbnail if need
//TODO:暂时注释，发版前修改
- (void)loadImageSourceInTableView:(UITableView *)tableView {
    // user avatar
//    [KDAvatarView loadImageSourceForTableView:tableView];
//    
//    // thumbnail
//    NSArray *cells = [tableView visibleCells];
//	if (cells != nil) {
//        KDThumbnailView2 *thumbnailView = nil;
//        for(KDTimelineStatusCell *cell in cells){
//            thumbnailView = cell.containerView.thumbnailView;
//            if(thumbnailView != nil && !thumbnailView.hasThumbnail && !thumbnailView.loadThumbnail){
//                [thumbnailView setLoadThumbnail:YES];
//            }
//        }
//    }
}


////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDThumbnailView delegate methods

// Use the view controller as thumbnail's delegate because the data source class will be
// destory on switch community,
- (void)thumbnailView:(KDThumbnailView2 *)thumbnailView didLoadThumbnail:(UIImage *)thumbnail {
    if (KDTimelinePresentationPatternImagePreview == [KDSession globalSession].timelinePresentationPattern) {
        [thumbnailView loadThumbnailFromDisk];
    }
}

- (void)didTapOnThumbnailView:(KDThumbnailView2 *)thumbnailView userInfo:(id)userInfo {
    
    // some view controller like BlogViewController combined in ProfileViewController.
    // The usage like this looks so bad, we need fixs it in the future
    UIViewController *target = viewController_;
    if (viewController_.parentViewController == nil) {
        target = [[KDDefaultViewControllerContext defaultViewControllerContext] topViewController];
    }
    
    if (thumbnailView.hasVideo) {
        KDVideoPlayerController *videoController = [[KDVideoPlayerController alloc] initWithNibName:nil bundle:nil];
        videoController.delegate = self;
        videoController.weiboStatus = thumbnailView.status;
        [target presentViewController:videoController animated:YES completion:nil];
//        [videoController release];
    } else {
        imageDataSource_ = thumbnailView.imageDataSource;
        
        NSUInteger startImage = 0;
        NSArray *srcs = nil;
        if ([userInfo isKindOfClass:[NSArray class]]) {
            //
            if (((NSArray *)userInfo).count >1) {
                startImage  = [[((NSArray *)userInfo) objectAtIndex:0] intValue];
                srcs = [((NSArray *)userInfo) objectAtIndex:1];
            }
        }
        
        
        NSMutableArray *photos = [NSMutableArray array];
        NSArray *bigUrls    = [imageDataSource_ bigImageURLs];
        NSArray *noRawUrls  = [imageDataSource_ noRawURLs];
        for (int i = 0; i<bigUrls.count; i++) {
            // 替换为中等尺寸图片
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString:[bigUrls objectAtIndex:i]]; // 图片地址
            if (bigUrls.count == noRawUrls.count) {
                photo.originUrl = [NSURL URLWithString:[bigUrls objectAtIndex:i]];//原图地址
            }
            
            if (srcs.count == bigUrls.count ) {
                photo.srcImageView = [srcs objectAtIndex:i]; // 来源于哪个UIImageView
            }
            
            [photos addObject:photo];
//            [photo release];
        }
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init] ;//autorelease];
        browser.currentPhotoIndex = startImage; // 弹出相册时显示的第一张图片是？
        browser.photos = photos; // 设置所有的图片
        [browser show];

    }
   
}

////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark
#pragma mark KDVideoPlayerManager delegate

- (void)videoPlayFinished:(KDVideoPlayerManager *)player
{
    UIViewController *target = viewController_;
    if (viewController_.parentViewController == nil) {
        target = [[KDDefaultViewControllerContext defaultViewControllerContext] topViewController];
    }
    [target dismissViewControllerAnimated:YES completion:nil];
}


- (void)dealloc {
    // make weak reference object point to nil.
    viewController_ = nil;
    imageDataSource_ = nil;
    
    //[super dealloc];
}

@end
