//
//  CustomAlertView.m
//  medicalCom
//
//  Created by bird on 14-3-23.
//  Copyright (c) 2014年 小熊. All rights reserved.
//

#import "CustomAlertView.h"
#import "KDCommon.h"

static const CGFloat CustomAlertViewButtonHeight = 40;

@interface CustomAlertView() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UILabel *titleName;
@property (nonatomic, retain) UITableView *mainView;
@property (nonatomic, retain) UIControl *controlForDismiss;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) UIButton *doneButton;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic, assign) CustomAlertViewType type;

@end

@implementation CustomAlertView
@synthesize textField = _textField;
@synthesize delegate = _delegate;
@synthesize titleName = _titleName;
@synthesize mainView = _mainView;
@synthesize cancelButton = _cancelButton;
@synthesize controlForDismiss = _controlForDismiss;
@synthesize doneButton = _doneButton;
@synthesize message = _message;

- (id)initWithDelegate:(id<CustomAlertViewDelegate>)delegate alertType:(CustomAlertViewType)type meesage:(NSString *)msg title:(NSString *)title subTitle:(NSString *)subTitle cancelButtonTitle:(NSString *)firstTitle doneButtonTitle:(NSString *)secondTitle
{

    CGRect rect = CGRectMake(0, 0, 260, 165);
    if (type == CustomAlertViewTypeInputAlert) {
        rect.size.height = 185.f;
    }
    
    self = [super initWithFrame:rect];
    if (self) {
        // Initialization code
        self.type = type;
        self.message = msg;
        self.subTitle = subTitle;
        self.delegate = delegate;
        
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 5.0f;
        self.clipsToBounds = TRUE;
        
        _titleName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleName.font = [UIFont boldSystemFontOfSize:16.0f];
        self.titleName.backgroundColor = UIColorFromRGB(0xfafafa);
        
        self.titleName.textAlignment = NSTextAlignmentLeft;
        self.titleName.textColor = MESSAGE_TOPIC_COLOR;
        CGFloat xWidth = self.bounds.size.width;
        self.titleName.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleName.frame = CGRectMake(0, 12, xWidth, 32.0f);
        self.titleName.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.titleName];
        
        self.titleName.text = title;
        
        CGRect tableFrame = CGRectMake(0, CGRectGetMaxY(_titleName.frame), xWidth, self.bounds.size.height-32.0f);
        _mainView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        self.mainView.dataSource = self;
        self.mainView.delegate = self;
        _mainView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainView.allowsSelection = NO;
        _mainView.scrollEnabled = NO;
        
        _mainView.backgroundColor =  UIColorFromRGB(0xfafafa);
        
        [self addSubview:self.mainView];
        if (firstTitle) {
            [self setCancelButtonTitle:firstTitle];
        }
        if (secondTitle) {
            [self setDoneButtonWithTitle:secondTitle];
        }
        
        self.backgroundColor = UIColorFromRGB(0xfafafa);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    [_textField release];
    //[super dealloc];
}

