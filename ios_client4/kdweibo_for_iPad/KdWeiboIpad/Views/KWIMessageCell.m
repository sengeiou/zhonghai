//
//  KWIMessageCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/18/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIMessageCell.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"
#import "UIImageView+WebCache.h"
#import "NSDate+RelativeTime.h"
#import "UITextView+SizeUtils.h"

#import "KWIAvatarV.h"

#import "KDDMMessage.h"
#import "EGOPhotoViewController.h"
#import "KWIRootVCtrl.h"
#import "KDDocumentListViewController.h"
#import "NSDate+Additions.h"

@interface KWIMessageCell () {
    
    BOOL shouldDisplayDate;
}

@property (retain, nonatomic) KDDMMessage *data;
@property (retain, nonatomic) KDDMMessage *lastMessage;

@property (retain, nonatomic) IBOutlet UIView *ctnWrapperV;
@property (retain, nonatomic) IBOutlet UIImageView *avatarV;
@property (retain, nonatomic) IBOutlet UILabel *usernameV;
@property (retain, nonatomic) IBOutlet UITextView *textV;
@property (retain, nonatomic) IBOutlet UILabel *dateV;
@property (retain, nonatomic) IBOutlet UIView *txtWrapperV;
@property (retain, nonatomic) IBOutlet UIView *imageCotainerView;
@property (retain, nonatomic) IBOutlet UIImageView *thumbnaiIsImageView;

@property (retain, nonatomic) IBOutlet UIImageView *moreImagesIndicatiorImageView;
@property (retain, nonatomic) IBOutlet UITableView *documentTableView;
@property (retain, nonatomic) IBOutlet KDDocumentListViewController *documentTableViewController;
@end

@implementation KWIMessageCell

@synthesize data = _data;
@synthesize lastMessage = _lastMessage;
@synthesize ctnWrapperV = _ctnWrapperV;

@synthesize avatarV = _avatarV;
@synthesize usernameV;
@synthesize textV;
@synthesize dateV;
@synthesize txtWrapperV;

+ (KWIMessageCell *)cell
{
    UIViewController *tmpVCtrl = [[[UIViewController alloc] initWithNibName:@"KWIMessageCell" bundle:nil] autorelease];
    KWIMessageCell *cell = (KWIMessageCell *)tmpVCtrl.view;  
    
    //cell.avatarV.layer.cornerRadius = 4;
    //cell.avatarV.layer.masksToBounds = YES;
    UITapGestureRecognizer *grzr = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(thumbnaiIsImageViewTapped:)];
    [cell.thumbnaiIsImageView addGestureRecognizer:grzr];
    [grzr release];
    
    return cell;
}

