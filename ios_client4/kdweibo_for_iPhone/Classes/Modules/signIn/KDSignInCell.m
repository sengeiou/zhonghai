//
//  KDSignInCell.m
//  kdweibo
//
//  Created by 王 松 on 13-8-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDSignInCell.h"
#import "BOSConfig.h"

#define kLableWith 217

#define kKDSignInCellMaxLabelSize CGSizeMake(217.,9999.f)
#define kLocationLabelHeight 30.f
#define kMinimumVelocity  self.frame.size.width*1.5
#define kMinimumPan       60.0
#define kBOUNCE_DISTANCE  7.0
#define signInFailureImageViewWidth 15

@implementation KDSignInCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellStyle = kSigninStyleGray;
        [self initCell];
    }
    return self;
}

- (void)initCell {
    self.backgroundColor = [UIColor clearColor];
    _innerView = [[KDSigninCellInnerView alloc] initWithFrame:CGRectZero];
    _innerView.cell = self;
    [self.contentView.superview setClipsToBounds:NO];
    [[self contentView] addSubview:_innerView];
    [_innerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo([self contentView]);
        make.bottom.mas_equalTo([self contentView]).with.offset(-14);
    }];
}

- (void)setRecord:(KDSignInRecord *)record {
    if (record != _record) {
        _record = record;
        _innerView.record = _record;
    }
}

- (void)setCellStyle:(SigninStyle)cellStyle {
    _cellStyle = cellStyle;
    _innerView.cellStyle = cellStyle;
}

- (void)setDelegate:(id <KDSignInCellDelegate>)delegate {
    if (delegate != _delegate) {
        _delegate = delegate;
        _innerView.delegate = _delegate;
    }
}

- (void)setPhotoSignInCollectionViewDelegate:(id <KDPhotoSignInPhotoCollectionViewDelegate>)photoSignInCollectionViewDelegate {
    _photoSignInCollectionViewDelegate = photoSignInCollectionViewDelegate;
    _innerView.photoSignInCollectionViewDelegate = _photoSignInCollectionViewDelegate;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)slideInContentView {
    [_innerView slideInContentView];
}

- (void)slideOutContentView {
    [_innerView slideOutContentView];
}

- (void)setGestureEnable:(BOOL)enable {
    [_innerView setGestureEnable:enable];
}

+ (CGFloat)cellHeightByString:(NSString *)record withMinHeigh:(CGFloat)min {
    CGRect rect = [record boundingRectWithSize:kKDSignInCellMaxLabelSize options:NSStringDrawingTruncatesLastVisibleLine attributes:nil context:nil];
    
    return  rect.size.height > min ? rect.size.height : min;
}

+ (CGFloat)cellHeightByContentString:(NSString *)record withMinHeigh:(CGFloat)min {
    
    CGRect rect = [record boundingRectWithSize:CGSizeMake(ScreenFullWidth- 32-22 - 50 - 5, 500) options:NSStringDrawingTruncatesLastVisibleLine attributes:nil context:nil];
    return  rect.size.height > min ? rect.size.height : min;
}

+ (CGFloat)cellHeightByRecord:(KDSignInRecord *)record {
    CGRect rect;
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:record.featurename];
    [attributedString addAttributes:@{NSFontAttributeName :FS6} range:NSMakeRange(0, record.featurename.length)];
    if ([self isRecordPhotoSignInRecord:record])
    {
        if(record.status == -1)
        {
            rect = [attributedString boundingRectWithSize:CGSizeMake(ScreenFullWidth - 50 - 25 - 16 - 48 - 12 - signInFailureImageViewWidth, 100) options:options context:nil];
        }else{
            rect = [attributedString boundingRectWithSize:CGSizeMake(ScreenFullWidth - 50 - 25 - 16 - 48 - 12, 100) options:options context:nil];
        }
    }else{
        rect = [attributedString boundingRectWithSize:CGSizeMake(ScreenFullWidth - 50 - 25 - 16 * 2, 100) options:options context:nil];
    }
    CGFloat height = 8 + 30 + 2 + ceilf(rect.size.height) + 8;
    
    if (height < 65) {
        height = 65;
    }
    
    return height;
}

+ (BOOL)isRecordPhotoSignInRecord:(KDSignInRecord *)record {
    if (record && record.photoIds && ![record.photoIds isKindOfClass:[NSNull class]] && record.photoIds.length > 0) {
        return YES;
    } else {
        if (record && record.cachesUrl && ![record.cachesUrl isKindOfClass:[NSNull class]] &&record.cachesUrl.length > 0) {
            return YES;
        }
        return NO;
    }
}
@end


