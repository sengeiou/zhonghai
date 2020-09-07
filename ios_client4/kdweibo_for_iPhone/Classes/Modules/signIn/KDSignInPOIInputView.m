//
//  KDSignInPOIInputView.m
//  kdweibo
//
//  Created by AlanWong on 14-9-17.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDSignInPOIInputView.h"
#import "KDSignInManager.h"
#define BACKGROUND_VIEW_WIDTH 280

@interface KDSignInPOIInputView()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property(nonatomic,strong)UIView * backgroundView;
@property(nonatomic,strong)UILabel * tipsLabel;
@property(nonatomic,strong)UIButton * cancelButton;
@property(nonatomic,strong)UIButton * confirmButton;
@property(nonatomic,strong)UITextField * textField;

@property(nonatomic,strong)NSMutableArray * addressList;
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UIView * listMaskView;
@property(nonatomic,strong)UIButton * backgroundButton;


@end
@implementation KDSignInPOIInputView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //获取已经输入过的地址信息
        _addressList = [[NSMutableArray alloc]init];
        [_addressList addObjectsFromArray:[KDSignInManager getAddressList]];
        
        _backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backgroundButton setFrame:frame];
        [_backgroundButton addTarget:self action:@selector(backgroundButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backgroundButton];


        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.7f);
        _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(20, 100, BACKGROUND_VIEW_WIDTH, 180)];
        _backgroundView.backgroundColor = BOSCOLORWITHRGBA(0xFFFFFF, 0.95);
        _backgroundView.layer.cornerRadius = 8.0;
        _backgroundView.hidden = NO;
        [self addSubview:_backgroundView];
        
        _tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(15.0f, 15.0f, 250, 40)];
        _tipsLabel.text = ASLocalizedString(@"KDSignInPOIInputView_tipsLabel_text");
        _tipsLabel.numberOfLines = 2;
        _tipsLabel.font = [UIFont systemFontOfSize:14.0f];
        _tipsLabel.backgroundColor = [UIColor clearColor];
        _tipsLabel.textColor = [UIColor blackColor];
        _tipsLabel.hidden = NO;
        [_backgroundView addSubview:_tipsLabel];
        
        _textField = [self textFieldPlaceHolder:nil dropDownImageName:[self hasLoggedAddresses]?@"login_input_drop_down_signin":nil];
        _textField.delegate = self;
        [_textField setFrame:CGRectMake(35.0f,
                                       CGRectGetMinY(_backgroundView.frame) + 70.0f,
                                       250.0f,
                                        40)];
        [self addSubview:_textField];
        
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:ASLocalizedString(@"Global_Cancel")forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f] ];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_cancelButton sizeToFit];
        [_cancelButton setFrame:CGRectMake(0,
                                           CGRectGetHeight(_backgroundView.frame) - 44,
                                           CGRectGetWidth(_backgroundView.frame) / 2,
                                           44)];
        [_cancelButton addTarget:self action:@selector(cancelButonTap:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.hidden = NO;
        [_backgroundView addSubview:_cancelButton];
        UIView * topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _backgroundView.bounds.size.width / 2, 1)];
        [topLine setBackgroundColor:BOSCOLORWITHRGBA(0xDDDDDD, 1.0f)];
        [_cancelButton addSubview:topLine];
        UIView * rightLine = [[UIView alloc]initWithFrame:CGRectMake(_backgroundView.bounds.size.width / 2 - 0.5, 0, 0.5, 44)];
        [rightLine setBackgroundColor:BOSCOLORWITHRGBA(0xDDDDDD, 1.0f)];
        [_cancelButton addSubview:rightLine];
        
        
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:ASLocalizedString(@"KDBindEmailViewController_submit")forState:UIControlStateNormal];
        [_confirmButton sizeToFit];
        [_confirmButton setFrame:CGRectMake(_backgroundView.bounds.size.width / 2, CGRectGetHeight(_backgroundView.frame) - 44,_backgroundView.bounds.size.width / 2, 44)];
        [_confirmButton addTarget:self action:@selector(confimButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f] ];
        [_confirmButton setTitleColor:BOSCOLORWITHRGBA(0x1A85FF, 1.0f) forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _confirmButton.hidden = NO;
        [_backgroundView addSubview:_confirmButton];
        UIView * topLine2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _backgroundView.bounds.size.width / 2, 1)];
        [topLine2 setBackgroundColor:BOSCOLORWITHRGBA(0xDDDDDD, 1.0f)];
        [_confirmButton addSubview:topLine2];
        UIView * leftLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0.5, 44)];
        [leftLine setBackgroundColor:BOSCOLORWITHRGBA(0xDDDDDD, 1.0f)];
        [_confirmButton addSubview:leftLine];
        
    }
    return self;
}