- (void)thumbnaiIsImageViewTapped:(UITapGestureRecognizer *)grzr {
    EGOPhotoViewController *fullImgVC = [[EGOPhotoViewController alloc] initwithCompositeImageDataSource:_data.compositeImageSource];
    UINavigationController *navVC = [[[UINavigationController alloc] initWithRootViewController:fullImgVC] autorelease];
    
    navVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    KWIRootVCtrl *rootVC = [KWIRootVCtrl curInst];
    if ([rootVC respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [rootVC presentViewController:navVC animated:YES completion:nil];
    } else {
        [rootVC presentModalViewController:navVC animated:YES];
    }
    [fullImgVC release];

}
- (void)dealloc {
    [_avatarV release];
    [usernameV release];
    [textV release];
    [dateV release];
    [_ctnWrapperV release];
    [txtWrapperV release];
    
    [_data release];
    [_lastMessage release];
    
    [_thumbnaiIsImageView release];
    [_moreImagesIndicatiorImageView release];
    [_imageCotainerView release];
    [_documentTableView release];
    [_documentTableViewController release];
    [super dealloc];
}

#pragma mark -
- (void)setData:(KDDMMessage *)data lastMessage:(KDDMMessage *)lastMessage
{
    [_data release];
    _data = [data retain];
    
    //[self.avatarV setImageWithURL:[NSURL URLWithString:data.sender.profile_image_url]];
    KWIAvatarV *avatarV = [KWIAvatarV viewForUrl:_data.sender.profileImageUrl size:48];
    [avatarV replacePlaceHolder:self.avatarV];
    self.avatarV = nil;
    
    self.usernameV.text = _data.sender.username;
    self.textV.text = _data.message;
  

    if (_data.compositeImageSource) {
        self.imageCotainerView.hidden = NO;
        self.thumbnaiIsImageView.hidden = NO;
        
        NSURL *url = [NSURL URLWithString:[_data.compositeImageSource firstThumbnailURL]];
        [self.thumbnaiIsImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"picture_PH.png"]];
        if ([[_data.compositeImageSource imageSources] count] >0) {
            [self.moreImagesIndicatiorImageView setHidden:NO];
        }else {
            self.moreImagesIndicatiorImageView.hidden = YES;
        }
    }else {
        self.thumbnaiIsImageView.hidden = YES;
        self.moreImagesIndicatiorImageView.hidden = YES;
        self.imageCotainerView.hidden = YES;
    }
    if(_data.attachments){
        self.documentTableView.hidden = NO;
        [self.documentTableViewController setDocumentDataSource:_data];
    }else {
        self.documentTableView.hidden = YES;
    }
    if ([[self class] _shouldDisplayDateForMessage:data lastMessage:lastMessage]) {
        shouldDisplayDate = YES;
        self.dateV.hidden = NO;
        //self.dateV.text = [data.createdAt  formatRelativeTime];
        self.dateV.text = [[NSDate dateWithTimeIntervalSince1970:_data.createdAt] formatRelativeTime];
    } else {
        shouldDisplayDate = NO;
        self.dateV.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat maxY = 0;
    CGRect txtFrame = self.textV.frame;
    txtFrame.size = self.textV.contentSize;
    txtFrame.size.height = [self.textV calulateSizeForText:self.textV.text];
    self.textV.frame = txtFrame;
    CGRect txtWrapperFrame = self.txtWrapperV.frame;
    maxY = CGRectGetMaxY(txtFrame)+5;
    //txtWrapperFrame.size = CGSizeMake(txtFrame.size.width + 20, txtFrame.size.height + 15);
    if (_data.compositeImageSource) {
        CGRect imgCtnFrame = self.imageCotainerView.frame;
        imgCtnFrame.origin.y = CGRectGetMaxY(txtFrame);
        self.imageCotainerView.frame = imgCtnFrame;
        maxY = CGRectGetMaxY(imgCtnFrame) +5;
        
    }
    //self.txtWrapperV.frame = txtWrapperFrame;
    if (_data.attachments) {
        CGRect frame = self.documentTableView.frame;
        frame.origin.y = maxY;
        frame.size.height = [KDDocumentListViewController heightOfTableViewByMessage:_data];
        self.documentTableView.frame = frame;
        maxY = CGRectGetMaxY(frame)+5;
        
    }
     txtWrapperFrame.size = CGSizeMake(txtFrame.size.width + 20, maxY+10);
     self.txtWrapperV.frame = txtWrapperFrame;
     CGRect ctnFrame = self.ctnWrapperV.frame;
     if (shouldDisplayDate) {
        ctnFrame.origin.y = CGRectGetMaxY(self.dateV.frame);
     } else {
        ctnFrame.origin.y = 0;
        //ctnFrame.size.height = CGRectGetMaxY(txtWrapperV.frame);
    }
    self.ctnWrapperV.frame = ctnFrame;
}
+ (NSUInteger)calculateHeightWithMessage:(KDDMMessage *)message lastMessage:(KDDMMessage *)lastMessage
{
    static unsigned int width;
    static unsigned int fontsize;
    if (0 == width) {
        KWIMessageCell *sample = [self cell];
        width = sample.textV.frame.size.width;
        fontsize = sample.textV.font.pointSize;
    }
    
    NSUInteger h = MAX([UITextView calulateSizeForText:message.message withFontsize:fontsize width:width] + 30, 90);
    
    if ([self _shouldDisplayDateForMessage:message lastMessage:lastMessage]) {
        h += 25;
    }
    if (message.compositeImageSource) {
        h+=100+15;
    }
   
    if(message.attachments) {
        h+= [KDDocumentListViewController heightOfTableViewByMessage:message]+15;
                                                                   
    }
    return h;
}

+ (BOOL)_shouldDisplayDateForMessage:(KDDMMessage *)message lastMessage:(KDDMMessage *)lastMessage
{
    return (nil == lastMessage || 300 < [[NSDate dateWithTimeIntervalSince1970: message.createdAt] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970: lastMessage.createdAt]]);
}

@end
