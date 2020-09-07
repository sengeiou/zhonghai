//
//  KDPersonDetailCell.m
//  kdweibo
//
//  Created by shen kuikui on 14-4-22.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDPersonDetailCell.h"

#define TOP_LINE_TAG      101
#define LEFT_LINE_TAG     102
#define BOTTOM_LINE_TAG   103
#define RIGH_LINE_TAG     104

#define IN_VALID_RECT     (CGRectMake(MAXFLOAT, MAXFLOAT, MAXFLOAT, MAXFLOAT))

NS_INLINE UIView * borderView(NSInteger tag) {
    UIView *v = [[UIView alloc] init];
    v.tag = tag;
    v.backgroundColor = RGBCOLOR(0xdd, 0xdd, 0xdd);
    
    return v ;//autorelease];
}

@interface KDPersonDetailCell()

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *valueLabel;

@property (nonatomic, retain) UIImageView *accessoryImageView;

@property (nonatomic, retain) UIButton *messageButton;
@property (nonatomic, retain) UIButton *phoneButton;
@property (nonatomic, retain) UIButton *emailButton;

@property (nonatomic, assign) CGRect   originalRect;
           
@end

@implementation KDPersonDetailCell

@synthesize contentEdgeInsets = contentEdgeInsets_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self setupViews];
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        self.separatorLineInset = UIEdgeInsetsMake(0, 15, 0, 0);
        _dataIndex = 1000;
        self.showOrganization = NO;
    }
    
    return self;
}

- (void)setupViews
{
    self.backgroundColor = MESSAGE_CT_COLOR;
    _isBottom = NO;
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.backgroundColor = [UIColor clearColor];
//    _nameLabel.textColor = MESSAGE_NAME_COLOR;
    _nameLabel.textColor = [UIColor kdTextColor2];
    _nameLabel.font = [UIFont systemFontOfSize:14.0f];
    _nameLabel.numberOfLines = 2;
//    _nameLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:_nameLabel];
    
    _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_edit_arrow.png"]];
    [self.contentView addSubview:_accessoryImageView];
    
    _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _valueLabel.backgroundColor = [UIColor clearColor];
    //    _valueLabel.textColor = MESSAGE_TOPIC_COLOR;
    _valueLabel.textColor = [UIColor kdTextColor1];
    _valueLabel.font = [UIFont systemFontOfSize:16.0f];
//    _valueLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:_valueLabel];
    
    self.messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_messageButton setImage:[UIImage imageNamed:@"user_btn_message.png"] forState:UIControlStateNormal];
    [_messageButton setImage:[UIImage imageNamed:@"user_btn_message_press.png"] forState:UIControlStateHighlighted];
    [_messageButton addTarget:self action:@selector(messageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_messageButton sizeToFit];
    [self.contentView addSubview:_messageButton];
    
    self.phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_phoneButton setImage:[UIImage imageNamed:@"user_btn_call.png"] forState:UIControlStateNormal];
    [_phoneButton setImage:[UIImage imageNamed:@"user_btn_call_press.png"] forState:UIControlStateHighlighted];
    [_phoneButton addTarget:self action:@selector(phoneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_phoneButton sizeToFit];
    [self.contentView addSubview:_phoneButton];
    
    self.emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_emailButton setImage:[UIImage imageNamed:@"user_btn_mail.png"] forState:UIControlStateNormal];
    [_emailButton setImage:[UIImage imageNamed:@"user_btn_mail_press.png"] forState:UIControlStateHighlighted];
    [_emailButton addTarget:self action:@selector(emailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_emailButton sizeToFit];

    [self.contentView addSubview:_emailButton];
    
    self.originalRect = IN_VALID_RECT;
    
//    //set up border
//    [self addSubview:borderView(TOP_LINE_TAG)];
//    [self addSubview:borderView(LEFT_LINE_TAG)];
//    [self addSubview:borderView(BOTTOM_LINE_TAG)];
//    [self addSubview:borderView(RIGH_LINE_TAG)];
    [self.contentView addSubview:self.pressImageView];
    autolayoutSetCenterY(self.pressImageView);
    autolayoutSetCenterX(self.pressImageView);
    
}