@implementation KDSigninCellInnerView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initCell];
    }
    return self;
}

- (void)initCell {
    _clipBoundView = [[UIView alloc] initWithFrame:CGRectZero];
    _clipBoundView.layer.cornerRadius = 6;
    _clipBoundView.layer.masksToBounds = YES;
    _clipBoundView.clipsToBounds = YES;
    
    _dotView = [[UIView alloc] initWithFrame:CGRectZero];
    _dotView.layer.cornerRadius = 4.5;
    _dotView.layer.masksToBounds = YES;
    
    _bgView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _signInFailureImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _signInFailureImageView.image = [UIImage imageNamed:@"sign_btn_mark_normal"];
    _signInFailureImageView.hidden = YES;
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _contentLabel.textColor = FC2;
    _contentLabel.font = FS3;
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.font = [UIFont systemFontOfSize:30];
    
    _signTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _signTypeLabel.backgroundColor = [UIColor clearColor];
    _signTypeLabel.font = FS6;
    _signTypeLabel.text = ASLocalizedString(@"外勤签到");
    
    _locationNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _locationNameLabel.backgroundColor = [UIColor clearColor];
    _locationNameLabel.font = FS6;
    _locationNameLabel.textAlignment = NSTextAlignmentLeft;
    _locationNameLabel.numberOfLines = 0;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 10;
    _photoCollectionView = [[KDPhotoSignInPhotoCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _photoCollectionView.hidden = YES;
    _photoCollectionView.userInteractionEnabled = YES;
    
    [_bgView addSubview:_timeLabel];
    [_bgView addSubview:_signTypeLabel];
    [_bgView addSubview:_locationNameLabel];
    [_bgView addSubview:_contentLabel];
    [_bgView addSubview:_photoCollectionView];
    [_bgView addSubview:_signInFailureImageView];
    [_clipBoundView addSubview:_bgView];
    [self addSubview:_dotView];
    [self addSubview:_clipBoundView];
    
    [_dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).with.offset(-20 - 4.5);
        make.centerY.mas_equalTo(self.mas_centerY).with.offset(0);
        make.width.mas_equalTo(9);
        make.height.mas_equalTo(9);
    }];
    
    [_clipBoundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).with.insets(UIEdgeInsetsZero);
    }];
    
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_clipBoundView).with.insets(UIEdgeInsetsZero);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_bgView).with.offset(16);
        make.top.mas_equalTo(_bgView).with.offset(8);
        make.width.mas_equalTo(87);
        make.height.mas_equalTo(30);
    }];
    
    [_signTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_timeLabel).with.offset(-2);
        make.left.mas_equalTo(_timeLabel.right).with.offset(2);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(80);
    }];
    
    [_locationNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_bgView).with.offset(16);
        make.top.mas_equalTo(_timeLabel.bottom).with.offset(2);
        make.right.mas_equalTo(_bgView).with.offset(-16);
        make.bottom.mas_equalTo(_bgView).with.offset(-8);
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_bgView).with.offset(12);
        make.right.mas_equalTo(_bgView).with.offset(-12);
        make.top.mas_equalTo(_bgView).with.offset(8);
        make.bottom.mas_equalTo(_bgView).with.offset(-8);
    }];
    
    [_photoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_bgView).with.offset(-12);
        make.centerY.mas_equalTo(_bgView.mas_centerY);
        make.height.mas_equalTo(KDPhotoSignInCollectionViewCellWidth);
        make.width.mas_equalTo(KDPhotoSignInCollectionViewCellWidth);
    }];
    
    [_signInFailureImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_bgView).with.offset(-6);
        make.centerY.mas_equalTo(_bgView.mas_centerY).with.offset(0);
        make.height.mas_equalTo(signInFailureImageViewWidth);
        make.width.mas_equalTo(signInFailureImageViewWidth);
    }];
    
    [self setGestureEnable:YES];
}

- (void)setGestureEnable:(BOOL)enable {
    if (!enable) {
        [_bgView removeGestureRecognizer:_panGestureRecognizer];
        [_bgView removeGestureRecognizer:_tapGestureRecognizer];
    } else {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        _panGestureRecognizer.delegate = self;
        [_bgView addGestureRecognizer:_panGestureRecognizer];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSlider:)];
        [_bgView addGestureRecognizer:_tapGestureRecognizer];
    }
}