- (UITextField *)textFieldPlaceHolder:(NSString *)ph dropDownImageName:(NSString *)dropDownImageName {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.backgroundColor = RGBACOLOR(255, 255, 255, 1.0f);
    textField.font = [UIFont systemFontOfSize:14.0f];
    textField.layer.cornerRadius = 5.0f;
    textField.layer.masksToBounds = YES;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.returnKeyType = UIReturnKeyDone;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.textColor = [UIColor blackColor];
    
    textField.placeholder = ph;
    
    
    // right view
    if (dropDownImageName != nil) {
        UIButton *dropDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:dropDownImageName];
        
        dropDownBtn.frame = CGRectMake(0.0, 0.0, 30.0f, 43.0f);
        dropDownBtn.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 7.0f);
        [dropDownBtn setImage:image forState:UIControlStateNormal];
        
        [dropDownBtn addTarget:self action:@selector(showAddressList:) forControlEvents:UIControlEventTouchUpInside];
        textField.rightView = dropDownBtn;
        textField.rightViewMode = UITextFieldViewModeAlways;
        
    } else {
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    
	textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return textField;
}

- (BOOL)hasLoggedAddresses {
    return _addressList != nil && [_addressList count] > 0;
}

- (void)showAddressList:(UIButton *)sender {
//    authViewControllerFlags_.disableInputFieldsAnimation = 1;
    
    CGFloat height = CGRectGetHeight(_textField.frame);
    CGRect rect = _textField.frame;
    rect.origin.x = CGRectGetMinX(_textField.frame);
    rect.origin.y += height;
    rect.size.height = height;
    
    [self loggedInUserPicker:YES anchorRect:rect];
}

- (void)loggedInUserPicker:(BOOL)visible anchorRect:(CGRect)anchorRect {
    if(visible){
        CGRect frame;
        if(_listMaskView == nil){
            frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
            _listMaskView = [[UIView alloc] initWithFrame:frame];
            
            _listMaskView.backgroundColor = [UIColor clearColor];
            _listMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            
        }
        [self addSubview:_listMaskView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissLoggedInAddressPicker:)];
        [_listMaskView addGestureRecognizer:tapGestureRecognizer];
        
        if(_tableView == nil){
            frame = anchorRect;
            frame.size.height = 0.0;
            
            _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
            _tableView.backgroundColor = RGBACOLOR(255, 255, 255, 0.5f);
            _tableView.backgroundView = nil;
            
            _tableView.layer.borderColor = RGBCOLOR(202.0, 202.0, 202.0).CGColor;
            _tableView.layer.borderWidth = 1.0;
            _tableView.layer.cornerRadius = 5.0;
            
            _tableView.delegate = self;
            _tableView.dataSource = self;
            
            _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
            
        }
        [self addSubview:_tableView];
    }
    
    CGFloat height = 0.0;
    if(visible) {
      //  isPickedUser_ = NO;
        _listMaskView.userInteractionEnabled = YES;
        _backgroundButton.userInteractionEnabled = NO;
        
        height = [_addressList count] * 36.0;
        CGFloat visibleHeight = self.bounds.size.height - anchorRect.origin.y;
        if(height < visibleHeight){
            _tableView.scrollEnabled = NO;
        }else {
            _tableView.scrollEnabled = YES;
            height = visibleHeight;
        }
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect rect = _tableView.frame;
                         rect.origin.y = visible ? anchorRect.origin.y : rect.origin.y;
                         rect.size.height = height;
                         
                        
                         

                         _tableView.frame = rect;
                     }
     
                     completion:^(BOOL finished){
   //                      authViewControllerFlags_.signedUsersPickerVisible = visible ? 1 : 0;
                         
                         if(!visible) {
                             for(UITapGestureRecognizer *tap in _listMaskView.gestureRecognizers) {
                                 [_listMaskView removeGestureRecognizer:tap];
                             }
                             
                             [_listMaskView removeFromSuperview];
                             [_tableView removeFromSuperview];
                             
                             _backgroundButton.userInteractionEnabled = YES;
                            }
                     }];
}


