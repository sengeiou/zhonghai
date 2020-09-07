//
//  KDAttachmentMenuCell.m
//  kdweibo
//
//  Created by shen kuikui on 12-12-28.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDAttachmentMenuCell.h"

@implementation KDAttachmentMenuCell

@synthesize delegate = delegate_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupMenuCell];
    }
    return self;
}

- (void)setupMenuCell {
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];

    UIButton *checkButton = [self buttonWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width * 0.5f, 60.0f) imageName:@"document_view.png" title:ASLocalizedString(@"KDApplicationTableViewCell_check")selector:@selector(view:)];
    UIButton *deleteButton = [self buttonWithFrame:CGRectMake(self.bounds.size.width * 0.5f, 0.0f, self.bounds.size.width * 0.5f, 60.0f) imageName:@"document_delete.png" title:ASLocalizedString(@"KDAttachmentMenuCell_del")selector:@selector(del:)];
    [checkButton setBackgroundColor:[UIColor colorWithRed:213/255.f green:213/255.f blue:213/255.f alpha:1]];
    [deleteButton setBackgroundColor:[UIColor colorWithRed:213/255.f green:213/255.f blue:213/255.f alpha:1]];
    [self.contentView addSubview:checkButton];
    [self.contentView addSubview:deleteButton];
}

- (UIButton *)buttonWithFrame:(CGRect)frame imageName:(NSString *)imageName title:(NSString *)titleName  selector:(SEL)sel {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:frame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = titleName;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:15.0f];
    titleLabel.textColor = MESSAGE_TOPIC_COLOR;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    CGSize size = [titleName sizeWithFont:titleLabel.font];
    
    CGFloat space = 10.0f;
    CGFloat origin_x = (frame.size.width - space - size.width - imageView.image.size.width) * 0.5f;
    
    imageView.frame = CGRectMake(origin_x, 0.0f, imageView.image.size.width, imageView.image.size.height);
    titleLabel.frame = CGRectMake(origin_x + imageView.frame.size.width + space, 0.0f, size.width, size.height);
    
    imageView.center = CGPointMake(imageView.center.x, frame.size.height * 0.5f);
    titleLabel.center = CGPointMake(titleLabel.center.x, frame.size.height * 0.5f);
    
    [btn addSubview:imageView];
//    [imageView release];
    
    [btn addSubview:titleLabel];
//    [titleLabel release];
    
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(highlightedColor:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(normalColor:) forControlEvents:UIControlEventTouchCancel];
    [btn setBackgroundColor:MESSAGE_BG_COLOR];
    return btn;
}
- (void)highlightedColor:(UIButton *)button
{
   [button setBackgroundColor:[UIColor colorWithRed:195/255.f green:195/255.f blue:195/255.f alpha:1]];
}
- (void)normalColor:(UIButton *)button
{
    [button setBackgroundColor:[UIColor colorWithRed:213/255.f green:213/255.f blue:213/255.f alpha:1]];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)view:(UIButton *)button {
    
    [button setBackgroundColor:[UIColor colorWithRed:213/255.f green:213/255.f blue:213/255.f alpha:1]];
    
    if(delegate_ && [delegate_ respondsToSelector:@selector(viewButtonClickedInAttachmentMenuCell:)])
        [delegate_ viewButtonClickedInAttachmentMenuCell:self];
}

- (void)del:(UIButton *)button {
    
    [button setBackgroundColor:[UIColor colorWithRed:213/255.f green:213/255.f blue:213/255.f alpha:1]];
    
    if(delegate_ && [delegate_ respondsToSelector:@selector(deleteButtonClickedInAttachmentMenuCell:)])
        [delegate_ deleteButtonClickedInAttachmentMenuCell:self];
}

@end