- (void)setRecord:(KDSignInRecord *)record {
    if (record != _record) {
        _record = record;
        [self setComponentRecord];
    }
}

- (void)setCellStyle:(SigninStyle)cellStyle {
    _cellStyle = cellStyle;
    
    if (_cellStyle == kSigninStyleBlue)
    {
        _dotView.backgroundColor = FC5;
        _bgView.backgroundColor = FC5;
        _timeLabel.textColor = FC6;
        _locationNameLabel.textColor = FC6;
        _signTypeLabel.textColor = [UIColor colorWithRGB:0xffffff alpha:0.6];
    }
    else{
        _dotView.backgroundColor = [UIColor colorWithRGB:0xdce1e8];
        _bgView.backgroundColor = [UIColor kdBackgroundColor7];
        _timeLabel.textColor = FC2;
        _locationNameLabel.textColor = FC2;
        _signTypeLabel.textColor = FC3;
    }
    
    [self layoutBottomView];
}

- (void)setComponentRecord {
    
    if (_record && [_record.content length] > 0 && _record.featurename.length <= 0 && ([_record.content isEqualToString:ASLocalizedString(@"新的一天从打卡开始\n分享你的工作时间，晒晒你的劳模表单！")] || [_record.content isEqualToString:ASLocalizedString(@"我能管理小伙伴的内外勤工作.\n还能帮你核算工时,\n让考勤更简单,快试试吧!")])) {
        _contentLabel.text = _record.content;
        _timeLabel.hidden = YES;
        _signTypeLabel.hidden = YES;
        _locationNameLabel.hidden = YES;
        _photoCollectionView.hidden = YES;
        _dotView.backgroundColor = FC5;
    } else {
        _contentLabel.hidden = YES;
        _timeLabel.hidden = NO;
        _locationNameLabel.hidden = NO;
        
        if(_record.status != -1)
        {
            _signInFailureImageView.hidden = YES;
            if ([self isRecordPhotoSignIn])
            {
                self.photoCollectionView.hidden = NO;
                [_photoCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(_bgView).with.offset(-12);
                }];
                [_locationNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(_bgView).with.offset(-60);
                }];
            }else{
                self.photoCollectionView.hidden = YES;
                [_locationNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(_bgView).with.offset(-16);
                }];
            }
        }
        else{
            _signInFailureImageView.hidden = NO;
            if ([self isRecordPhotoSignIn])
            {
                self.photoCollectionView.hidden = NO;
                [_photoCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(_bgView).with.offset(-12 - signInFailureImageViewWidth);
                }];
                [_locationNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(_bgView).with.offset(-60 - signInFailureImageViewWidth);
                }];
            }else{
                self.photoCollectionView.hidden = YES;
                [_locationNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(_bgView).with.offset(-16);
                }];
            }
        }
        
        if (_record.featurename.length > 0) {
            NSCalendar *gregorian = [[NSCalendar alloc]
                                     initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *weekdayComponents =
            [gregorian components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:_record.singinTime];
            NSInteger hour = [weekdayComponents hour];
            NSInteger minute = [weekdayComponents minute];
            NSString *timeAndLoc = [NSString stringWithFormat:@"%02ld:%02ld",(long) hour, (long) minute];
            _timeLabel.text = timeAndLoc;
            _locationNameLabel.text = _record.featurename;
            
            if ([self.record.clockInType isEqualToString:@"photo"]) {
                _signTypeLabel.hidden = NO;
                _signTypeLabel.text = ASLocalizedString(@"拍照签到");
            }
            else {
                if (_record.status == 0) {
                    _signTypeLabel.hidden = NO;
                    _signTypeLabel.text = ASLocalizedString(@"外勤签到");
                }
                else {
                    _signTypeLabel.hidden = YES;
                }
            }
        }
        
        if ([self isRecordPhotoSignIn]) {
            if (self.record && self.record.photoIds && self.record.photoIds.length > 0) {
                [_photoCollectionView setPhotoIdsArray:[_record.photoIds componentsSeparatedByString:@","]];
            } else if (self.record && self.record.cachesUrl && self.record.cachesUrl.length > 0) {
                [_photoCollectionView setCacheImagesArray:[_record.cachesUrl componentsSeparatedByString:@","]];
            }
        }
    }
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _originalCenter = _bgView.bounds.size.width / 2;
    
}

