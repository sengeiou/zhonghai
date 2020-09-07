//
//  KDDocumentCell.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-25.
//
//

#import "KDDocumentCell.h"
#import "KDCommon.h"
#import "NSString+Additions.h"
#import "UIImage+Additions.h"

@interface KDDocumentCell()
@property(nonatomic,retain) UIImageView *seperatorView;
@end

@implementation KDDocumentCell

@dynamic download;

@synthesize kindImageView=kindImageView_;
@synthesize filenameLabel=filenameLabel_;
@synthesize seperatorView = seperatorView_;

- (void)setupDownloadCell {
    // kind image view
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    kindImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    kindImageView_.contentMode = UIViewContentModeCenter;
    [super.contentView addSubview:kindImageView_];
    
    // filename label
    filenameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    filenameLabel_.backgroundColor = [UIColor clearColor];
    filenameLabel_.font = [UIFont boldSystemFontOfSize:17.0f];
    filenameLabel_.lineBreakMode = UILineBreakModeMiddleTruncation;
    
    [super.contentView addSubview:filenameLabel_];
    
    
    // divider image view
    seperatorView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"document_list_separator_bg"]];
    //[dividerImageView sizeToFit];
    
    [super.contentView addSubview:seperatorView_];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupDownloadCell];
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
   
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = super.contentView.bounds.size.width;
    CGFloat height = super.contentView.bounds.size.height;
    CGRect rect;
    // kind image view
    rect = CGRectMake(15.0,height*0.1,height*0.8, height*0.8);
    kindImageView_.frame = rect;
    
    // filename label
    CGFloat offsetX = rect.origin.x + rect.size.width + 10.0;
    CGFloat contentWidth = width - offsetX - 10.0;
    rect = CGRectMake(offsetX, (height -22.0)*0.5, contentWidth, 22.0);
    filenameLabel_.frame = rect;
    seperatorView_.frame = CGRectMake(0, height-1, width, 1);

}

- (void)update {
    kindImageView_.image = [UIImage imageByFileEntension:download_.name isBig:NO];
    
    filenameLabel_.text = download_.name;
}

- (void)setDownload:(KDDownload *)download {
    if (download_ != download) {
        [download_ release];
        download_ = [download retain];
        
        [self update];
    }
}

- (KDDownload *)download {
    return download_;
}

+ (CGFloat)optimalHeight {
    return 56.0f;
}

- (void)dealloc {
    KD_RELEASE_SAFELY(download_);
    
    KD_RELEASE_SAFELY(kindImageView_);
    KD_RELEASE_SAFELY(filenameLabel_);
    KD_RELEASE_SAFELY(seperatorView_);
    
    [super dealloc];
}

@end