/**
 *  在iOS7.0下，UITableViewCell的层级变了
 *
 *
 */
- (void)removeLoggedAddress:(UIButton *)btn {
    UIView *superView = btn.superview;
    
    while (superView && ![superView isKindOfClass:[UITableViewCell class]]) {
        superView = superView.superview;
    }
    
    if([superView isKindOfClass:[UITableViewCell class]]){
        UITableViewCell *cell = (UITableViewCell *)superView;
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        
        [_addressList removeObjectAtIndex:indexPath.row];
        if([_addressList count] > 0){
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            
            [UIView animateWithDuration:0.25 animations:^{
                CGRect rect = _tableView.frame;
                rect.size.height = [_addressList count] * 36.0;
                _tableView.frame = rect;
            }];
            
        }else {
            [self loggedInUserPicker:NO anchorRect:CGRectZero];
            
            _textField.rightView = nil;
            _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
        
        [KDSignInManager storeAddressList:_addressList];
    }
}

- (void)dismissLoggedInAddressPicker:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self loggedInUserPicker:NO anchorRect:CGRectZero];
}
#pragma mark -
#pragma mark UITableView delegate and data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_addressList count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentify = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentify];
	if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentify];
        
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = RGBACOLOR(255, 255, 255, 0.5f);
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // accessory view
        UIImage *bgImage = [UIImage imageNamed:@"gray_circle_remove.png"];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0.0, 0.0, bgImage.size.width+15.0, bgImage.size.height+14.0);
        
        btn.imageEdgeInsets = UIEdgeInsetsMake(7.0, 11.0, 7.0, 4.0);
        [btn setImage:bgImage forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(removeLoggedAddress:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = btn;
    }
    
    NSString *addressString = [_addressList objectAtIndex:indexPath.row];
    cell.textLabel.text = addressString;
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self hasLoggedAddresses]) {
        
        NSString * string  = [_addressList objectAtIndex:indexPath.row];
        [_textField setText:string];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self loggedInUserPicker:NO anchorRect:CGRectZero];
    }
}

#pragma mark - 
#pragma mark Button Method

-(void)backgroundButtonTap:(UIButton *)button{
    if ([_textField isFirstResponder]) {
        [_textField resignFirstResponder];
    }
}

-(void)cancelButonTap:(UIButton *)button{
    [self removeFromSuperview];
}

-(void)confimButtonTap:(UIButton *)button{
    if ([_textField.text length] == 0 ) {
        return;
    }
    BOOL shouldInsert = YES;
    for (NSString * address in _addressList) {
        if ([address isEqualToString:_textField.text]) {
            shouldInsert = NO;
            break;
        }
    }
    if (shouldInsert) {
        [_addressList insertObject:_textField.text atIndex:0];
        [KDSignInManager storeAddressList:_addressList];
    }
    if (_block) {
        _block(_textField.text);
    }
    [self removeFromSuperview];
    
}

#pragma mark -
#pragma mark UITextField Method
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_textField resignFirstResponder];
    return YES;
}


@end