- (BOOL)isRecordPhotoSignIn {
    if (self.record && self.record.photoIds && ![self.record.photoIds isKindOfClass:[NSNull class]] && self.record.photoIds.length > 0) {
        return YES;
    } else {
        if (self.record && self.record.cachesUrl && ![self.record.cachesUrl isKindOfClass:[NSNull class]] && self.record.cachesUrl.length > 0) {
            return YES;
        }
        return NO;
    }
}

- (void)layoutBottomView {
    if (!self.bottomLeftView) {
        _bottomLeftView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLeftView.backgroundColor = _cellStyle == kSigninStyleBlue ? [UIColor colorWithRGB:0x2698f0] : [UIColor colorWithRGB:0xe8ecf1];
        UIButton *weiboBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIColor *highColor = (_cellStyle == kSigninStyleBlue ? [UIColor colorWithRGB:0x0a81dd] : [UIColor colorWithRGB:0xd0d3d8]);
        [weiboBtn setImage:(_cellStyle == kSigninStyleBlue ? [UIImage imageNamed:@"sign_btn_share_blue"] : [UIImage imageNamed:@"sign_btn_share_normal"]) forState:UIControlStateNormal];
        [weiboBtn setBackgroundImage:[UIImage kd_imageWithColor:highColor] forState:UIControlStateHighlighted];
        weiboBtn.tag = kSignInWeiboButtonTag;
        [weiboBtn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomLeftView addSubview:weiboBtn];
        [weiboBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.and.bottom.mas_equalTo(_bottomLeftView);
            make.width.mas_equalTo(60);
        }];
        
        [_clipBoundView insertSubview:_bottomLeftView atIndex:0];
        [_bottomLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_clipBoundView).with.insets(UIEdgeInsetsZero);
        }];
    }
}


#pragma mark public

- (void)slideInContentView {
    _lastDirection = KDCellDirectionNone;
    [self _slideInContentViewFromDirection:KDCellDirectionLeft];
    [self _setRevealing:NO];
}

#pragma mark private

- (void)bottomBtnClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellDidClicked:withTag:)]) {
        [self.delegate cellDidClicked:_cell withTag:sender.tag];
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)recognizer {
    //begin pan...
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        _initialTouchPositionX = [recognizer locationInView:_clipBoundView].x;
        _initialHorizontalCenter = _bgView.center.x;
        if (_currentStatus == kStatusNormal) {
            [self layoutBottomView];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) { //status change
        
        
        CGFloat panAmount = _initialTouchPositionX - [recognizer locationInView:_clipBoundView].x;
        CGFloat newCenterPosition = _initialHorizontalCenter - panAmount;
        CGFloat centerX = _bgView.center.x;
        
        
        if (centerX > _originalCenter && _currentStatus != kStatusLeftExpanding) {
            _currentStatus = kStatusLeftExpanding;
            [self togglePanelWithFlag];
        }
        
        if (panAmount > 0) {
            return;
        }
        else {
            _lastDirection = KDCellDirectionRight;
        }
        
        if (newCenterPosition > _clipBoundView.bounds.size.width + _originalCenter) {
            newCenterPosition = _clipBoundView.bounds.size.width + _originalCenter;
        }
        else if (newCenterPosition < -_originalCenter) {
            newCenterPosition = -_originalCenter;
        }
        CGPoint center = _bgView.center;
        center.x = newCenterPosition;
        _bgView.layer.position = center;
        
        
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        
        CGPoint translation = [recognizer translationInView:_clipBoundView];
        CGFloat velocityX = [recognizer velocityInView:_clipBoundView].x;
        
        //判断是否push view
        BOOL isNeedPush = (fabs(velocityX) > kMinimumVelocity);
        
        
        isNeedPush |= ((_lastDirection == KDCellDirectionLeft && translation.x < -kMinimumPan) ||
                       (_lastDirection == KDCellDirectionRight && translation.x > kMinimumPan));
        
        if (velocityX > 0 && _lastDirection == KDCellDirectionLeft) {
            isNeedPush = NO;
        }
        
        else if (velocityX < 0 && _lastDirection == KDCellDirectionRight) {
            isNeedPush = NO;
        }
        
        if (isNeedPush && !self.revealing) {
            
            if (_lastDirection == KDCellDirectionRight) {
                _currentStatus = kStatusLeftExpanding;
                [self togglePanelWithFlag];
                
            }
            
            [self _slideOutContentViewInDirection:_lastDirection];
            [self _setRevealing:YES];
            
        }
        else if (self.revealing && translation.x != 0) {
            
            KDCellDirection direct = _currentStatus == kStatusRightExpanding ? KDCellDirectionLeft : KDCellDirectionRight;
            _lastDirection = direct;
            [self _slideInContentViewFromDirection:direct];
            [self _setRevealing:NO];
            
        }
        else if (translation.x != 0) {
            // Figure out which side we've dragged on.
            KDCellDirection finalDir = KDCellDirectionRight;
            if (translation.x < 0)
                finalDir = KDCellDirectionLeft;
            [self _slideInContentViewFromDirection:finalDir];
            [self _setRevealing:NO];
        }
    }
}

