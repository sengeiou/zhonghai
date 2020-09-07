//
//  KDDocumentMoreCell.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-5-2.
//
//

#import "KDDocumentMoreCell.h"
#import "UIImage+Additions.h"
@interface KDDocumentMoreCell()
 @property(nonatomic, retain) UIImageView *iconImageView;
 @property(nonatomic, retain) UILabel *label;
@end

@implementation KDDocumentMoreCell

@synthesize iconImageView = iconImageView_;
@synthesize label = label_;

- (void)setup {
    // kind image view
    
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage stretchableImageWithImageName:@"document_list_cell_selected_bg" leftCapWidth:5 topCapHeight:2]];
//    selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//    self.selectedBackgroundView = selectedBackgroundView;
    
    iconImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_more_docs"]];
    iconImageView_.contentMode = UIViewContentModeCenter;
   
    [super.contentView addSubview:iconImageView_];
    
    // filename label
    label_ = [[UILabel alloc] initWithFrame:CGRectZero];
    label_.backgroundColor = [UIColor clearColor];
    label_.font = [UIFont boldSystemFontOfSize:17.0f];
    label_.lineBreakMode = UILineBreakModeMiddleTruncation;
    
    [super.contentView addSubview:label_];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = super.contentView.bounds.size.width;
    CGFloat height = super.contentView.bounds.size.height;
    CGRect rect = CGRectMake(-1.0,-1,width+2, height+2);
    self.backgroundView.frame = rect;
    // kind image view
    rect = CGRectMake(15.0,0,height, height);
    iconImageView_.frame = rect;
    
    // filename label
    CGFloat offsetX = rect.origin.x + rect.size.width + 10.0;
    CGFloat contentWidth = width - offsetX - 10.0;
    rect = CGRectMake(offsetX, (height -22.0)*0.5, contentWidth, 22.0);
    label_.frame = rect;

}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    UIImageView *backgroundView = nil;
        if (highlighted) {
                label_.textColor = [UIColor whiteColor];
                iconImageView_.image = [UIImage imageNamed:@"icon_more_unselected"];
             backgroundView = [[UIImageView alloc] initWithImage:[UIImage stretchableImageWithImageName:@"document_list_cell_selected_bg" leftCapWidth:5 topCapHeight:2]];
            backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            self.backgroundView = backgroundView;
            [backgroundView release];
            }else {
                label_.textColor = [UIColor blackColor];
                iconImageView_.image = [UIImage imageNamed:@"icon_more_docs"];
                backgroundView = [[UIImageView alloc] initWithImage:[UIImage stretchableImageWithImageName:@"more_docs_btn_bg" leftCapWidth:5 topCapHeight:2]];
                backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                self.backgroundView = backgroundView;
                [backgroundView release];
        }
}
+(CGFloat)optimalHeight {
    return 56.0f;
}
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//    if (selected) {
//        label_.textColor = [UIColor whiteColor];
//        iconImageView_.image = [UIImage imageNamed:@"icon_more_unselected"];
//    }else {
//        label_.textColor = [UIColor blackColor];
//        iconImageView_.image = [UIImage imageNamed:@"icon_more_docs"];
//    }
//}
-(void)setMoreCount:(NSInteger)count {
    label_.text = [NSString stringWithFormat:@"还有%d个文档",count];
}
@end