- (void)refreshTheUserInterface
{
    self.mainView.frame = CGRectMake(0, CGRectGetMaxY(_titleName.frame), self.mainView.frame.size.width, self.mainView.frame.size.height - CustomAlertViewButtonHeight);
    
    if (self.doneButton) {
        
        CGFloat width = self.bounds.size.width / 2.0f;
        if (!_cancelButton) {
            width = width*2;
        }
        
        self.doneButton.frame = CGRectMake(self.bounds.size.width / 2.0f, self.bounds.size.height - CustomAlertViewButtonHeight, width, CustomAlertViewButtonHeight-3);
    }
    if (self.cancelButton) {
        
        CGFloat width = self.bounds.size.width / 2.0f;
        if (!_doneButton) {
            width = width*2 - 30.f;
            
            self.cancelButton.frame = CGRectMake(15.f, self.bounds.size.height - CustomAlertViewButtonHeight - 15.f, width, CustomAlertViewButtonHeight);
            
            _cancelButton.layer.borderWidth = 0.5;
            _cancelButton.layer.borderColor = [[UIColor colorWithRed:20/255.f green:20/255.f blue:20/255.f alpha:0.3] CGColor];
            _cancelButton.layer.cornerRadius = 3.f;

        }
        else
        {
            self.cancelButton.frame = CGRectMake(0, self.bounds.size.height - CustomAlertViewButtonHeight, width, CustomAlertViewButtonHeight);
        }
    }

    
    UIView *topLine =  [self viewWithTag:0x99];
    UIView *midLine =  [self viewWithTag:0x98];
    if (!topLine ) {
        topLine = [[UIView alloc] initWithFrame:CGRectZero];
        topLine.backgroundColor = [UIColor colorWithRed:20/255.f green:20/255.f blue:20/255.f alpha:0.2];
        topLine.tag = 0x99;
        [self addSubview:topLine];
//        [topLine release];
    }
    
    if (!midLine ) {
        midLine = [[UIView alloc] initWithFrame:CGRectZero];
        midLine.tag = 0x98;
        midLine.backgroundColor = [UIColor colorWithRed:20/255.f green:20/255.f blue:20/255.f alpha:0.2];
        [self addSubview:midLine];
//        [midLine release];
    }
    
    if (self.doneButton && self.cancelButton) {
        topLine.frame = CGRectMake(0, self.bounds.size.height - CustomAlertViewButtonHeight, self.bounds.size.width, 0.5);
        midLine.frame = CGRectMake(self.bounds.size.width / 2.0f, self.bounds.size.height - CustomAlertViewButtonHeight, 0.5, CustomAlertViewButtonHeight);
    }
    else
    {
        midLine.frame = CGRectZero;
        topLine.frame = CGRectZero;
    }
    
    if (nil == _controlForDismiss)
    {
        _controlForDismiss = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _controlForDismiss.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:.5];
        [_controlForDismiss addTarget:self action:@selector(touchForDismissSelf:) forControlEvents:UIControlEventTouchUpInside];
    }

}
#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_type == CustomAlertViewTypeInputAlert) {
        return 3;
    }
    else if(_type == CustomAlertViewTypeTitleAlert)
    {
        return 2;
    }
    
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (_type == CustomAlertViewTypeInputAlert) {
        
        if (indexPath.row == 0) {
            return 23.f;
        }
        else if(indexPath.row ==1){
            return 23.f;
        }
        return 60.f;
    }
    else{
    
        if (indexPath.row == 0) {
            return 23.f;
        }
        return 60.f;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellSelectionStyleDefault reuseIdentifier:CellIdentifier] ;//autorelease];
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 20.f, 23.f)];
        textLabel.font = [UIFont systemFontOfSize:14.f];
        textLabel.textColor = MESSAGE_TOPIC_COLOR;
        textLabel.numberOfLines = 1;
        textLabel.backgroundColor = [UIColor clearColor];
        
        [cell.contentView addSubview:textLabel];
//        [textLabel release];
        textLabel.tag = 0x99;
        
    }
    if (indexPath.row ==0) {
        UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:0x99];
        textLabel.textAlignment = NSTextAlignmentCenter;
        if (_type == CustomAlertViewTypeTitleAlert)
            textLabel.textAlignment = NSTextAlignmentCenter;

        textLabel.text = _message;
    }
    else if(indexPath.row == 1){
    
        UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:0x99];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.text = _subTitle;
    }
    else
    {
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(10, 8, tableView.bounds.size.width - 20.f, 35)];
        field.borderStyle = UITextBorderStyleNone;
        field.layer.borderWidth = 0.5;
        field.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
        field.layer.cornerRadius = 3.f;
        field.secureTextEntry = YES;
        [cell addSubview:field];
        field.returnKeyType = UIReturnKeyDefault;
        field.backgroundColor = [UIColor whiteColor];
        field.delegate = self;
//        [field release];
        
        self.textField = field;
    }
    return cell;
}

#pragma mark - Button Method
- (void)setCancelButtonTitle:(NSString *)aTitle
{
    if (nil == _cancelButton)
    {
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.cancelButton setBackgroundImage:[CustomAlertView cancelButtonBackgroundImage] forState:UIControlStateNormal];
        
        [self.cancelButton setTitleColor:UIColorFromRGB(0x1a85ff) forState:UIControlStateNormal];
        [self.cancelButton setBackgroundColor:[UIColor whiteColor]];
        [self.cancelButton addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelButton];
    }
    [self.cancelButton setTitle:aTitle forState:UIControlStateNormal];
}

- (void)setDoneButtonWithTitle:(NSString *)aTitle
{
    if (nil == _doneButton)
    {
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.doneButton setBackgroundImage:[CustomAlertView normalButtonBackgroundImage] forState:UIControlStateNormal];
        [self.doneButton setTitleColor:UIColorFromRGB(0x1a85ff) forState:UIControlStateNormal];
        [self.doneButton setBackgroundColor:[UIColor whiteColor]];
        [self.doneButton addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.doneButton];
    }
    [self.doneButton setTitle:aTitle forState:UIControlStateNormal];
}