- (void)togglePanelWithFlag {
    switch (_currentStatus) {
        case kStatusLeftExpanding: {
            _bottomLeftView.alpha = 1.0f;
        }
            break;
        case kStatusRightExpanding: {
            _bottomLeftView.alpha = 0.0f;
        }
            break;
        case kStatusNormal: {
            //            [_bottomLeftView removeFromSuperview];
            //            self.bottomLeftView = nil;
        }
        default:
            break;
    }
}


- (void)_slideInContentViewFromDirection:(KDCellDirection)direction {
    
    if (_bgView.center.x == _originalCenter)
        return;
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = _bgView.frame;
        frame.origin.x = 0;
        _bgView.frame = frame;
    } completion:^(BOOL finished) {
        _currentStatus = kStatusNormal;
        [self togglePanelWithFlag];
    }];
}

- (void)toggleSlider:(UITapGestureRecognizer *)gesture {
    CGPoint locate = [gesture locationInView:_bgView];
    locate = [_signInFailureImageView.layer convertPoint:locate fromLayer:_bgView.layer];
    if ([_signInFailureImageView.layer containsPoint:locate]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cellDidClicked:withTag:)]) {
            [self.delegate cellDidClicked:_cell withTag:kdSignInFailuredBtnTag];
        }
    }
    else {
        _lastDirection = KDCellDirectionNone;
        if (_currentStatus == kStatusNormal) {
            [self slideOutContentView];
        } else {
            [self slideInContentView];
        }
    }
    
}

- (void)slideOutContentView {
    if (_currentStatus == kStatusNormal) {
        [self layoutBottomView];
    }
    _lastDirection = KDCellDirectionRight;
    _currentStatus = kStatusLeftExpanding;
    [self togglePanelWithFlag];
    [self _slideOutContentViewInDirection:KDCellDirectionRight];
    [self _setRevealing:YES];
}

- (void)_slideOutContentViewInDirection:(KDCellDirection)direction {
    CGFloat newCenterX = 0.0f;
    CGFloat bounceDistance = 0.0f;
    switch (direction) {
        case KDCellDirectionLeft: {
            return;
        }
            break;
        case KDCellDirectionRight: {
            newCenterX = 60;
            bounceDistance = kBOUNCE_DISTANCE;
            _currentStatus = kStatusRightExpanded;
        }
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = _bgView.frame;
        frame.origin.x = newCenterX;
        _bgView.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            if (_bgView.frame.origin.x != 0) {
                _bgView.frame = CGRectOffset(_bgView.frame, -bounceDistance, 0);
            }
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                if (_bgView.frame.origin.x != 0) {
                    _bgView.frame = CGRectOffset(_bgView.frame, bounceDistance, 0);
                }
            } completion:nil];
        }];
    }];
}

- (void)_setRevealing:(BOOL)revealing {
    _revealing = revealing;
    if (self.revealing && [self.delegate respondsToSelector:@selector(cellDidReveal:)])
        [self.delegate cellDidReveal:_cell];
}


#pragma mark
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _panGestureRecognizer) {
        UIScrollView *superview = (UIScrollView *) self.superview;
        CGPoint translation = [(UIPanGestureRecognizer *) gestureRecognizer translationInView:superview];
        // Make it scrolling horizontally
        return ((fabs(translation.x) / fabs(translation.y) > 1 && (translation.x > 0 || (_lastDirection == KDCellDirectionRight))) ? YES : NO &&
                (superview.contentOffset.y == 0.0 && superview.contentOffset.x == 0.0));
    }
    return YES;
}

- (void)setPhotoSignInCollectionViewDelegate:(id <KDPhotoSignInPhotoCollectionViewDelegate>)photoSignInCollectionViewDelegate {
    _photoSignInCollectionViewDelegate = photoSignInCollectionViewDelegate;
    _photoCollectionView.photoSignInCollectionViewDelegate = photoSignInCollectionViewDelegate;
}


@end
