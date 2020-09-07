//
//  KDDownloadCell.m
//  kdweibo
//
//  Created by Tan yingqi on 7/27/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//
#import "KDDownloadCell.h"
#import "KDCommon.h"
#import "NSString+Additions.h"
#import "UIImage+Additions.h"
#import "ResourceManager.h"
#import "NSDate+Additions.h"

@interface KDDownloadCell ()

@property(nonatomic, retain) UIImageView *kindImageView;
@property(nonatomic, retain) UILabel *filenameLabel;
@property(nonatomic, retain) UILabel *sizeLabel;
@property(nonatomic, retain) UIImageView *downloadedStateImageView;

@end

@implementation KDDownloadCell

@dynamic download;

@synthesize kindImageView=kindImageView_;
@synthesize filenameLabel=filenameLabel_;
@synthesize sizeLabel=sizeLabel_;
@synthesize downloadedStateImageView=downloadedStateImageView_;
@synthesize isShowAccessory = _isShowAccessory;
@synthesize cellAccessoryImageView = cellAccessoryImageView_;

- (void)setupDownloadCell {
    
    _isShowAccessory = NO;

    // kind image view
    kindImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    [super.contentView addSubview:kindImageView_];
    
    // filename label
    filenameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    filenameLabel_.backgroundColor = [UIColor clearColor];
    filenameLabel_.font = [UIFont systemFontOfSize:17.0f];
    filenameLabel_.textColor = MESSAGE_TOPIC_COLOR;
    filenameLabel_.lineBreakMode = NSLineBreakByTruncatingMiddle; 
    
    [super.contentView addSubview:filenameLabel_];
    
    // size label
    sizeLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    sizeLabel_.backgroundColor = [UIColor clearColor];
    sizeLabel_.font = [UIFont systemFontOfSize:14.0f];
    sizeLabel_.textColor = MESSAGE_DATE_COLOR;
    
    [super.contentView addSubview:sizeLabel_];
    
    // downloaded state image view
    UIImage *image = [UIImage imageNamed:@"document_loaded_bg"];
    downloadedStateImageView_ = [[UIImageView alloc] initWithImage:image];
    [downloadedStateImageView_ sizeToFit];
    
    [super.contentView addSubview:downloadedStateImageView_];
    
    cellAccessoryImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"group_arrow"]];
    [super.contentView addSubview:cellAccessoryImageView_];
    
    cellAccessoryImageView_.frame = CGRectMake(self.bounds.size.width - cellAccessoryImageView_.image.size.width -15, (60 - cellAccessoryImageView_.image.size.height)/2.0, cellAccessoryImageView_.image.size.width, cellAccessoryImageView_.image.size.height);
    
    
    UILabel *bottom = [[UILabel alloc] initWithFrame:CGRectZero];
    bottom.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    bottom.backgroundColor = MESSAGE_LINE_COLOR;
    bottom.tag = 0x99;
    [self addSubview:bottom];
//    [bottom release];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupDownloadCell];
        self.backgroundColor = MESSAGE_CT_COLOR;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = super.contentView.bounds.size.width;
    CGFloat height = super.contentView.bounds.size.height;
    
    // kind image view
    CGRect rect = CGRectMake(10.0, (height - kindImageView_.image.size.height) * 0.5, kindImageView_.image.size.width, kindImageView_.image.size.height);
    kindImageView_.frame = rect;
    
    // filename label
    CGFloat offsetX = rect.origin.x + rect.size.width + 13.0;
    CGFloat contentWidth = width - offsetX - 40.0;
    if (_isShowAccessory)
        contentWidth -= 00.f;
    rect = CGRectMake(offsetX, 8.0, contentWidth, 22.0);
    filenameLabel_.frame = rect;
    
    // size label
    rect.origin.y += rect.size.height + 2.0;
    if (!_isShowAccessory)
        rect.size.width *= 0.5;
    sizeLabel_.frame = rect;
    
    // downloaded state image view
    rect = downloadedStateImageView_.bounds;
    rect.origin.x = offsetX + contentWidth + 23 - rect.size.width;
    rect.origin.y = (height - rect.size.height)/2.0 +5.f;
    downloadedStateImageView_.frame = rect;

    UILabel *bottom = (UILabel *)[self viewWithTag:0x99];
    bottom.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-0.5f, CGRectGetWidth(self.bounds), 0.5f);
    
    cellAccessoryImageView_.hidden = !_isShowAccessory;
    if (_isShowAccessory)
        downloadedStateImageView_.hidden = YES;
}

- (void)update {
    kindImageView_.image = [UIImage imageByFileEntension:download_.name isBig:YES];

    filenameLabel_.text = download_.name;
    sizeLabel_.text = [NSString formatContentLengthWithBytes:download_.maxByte];
    
    if (_isShowAccessory) {
        sizeLabel_.text = [NSString stringWithFormat:@"%@   %@",sizeLabel_.text,[NSDate formatMonthOrDaySince1970:download_.endAt]];
    }
}

- (void)setDownload:(KDDownload *)download {
    if (download_ != download) {
//        [download_ release];
        download_ = download;// retain];
        
        [self update];
    }
}

- (KDDownload *)download {
    return download_;
}

- (void)hideStateIndicator {
    downloadedStateImageView_.hidden = YES;
}

- (void)showStateIndicator {
    downloadedStateImageView_.hidden = NO;
}

+ (CGFloat)downloadCellHeight {
    return 60.0;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(download_);
    //KD_RELEASE_SAFELY(cellAccessoryImageView_);
    //KD_RELEASE_SAFELY(kindImageView_);
    //KD_RELEASE_SAFELY(filenameLabel_);
    //KD_RELEASE_SAFELY(sizeLabel_);
    //KD_RELEASE_SAFELY(downloadedStateImageView_);
    
    //[super dealloc];
}
@end