+ (UIImage *)normalButtonBackgroundImage
{
	CGFloat opacity = 1.0;
    CGFloat locations[4] = { 0.0, 0.5, 0.5 + 0.0001, 1.0 };
    CGFloat components[4 * 4] = {
		179/255.0, 185/255.0, 199/255.0, opacity,
		121/255.0, 132/255.0, 156/255.0, opacity,
		87/255.0, 100/255.0, 130/255.0, opacity,
		108/255.0, 120/255.0, 146/255.0, opacity,
	};
	return [self glassButtonBackgroundImageWithGradientLocations:locations
													  components:components
												   locationCount:4];
}

+ (UIImage *)cancelButtonBackgroundImage
{
	CGFloat opacity = 1.0;
    CGFloat locations[4] = { 0.0, 0.5, 0.5 + 0.0001, 1.0 };
    CGFloat components[4 * 4] = {
		164/255.0, 169/255.0, 184/255.0, opacity,
		77/255.0, 87/255.0, 115/255.0, opacity,
		51/255.0, 63/255.0, 95/255.0, opacity,
		78/255.0, 88/255.0, 116/255.0, opacity,
	};
	return [self glassButtonBackgroundImageWithGradientLocations:locations
													  components:components
												   locationCount:4];
}

+ (UIImage *)glassButtonBackgroundImageWithGradientLocations:(CGFloat *)locations
												  components:(CGFloat *)components
											   locationCount:(NSInteger)locationCount
{
	const CGFloat lineWidth = 1;
	const CGFloat cornerRadius = 4;
	UIColor *strokeColor = [UIColor colorWithRed:1/255.0 green:11/255.0 blue:39/255.0 alpha:1.0];
	
	CGRect rect = CGRectMake(0, 0, cornerRadius * 2 + 1, CustomAlertViewButtonHeight);
    
	BOOL opaque = NO;
    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, [[UIScreen mainScreen] scale]);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, locationCount);
	
	CGRect strokeRect = CGRectInset(rect, lineWidth * 0.5, lineWidth * 0.5);
	UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:strokeRect cornerRadius:cornerRadius];
	strokePath.lineWidth = lineWidth;
	[strokeColor setStroke];
	[strokePath stroke];
	
	CGRect fillRect = CGRectInset(rect, lineWidth, lineWidth);
	UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:cornerRadius];
	[fillPath addClip];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	CGFloat capHeight = floorf(rect.size.height * 0.5);
	return [image resizableImageWithCapInsets:UIEdgeInsetsMake(capHeight, cornerRadius, capHeight, cornerRadius)];
}



#pragma mark - show or hide self
- (void)show
{
    [self refreshTheUserInterface];
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    if (self.controlForDismiss)
    {
        [keywindow addSubview:self.controlForDismiss];
    }

    [keywindow addSubview:self];
    
    self.center = CGPointMake(keywindow.bounds.size.width/2.0f,
                              keywindow.bounds.size.height/2.0f);
    [self animatedIn];
}

- (void)dismiss
{
    
    [self animatedOut];
}

#pragma mark - Animated Mthod
- (void)animatedIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        if (_type == CustomAlertViewTypeInputAlert)
            [_textField becomeFirstResponder];
    }];
}

- (void)animatedOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            if (self.controlForDismiss)
            {
                [self.controlForDismiss removeFromSuperview];
            }

            [self removeFromSuperview];
        }
    }];
}
- (void)touchForDismissSelf:(id)sender
{
    [self animatedOut];
}
- (void)buttonWasPressed:(id)sender
{
    if ([sender isEqual:_cancelButton]) {
        if (_delegate && [_delegate respondsToSelector:@selector(buttonClick:atIndex:)]) {
            [_delegate buttonClick:self atIndex:0];
        }
    }
    else if([sender isEqual:_doneButton])
    {
        if (_delegate && [_delegate respondsToSelector:@selector(buttonClick:atIndex:)]) {
            [_delegate buttonClick:self atIndex:1];
        }
    }
    [self dismiss];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardRect = [aValue CGRectValue];

	UIWindow *window = [[UIApplication sharedApplication] keyWindow];

	CGRect fieldRect = self.frame;
	if (CGRectGetMaxY(fieldRect) > keyboardRect.origin.y) {
		CGRect rect  = self.frame;
		rect.origin.y -= CGRectGetMaxY(fieldRect) - keyboardRect.origin.y;
		if (isAboveiPhone5) {
			rect.origin.y -= 36.f;
		}
		else {
			rect.origin.y -= 10.f;
		}
		[UIView beginAnimations:@"KeyBoard" context:nil];
		[UIView setAnimationDuration:0.2];
		//在这里调整UI位置
		[self setFrame:rect];
		[UIView commitAnimations];
	}
	else {
		[UIView beginAnimations:@"KeyBoard" context:nil];
		[UIView setAnimationDuration:0.2];
		//在这里调整UI位置
		self.center = window.center;
		[UIView commitAnimations];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}
@end