- (void)setFrame:(CGRect)frame
{
    if(CGRectEqualToRect(self.originalRect, IN_VALID_RECT)) {
        self.originalRect = frame;
    }
    
//    if(CGRectEqualToRect(self.originalRect, frame)) {
//        frame.origin.x += contentEdgeInsets_.left;
//        frame.origin.y += contentEdgeInsets_.top;
//        frame.size.width -= (contentEdgeInsets_.left + contentEdgeInsets_.right);
//        frame.size.height -= (contentEdgeInsets_.top + contentEdgeInsets_.bottom);
//    }
    
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
//    _nameLabel.highlighted = selected;
//    _valueLabel.highlighted = selected;
//    _accessoryImageView.highlighted = selected;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat cvWidth = CGRectGetWidth(self.contentView.frame);
    CGFloat cvHeight = CGRectGetHeight(self.contentView.frame);
    _nameLabel.frame = CGRectMake(15.0f, 0, cvWidth*0.3, cvHeight);
    
    if(!_accessoryImageView.hidden) {
        _accessoryImageView.frame = CGRectMake(cvWidth - CGRectGetWidth(_accessoryImageView.bounds) - 13.0f, (cvHeight - CGRectGetHeight(_accessoryImageView.bounds)) * 0.5f, CGRectGetWidth(_accessoryImageView.bounds), CGRectGetHeight(_accessoryImageView.bounds));
    }else {
        _accessoryImageView.frame = CGRectMake(cvWidth, 0, 0, 0);
    }
    
    __block CGFloat offsetToRight = 13.0f;
    
    offsetToRight += (cvWidth - CGRectGetMinX(_accessoryImageView.frame));
    
    NSArray *btns = @[_emailButton, _phoneButton, _messageButton];
    [btns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)obj;
            
            if(!btn.hidden) {
//                btn.frame = CGRectMake(cvWidth - offsetToRight - CGRectGetWidth(btn.bounds), (cvHeight - CGRectGetHeight(btn.bounds)) * 0.5f, CGRectGetWidth(btn.bounds), CGRectGetHeight(btn.bounds));
//                offsetToRight += CGRectGetWidth(btn.bounds);
//                offsetToRight += 28.0f;
                btn.frame = CGRectMake(cvWidth - offsetToRight - cvHeight, 0 , cvHeight, cvHeight);
                offsetToRight += cvHeight;
                offsetToRight += 0;
            }
        }
    }];
    
    _valueLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame)+10, (cvHeight - CGRectGetHeight(_valueLabel.bounds)) * 0.5f, CGRectGetMinX(_accessoryImageView.frame) - CGRectGetMaxX(_nameLabel.frame)-10, CGRectGetHeight(_valueLabel.bounds));
    
//    UIView *top = [self viewWithTag:TOP_LINE_TAG];
//    if(top) {
//        top.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0.5f);
//    }
//    
//    UIView *left = [self viewWithTag:LEFT_LINE_TAG];
//    if(left) {
//        left.frame = CGRectMake(0, 0, 0.5f, CGRectGetHeight(self.bounds));
//    }
//    
//    UIView *bottom = [self viewWithTag:BOTTOM_LINE_TAG];
//    if(bottom) {
//        bottom.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 0.5f, CGRectGetWidth(self.bounds), 0.5f);
//        bottom.hidden = !_isBottom;
//    }
//    
//    UIView *right = [self viewWithTag:RIGH_LINE_TAG];
//    if(right) {
//        right.frame = CGRectMake(CGRectGetWidth(self.bounds) - 0.5f, 0.0f, 0.5f, CGRectGetHeight(self.bounds));
//    }
}

- (void)setContact:(ContactDataModel *)contact
{
    if(contact != _contact) {
//        [_contact release];
        _contact = contact;// retain];
        
        [self setNeedsLayout];
        
        _nameLabel.text = [_contact formatedTextName];
        [_nameLabel sizeToFit];
        
        _valueLabel.text = _contact.cvalue;
        [_valueLabel sizeToFit];
        
        _messageButton.hidden  = YES;
        _phoneButton.hidden = YES;
        _emailButton.hidden = YES;
//        _messageButton.hidden = (_contact.ctype != ContactCellPhone);
//        _phoneButton.hidden = (_contact.ctype != ContactCellPhone && _contact.ctype != ContactHomePhone);
//        _emailButton.hidden = (_contact.ctype != ContactEmail);
    }
}

- (void)messageButtonAction:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(personDetailCellMessageButtonPressed:)]) {
        [_delegate personDetailCellMessageButtonPressed:self];
    }
}

- (void)phoneButtonAction:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(personDetailCellPhoneButtonPressed:)]) {
        [_delegate personDetailCellPhoneButtonPressed:self];
    }
}

- (void)emailButtonAction:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(personDetailCellEmailButtonPressed:)]) {
        [_delegate personDetailCellEmailButtonPressed:self];
    }
}

- (void)setBottom:(BOOL)isBottom
{
    if(_isBottom != isBottom) {
        _isBottom = isBottom;
        
        UIView *bottom = [self viewWithTag:BOTTOM_LINE_TAG];
        if(bottom) {
            bottom.hidden = !_isBottom;
        }
    }
}
- (UIImageView *)pressImageView {
    if (_pressImageView == nil) {
        _pressImageView = [[UIImageView alloc] init];
        _pressImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _pressImageView;
}
- (void)setDataIndex:(NSInteger)dataIndex
{
    if (_dataIndex != dataIndex) {
        _dataIndex = dataIndex;
    }
}

- (void)setShowOrganization:(BOOL)showOrganization
{
    if (_showOrganization != showOrganization) {
        _showOrganization = showOrganization;
    }
}
- (void)dealloc
{
    //KD_RELEASE_SAFELY(_contact);
    //KD_RELEASE_SAFELY(_nameLabel);
    //KD_RELEASE_SAFELY(_valueLabel);
    //KD_RELEASE_SAFELY(_messageButton);
    //KD_RELEASE_SAFELY(_phoneButton);
    //KD_RELEASE_SAFELY(_emailButton);
    //KD_RELEASE_SAFELY(_accessoryImageView);
    
    //[super dealloc];
}


@end
