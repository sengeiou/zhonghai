//
//  KDCommunityShareView.m
//  kdweibo
//
//  Created by AlanWong on 14-7-29.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDCommunityShareView.h"
#import "KDDraft.h"
#import "KDStatusUploadTask.h"
#import "KDUploadTaskHelper.h"
#import "KDAttachment.h"
#import "BOSBaseDataModel.h"
@interface KDCommunityShareView()<UITextFieldDelegate,UITextViewDelegate>
@property(nonatomic,strong)UIView * backgroundView;
@property(nonatomic,strong)UILabel * tipsLabel;
@property(nonatomic,strong)UILabel * fileNameLabel;
@property(nonatomic,strong)UILabel * fileSizeLabel;
@property(nonatomic,strong)UIButton * cancelButton;
@property(nonatomic,strong)UIButton * confirmButton;
@property(nonatomic,strong)UIImageView * imageView;
@property(nonatomic,strong)UITextField * textField;
@property(nonatomic,strong)UITextView * textView;
@property(nonatomic,strong)KDDraft * draft;
@end


#define BACKGROUND_VIEW_WIDTH ScreenFullWidth - 60
#define IMAGE_STANDARD_SIZE_WIDTH 250
#define IMAGE_STANDARD_SIZE_HEIGHT 60

@implementation KDCommunityShareView


/**
 *  唯一公开的初始化方法
 *
 *  @param frame        frame
 *  @param type         指定那种分享的类型
 *  @param isForIPhone5 指定是不是iphone5机型（4寸）
 *
 */
-(id)initWithFrame:(CGRect)frame type:(KDCommunityShareType)type isForIPhone5:(BOOL)isForIPhone5{
    if (isForIPhone5) {
        self = [self initIsIPhone5WithFrame:frame type:type];
    }
    else{
        if (type == KDCommunityShareTypeNew) {
            //type 为新闻的时候，使用跟iOS5尺寸一样的布局
            self = [self initIsIPhone5WithFrame:frame type:type];
        }
        else{
            self = [self initNoIPhone5WithFrame:frame type:type];

        }
    }

    _isForIPhone5 = isForIPhone5;
    return self;
}
/**
 *  没有意义，不被调用，返回nil
 *
 */
- (id)initWithFrame:(CGRect)frame
{
    return nil;
}
/**
 *  iPhone5 四寸的初始化方法
 *
 */
-(id)initIsIPhone5WithFrame:(CGRect)frame type:(KDCommunityShareType)type{
    self = [super initWithFrame:frame];
    if (self) {
        _draft = [[KDDraft alloc]initWithType:KDDraftTypeNewStatus];
        self.type = type;
        
        CGFloat originY = 0;
        
        UIButton * backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backgroundButton setFrame:frame];
        [backgroundButton addTarget:self action:@selector(backgroundButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backgroundButton];
        
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.7f);
        _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(30, 150, BACKGROUND_VIEW_WIDTH, 250)];
        _backgroundView.backgroundColor = [UIColor kdBackgroundColor1];//BOSCOLORWITHRGBA(0xFFFFFF, 0.95);
        _backgroundView.layer.cornerRadius = 8.0;
        _backgroundView.hidden = NO;
        [self addSubview:_backgroundView];
        
        KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
        CompanyDataModel *currentUser = communityManager.currentCompany;
        NSString * companyName = currentUser.name;
        NSString * typeText = nil;
        switch (_type) {
            case KDCommunityShareTypeNew:
                typeText = ASLocalizedString(@"KDCommunityShareView_News");
                break;
            case KDCommunityShareTypeFile:
                typeText = ASLocalizedString(@"KDCommunityShareView_File");
                break;
            case KDCommunityShareTypeText:
                typeText = ASLocalizedString(@"KDCommunityShareView_Chat");
                break;
            case KDCommunityShareTypeImage:
                typeText = ASLocalizedString(@"KDCommunityShareView_Pic");
                break;
                
            default:
                break;
        }
        _tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(15.0f, 15.0f, BACKGROUND_VIEW_WIDTH - 30, 18)];
        _tipsLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDCommunityShareView_Share"),typeText,companyName];
        _tipsLabel.font = [UIFont systemFontOfSize:14.0f];
        _tipsLabel.backgroundColor = [UIColor clearColor];
        _tipsLabel.textColor = [UIColor blackColor];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.hidden = NO;
        [_backgroundView addSubview:_tipsLabel];
        originY = CGRectGetMaxY(_tipsLabel.frame);
        
       
        
        switch (_type) {
            case KDCommunityShareTypeText:{
                _textView = [[UITextView alloc]initWithFrame:CGRectMake(15.0f, originY + 15.0f, BACKGROUND_VIEW_WIDTH-30.0f, 60.0f)];
                _textView.backgroundColor = [UIColor whiteColor];
                _textView.layer.borderColor = BOSCOLORWITHRGBA(0xDDDDDD, 1.0).CGColor;
                _textView.layer.borderWidth = 1.0;
                _textView.layer.cornerRadius = 5.0;
                _textView.font = [UIFont systemFontOfSize:14.0];
                _textView.returnKeyType = UIReturnKeyDone;
                _textView.delegate = self;
                _textView.hidden = NO;
                [_backgroundView addSubview:_textView];
                originY = CGRectGetMaxY(_textView.frame);
                
                
            }
                
                break;
            case KDCommunityShareTypeImage:{
                _imageView = [[UIImageView alloc]init];
                
                [_imageView setFrame:CGRectMake(15.0f, originY + 15.0f, 0,0)];
                _imageView.hidden = NO;
                [_backgroundView addSubview:_imageView];
                originY = CGRectGetMaxY(_imageView.frame);
                
                _textField = [[UITextField alloc]initWithFrame:CGRectMake(15.0f,
                                                                          originY + 15.0f,
                                                                          BACKGROUND_VIEW_WIDTH-30.0f,
                                                                          40)];
                _textField.backgroundColor = [UIColor whiteColor];
                _textField.layer.borderColor = BOSCOLORWITHRGBA(0xDDDDDD, 1.0).CGColor;
                _textField.layer.borderWidth = 1.0;
                _textField.layer.cornerRadius = 5.0;
                _textField.placeholder = ASLocalizedString(@"KDCommunityShareView_Something");
                _textField.font = [UIFont systemFontOfSize:14.0];
                _textField.returnKeyType = UIReturnKeyDone;
                _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, _textField.bounds.size.height)];
                leftView.backgroundColor = _textField.backgroundColor;
                _textField.leftView = leftView;
                _textField.leftViewMode = UITextFieldViewModeAlways;
                _textField.hidden = NO;
                _textField.delegate = self;
                [_backgroundView addSubview:_textField];
                originY = CGRectGetMaxY(_textField.frame);
                
                
                
            }
                
                break;
            case KDCommunityShareTypeNew:{
                _imageView = [[UIImageView alloc]init];
                
                [_imageView setFrame:CGRectMake(15.0f, originY + 15.0f, 0,0)];
                _imageView.hidden = NO;
                [_backgroundView addSubview:_imageView];
                originY = CGRectGetMaxY(_imageView.frame);
                
//                _textField = [[UITextField alloc]initWithFrame:CGRectMake(15.0f,
//                                                                          originY + 15.0f,
//                                                                          250.0f,
//                                                                          40)];
//                _textField.backgroundColor = [UIColor whiteColor];
//                _textField.layer.borderColor = BOSCOLORWITHRGBA(0xDDDDDD, 1.0).CGColor;
//                _textField.layer.borderWidth = 1.0;
//                _textField.layer.cornerRadius = 5.0;
//                _textField.placeholder = ASLocalizedString(@"和大家说点什么吧");
//                _textField.font = [UIFont systemFontOfSize:14.0];
//                _textField.returnKeyType = UIReturnKeyDone;
//                _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//                UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, _textField.bounds.size.height)];
//                leftView.backgroundColor = _textField.backgroundColor;
//                _textField.leftView = leftView;
//                _textField.leftViewMode = UITextFieldViewModeAlways;
//                _textField.hidden = NO;
//                _textField.delegate = self;
//                [_backgroundView addSubview:_textField];
//                originY = CGRectGetMaxY(_textField.frame);
                
                
            }
                
                break;
                
            case KDCommunityShareTypeFile:{
                _imageView = [[UIImageView alloc]init];
                
                _imageView.image = [UIImage imageNamed:@"file_img_weizhi"];
                [_imageView sizeToFit];
                [_imageView setFrame:CGRectMake(15.0f,
                                                originY + 15,
                                                _imageView.bounds.size.width,
                                                _imageView.bounds.size.height)];
                _imageView.hidden = NO;
                [_backgroundView addSubview:_imageView];
                originY = CGRectGetMaxY(_imageView.frame);
                
                _fileNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_imageView.frame) + 10,
                                                                          CGRectGetMaxY(_tipsLabel.frame) + 15,
                                                                          _backgroundView.bounds.size.width - CGRectGetMaxX(_imageView.frame) - 10 - 15,
                                                                          16)];
                _fileNameLabel.text = ASLocalizedString(@"KDCommunityShareView_Doc");
                _fileNameLabel.font = [UIFont systemFontOfSize:14.0f];
                _fileNameLabel.textColor= [UIColor blackColor];
                _fileNameLabel.backgroundColor = [UIColor clearColor];

                _fileNameLabel.hidden = NO;
                [_backgroundView addSubview:_fileNameLabel];
                
                _fileSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(_fileNameLabel.frame.origin.x,
                                                                          CGRectGetMaxY(_fileNameLabel.frame) + 12,
                                                                          _fileNameLabel.frame.size.width,
                                                                          14)];
                _fileSizeLabel.font = [UIFont systemFontOfSize:12.0f];
                _fileSizeLabel.textColor = BOSCOLORWITHRGBA(0x808080, 1.0f);
                _fileSizeLabel.backgroundColor = [UIColor clearColor];

                _fileSizeLabel.text = @"3M";
                _fileSizeLabel.hidden = NO;
                [_backgroundView addSubview:_fileSizeLabel];
                
                _textField = [[UITextField alloc]initWithFrame:CGRectMake(15.0f,
                                                                          originY + 15.0f,
                                                                          BACKGROUND_VIEW_WIDTH-30.0f,
                                                                          40)];
                _textField.backgroundColor = [UIColor whiteColor];
                _textField.layer.borderColor = BOSCOLORWITHRGBA(0xDDDDDD, 1.0).CGColor;
                _textField.layer.borderWidth = 1.0;
                _textField.layer.cornerRadius = 5.0;
                _textField.placeholder = ASLocalizedString(@"KDCommunityShareView_Something");
                _textField.font = [UIFont systemFontOfSize:14.0];
                _textField.returnKeyType = UIReturnKeyDone;
                _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, _textField.bounds.size.height)];
                leftView.backgroundColor = _textField.backgroundColor;
                _textField.leftView = leftView;
                _textField.leftViewMode = UITextFieldViewModeAlways;
                _textField.hidden = NO;
                _textField.delegate = self;
                [_backgroundView addSubview:_textField];
                originY = CGRectGetMaxY(_textField.frame);
                
                
            }
                break;
                
            default:
                break;
        }
        
        CGRect frame = _backgroundView.frame;
        frame.size.height = originY + 15 + 44;
        [_backgroundView setFrame:frame];
        
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
        [_confirmButton setTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Sure")forState:UIControlStateNormal];
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

/**
 *  非iPhone5 3.5寸屏的初始化方法
 *
 */
-(id)initNoIPhone5WithFrame:(CGRect)frame type:(KDCommunityShareType)type{
    self = [super initWithFrame:frame];
    if (self) {
        _draft = [[KDDraft alloc]initWithType:KDDraftTypeNewStatus];
        self.type = type;
        
        UIButton * backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backgroundButton setFrame:frame];
        [backgroundButton addTarget:self action:@selector(backgroundButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backgroundButton];
        
        CGFloat originY = 0;
        CGFloat originX = 0;
        
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.7f);
        _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(20, 60, BACKGROUND_VIEW_WIDTH, 250)];
        _backgroundView.backgroundColor = BOSCOLORWITHRGBA(0xFFFFFF, 0.95);
        _backgroundView.layer.cornerRadius = 8.0;
        _backgroundView.hidden = NO;
        [self addSubview:_backgroundView];
        
        
        KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
        CompanyDataModel *currentUser = communityManager.currentCompany;
        NSString * companyName = currentUser.name;
        NSString * typeText = nil;
        switch (_type) {
            case KDCommunityShareTypeNew:
                typeText = ASLocalizedString(@"KDCommunityShareView_News");
                break;
            case KDCommunityShareTypeFile:
                typeText = ASLocalizedString(@"KDCommunityShareView_File");
                break;
            case KDCommunityShareTypeText:
                typeText = ASLocalizedString(@"KDCommunityShareView_Chat");
                break;
            case KDCommunityShareTypeImage:
                typeText = ASLocalizedString(@"KDCommunityShareView_Pic");
                break;
                
            default:
                break;
        }

        _tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(15.0f, 15.0f, 230, 18)];
        _tipsLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDCommunityShareView_Share"),typeText,companyName];
        _tipsLabel.font = [UIFont systemFontOfSize:14.0f];
        _tipsLabel.backgroundColor = [UIColor clearColor];
        _tipsLabel.textColor = [UIColor blackColor];
         _tipsLabel.hidden = NO;
        [_backgroundView addSubview:_tipsLabel];
        originY = CGRectGetMaxY(_tipsLabel.frame);
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setImage:[UIImage imageNamed:@"common_btn_close"] forState:UIControlStateNormal];
        [_cancelButton sizeToFit];
        [_cancelButton setFrame:CGRectMake(CGRectGetWidth(_backgroundView.bounds) - _cancelButton.bounds.size.width - 15,
                                           10,
                                           _cancelButton.bounds.size.width,
                                           _cancelButton.bounds.size.height)];
        [_cancelButton addTarget:self action:@selector(cancelButonTap:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.hidden = NO;
        [_backgroundView addSubview:_cancelButton];
        
        switch (_type) {
            case KDCommunityShareTypeText:{
                
                _textView = [[UITextView alloc]initWithFrame:CGRectMake(15.0f, originY + 15.0f, 200.0f, 80.0f)];
                _textView.backgroundColor = [UIColor whiteColor];
                _textView.layer.borderColor = BOSCOLORWITHRGBA(0xDDDDDD, 1.0).CGColor;
                _textView.layer.borderWidth = 1.0;
                _textView.layer.cornerRadius = 5.0;
                _textView.font = [UIFont systemFontOfSize:14.0];
                _textView.returnKeyType = UIReturnKeyDone;
                _textView.delegate = self;
                _textView.hidden = NO;
                [_backgroundView addSubview:_textView];
                originY = CGRectGetMaxY(_textView.frame);
                originX = CGRectGetMaxX(_textView.frame);

  
            }
                
                break;
            case KDCommunityShareTypeImage:{
                _imageView = [[UIImageView alloc]init];
                
                [_imageView setFrame:CGRectMake(15.0f, originY + 15.0f, 0,0)];
                _imageView.hidden = NO;
                [_backgroundView addSubview:_imageView];
                originY = CGRectGetMaxY(_imageView.frame);
                

                
            }
                
                break;
            case KDCommunityShareTypeNew:{
                _imageView = [[UIImageView alloc]init];
                
                [_imageView setFrame:CGRectMake(15.0f, originY + 15.0f, 0,0)];
                _imageView.hidden = NO;
                [_backgroundView addSubview:_imageView];
                originY = CGRectGetMaxY(_imageView.frame);
                
            }
                
                break;
                
            case KDCommunityShareTypeFile:{
                _imageView = [[UIImageView alloc]init];
               
                _imageView.image = [UIImage imageNamed:@"file_img_weizhi"];
                [_imageView sizeToFit];
                [_imageView setFrame:CGRectMake(15.0f,
                                                originY + 15,
                                                _imageView.bounds.size.width,
                                                _imageView.bounds.size.height)];
                _imageView.hidden = NO;
                [_backgroundView addSubview:_imageView];
                originY = CGRectGetMaxY(_imageView.frame);
                
                _fileNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_imageView.frame) + 10,
                                                                          CGRectGetMaxY(_tipsLabel.frame) + 15,
                                                                          _backgroundView.bounds.size.width - CGRectGetMaxX(_imageView.frame) - 10 - 15,
                                                                          16)];
                _fileNameLabel.text = ASLocalizedString(@"KDCommunityShareView_Doc");
                _fileNameLabel.font = [UIFont systemFontOfSize:14.0f];
                _fileNameLabel.backgroundColor = [UIColor clearColor];
                _fileNameLabel.textColor= [UIColor blackColor];
                _fileNameLabel.hidden = NO;
                [_backgroundView addSubview:_fileNameLabel];
                
                _fileSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(_fileNameLabel.frame.origin.x,
                                                                          CGRectGetMaxY(_fileNameLabel.frame) + 12,
                                                                          _fileNameLabel.frame.size.width,
                                                                          14)];
                _fileSizeLabel.backgroundColor = [UIColor clearColor];

                _fileSizeLabel.font = [UIFont systemFontOfSize:12.0f];
                _fileSizeLabel.textColor = BOSCOLORWITHRGBA(0x808080, 1.0f);
                _fileSizeLabel.text = @"3M";
                _fileSizeLabel.hidden = NO;
                [_backgroundView addSubview:_fileSizeLabel];
                
            }
                break;
                
            default:
                break;
        }
        if (_type != KDCommunityShareTypeText) {
            _textField = [[UITextField alloc]initWithFrame:CGRectMake(15.0f,
                                                                      originY + 15.0f,
                                                                      200.0f,
                                                                      40)];
            _textField.backgroundColor = [UIColor whiteColor];
            _textField.layer.borderColor = BOSCOLORWITHRGBA(0xDDDDDD, 1.0).CGColor;
            _textField.layer.borderWidth = 1.0;
            _textField.layer.cornerRadius = 5.0;
            _textField.placeholder = ASLocalizedString(@"KDCommunityShareView_Something");
            _textField.font = [UIFont systemFontOfSize:14.0];
            _textField.returnKeyType = UIReturnKeyDone;
            _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, _textField.bounds.size.height)];
            leftView.backgroundColor = _textField.backgroundColor;
            _textField.leftView = leftView;
            _textField.leftViewMode = UITextFieldViewModeAlways;
            _textField.hidden = NO;
            _textField.delegate = self;
            [_backgroundView addSubview:_textField];
            originY = CGRectGetMaxY(_textField.frame);
            originX = CGRectGetMaxX(_textField.frame);
            
        }
        
        CGFloat confirmButtonY = (_type == KDCommunityShareTypeText ? CGRectGetMinY(_textView.frame) :CGRectGetMinY(_textField.frame));
        
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:ASLocalizedString(@"KDChooseOrganizationViewController_Sure")forState:UIControlStateNormal];
        [_confirmButton sizeToFit];
        [_confirmButton setFrame:CGRectMake(originX+ 10,confirmButtonY ,_confirmButton.bounds.size.width, _confirmButton.bounds.size.height)];
        [_confirmButton addTarget:self action:@selector(confimButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f] ];
        [_confirmButton setTitleColor:BOSCOLORWITHRGBA(0x1A85FF, 1.0f) forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _confirmButton.hidden = NO;
        [_backgroundView addSubview:_confirmButton];
        
        CGRect frame = _backgroundView.frame;
        frame.size.height = originY + 15;
        [_backgroundView setFrame:frame];

    }
    return self;
}


#pragma mark -
#pragma mark Private Method

-(void)becomeFirstResponderShareView{
    if (_type == KDCommunityShareTypeText) {
        [_textView becomeFirstResponder];
    }
    else{
        [_textField becomeFirstResponder];
    }
}
-(void)resignFirstResponderShareView{
    if ([_textField isFirstResponder]) {
        [_textField resignFirstResponder];
    }
    else if([_textView isFirstResponder]){
        [_textView resignFirstResponder];
    }
}
-(BOOL)shouldScaleImage:(UIImage *)image{
    if (image.size.width > IMAGE_STANDARD_SIZE_WIDTH || image.size.height > IMAGE_STANDARD_SIZE_HEIGHT) {
        return YES;
    }
    return NO;
}
-(CGFloat)calculateImageScaleSize:(UIImage *)image{
    CGFloat height = IMAGE_STANDARD_SIZE_HEIGHT / image.size.height ;
    CGFloat width = IMAGE_STANDARD_SIZE_WIDTH / image.size.width ;
    return height < width ? height : width;
}
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height*scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
-(void)setFileImageByExtName:(NSString *)extName{
    if ([extName isEqualToString:@"docx"] || [extName isEqualToString:@"doc"]) {
        self.imageView.image = [UIImage imageNamed:@"file_img_word"];
    }
    else if ([extName isEqualToString:@"xlsx"] || [extName isEqualToString:@"xls"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_img_xls"];
    }
    else if ([extName isEqualToString:@"pptx"] || [extName isEqualToString:@"ppt"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_img_ppt"];
    }
    else if ([extName isEqualToString:@"jpg"] || [extName isEqualToString:@"jpeg"]||[extName isEqualToString:@"gif"] || [extName isEqualToString:@"png"]||[extName isEqualToString:@"bmp"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_img_tupian"];
    }
    else if ([extName isEqualToString:@"txt"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_img_txt"];
    }
    else if ([extName isEqualToString:@"pdf"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_img_pdf"];
    }
    else if ([extName isEqualToString:@"zip"])
    {
        self.imageView.image = [UIImage imageNamed:@"file_img_zip"];
    }
    else{
        self.imageView.image = [UIImage imageNamed:@"file_img_weizhi"];
    }
}
#pragma mark -
#pragma mark Setter Method

-(void)setFileDataModel:(MessageFileDataModel *)fileDataModel{
    if (!fileDataModel) {
        return;
    }
    _fileDataModel = fileDataModel;
    _fileNameLabel.text = fileDataModel.name;
    CGFloat sizeValue = [fileDataModel.size floatValue] / 1024;
    _fileSizeLabel.text = [NSString stringWithFormat:@"%0.2fK",sizeValue];
    [self setFileImageByExtName:fileDataModel.ext];
}

-(void)setTheNewDataMedel:(MessageNewsEachDataModel *)theNewDataMedel{
    if (!theNewDataMedel) {
        return;
    }
    _theNewDataMedel = theNewDataMedel;
    NSURL * url = [NSURL URLWithString:theNewDataMedel.name];
    BOOL isImageExists = [[SDWebImageManager sharedManager]diskImageExistsForURL:url];
    if (isImageExists) {
        self.imagePath = [[SDWebImageManager sharedManager] diskImagePathForURL:url imageScale:SDWebImageScaleNone];
    }
}

-(void)setPersonUrl:(NSString *)personUrl{
    if (!personUrl || [personUrl isEqualToString:_personUrl] || [_contentText length] > 0 || [_imagePath length] > 0 ) {
        return;
    }
    _personUrl = personUrl;
    NSURL * url2 = [NSURL URLWithString:_personUrl];
    BOOL isphotoExists = [[SDWebImageManager sharedManager]diskImageExistsForURL:url2];
    if (isphotoExists) {
        self.imagePath = [[SDWebImageManager sharedManager]diskImagePathForURL:url2 imageScale:SDWebImageScaleNone];
    }
}

-(void)setContentText:(NSString *)contentText{
    if (![contentText isEqualToString:_contentText]) {
        _contentText = contentText;
        if (_type == KDCommunityShareTypeText) {
            _textView.text = _contentText;
        }
    }
    
}
-(void)setShareImage:(UIImage *)shareImage{
    if (shareImage) {
        UIImage * image = nil;
        if ([self shouldScaleImage:shareImage]) {
            image = [self scaleImage:shareImage toScale:[self calculateImageScaleSize:shareImage]];
        }
        if (image) {
            _imageView.image = image;
        }
        else{
            _imageView.image = shareImage;
        }
        
        [_imageView sizeToFit];
        if (_type == KDCommunityShareTypeNew) {
            CGRect frame = _backgroundView.frame;
            frame.size.height = CGRectGetMaxY(_imageView.frame) + 15 + 44;
            [_backgroundView setFrame:frame];
            [_cancelButton setFrame:CGRectMake(0, _backgroundView.bounds.size.height - 44, _backgroundView.bounds.size.width / 2, 44)];
            [_confirmButton setFrame:CGRectMake(_backgroundView.bounds.size.width / 2 , _backgroundView.bounds.size.height-44, _backgroundView.bounds.size.width / 2, 44)];
            [self setNeedsDisplay];
        }
        else{
            if (_isForIPhone5) {
                [_textField setFrame:CGRectMake(15.0f, CGRectGetMaxY(_imageView.frame) + 15.0f, 250.0f, 40)];
                CGRect frame = _backgroundView.frame;
                frame.size.height = CGRectGetMaxY(_textField.frame) + 15 + 44;
                [_backgroundView setFrame:frame];
                [_cancelButton setFrame:CGRectMake(0, _backgroundView.bounds.size.height - 44, _backgroundView.bounds.size.width / 2, 44)];
                [_confirmButton setFrame:CGRectMake(_backgroundView.bounds.size.width / 2 , _backgroundView.bounds.size.height-44, _backgroundView.bounds.size.width / 2, 44)];
                [self setNeedsDisplay];
                    
                
                
            }
            else{
                
                [_textField setFrame:CGRectMake(15.0f,
                                                    CGRectGetMaxY(_imageView.frame) + 15.0f,
                                                    200.0f,
                                                    40)];
                CGRect frame = _backgroundView.frame;
                frame.size.height = CGRectGetMaxY(_textField.frame) + 15 ;
                [_backgroundView setFrame:frame];
                [_confirmButton setFrame:CGRectMake(CGRectGetMaxX(_textField.frame) + 10, _textField.frame.origin.y ,_confirmButton.bounds.size.width, _confirmButton.bounds.size.height)];
                [self setNeedsDisplay];
                
                
            }

        }
        
    }
}
-(void)setImagePath:(NSString *)imagePath{
    if (!imagePath || [imagePath isEqualToString:_imagePath]) {
        return;
    }
    _imagePath = imagePath;
     [self setShareImage:[UIImage imageWithContentsOfFile:_imagePath]];
}
#pragma mark -
#pragma mark UIButton Method

-(void)backgroundButtonTap:(UIButton *)button{
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    }
    if ([_textField isFirstResponder]) {
        [_textField resignFirstResponder];
    }
}

-(void)cancelButonTap:(UIButton *)button{
    [self resignFirstResponderShareView];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(shareViewDidSelectButtonAtIndex:)]) {
        [_delegate shareViewDidSelectButtonAtIndex:KDCommunityShareButtonCancel];
    }
    [self removeFromSuperview];
    
}

-(void)confimButtonTap:(UIButton *)button{
    KDStatus *status = nil;
    switch (_type) {
        case KDCommunityShareTypeText:{
            [self backgroundButtonTap:nil];
            if ([_textView.text length] > 0) {
                _draft.content = _textView.text;
            }
            else{
                return;
            }
            status = [_draft sendingStatus:nil videoPath:nil];
        }
            break;
        case KDCommunityShareTypeImage:{
            status = [_draft sendingStatus:@[self.imagePath] videoPath:nil];

        }
            break;
        case KDCommunityShareTypeNew:{
            NSArray * imageArray = nil;
            if ([_theNewDataMedel.title isEqualToString:_theNewDataMedel.text] || _theNewDataMedel.title.length == 0) {//多图新闻类型
                _draft.content = [NSString stringWithFormat:@"%@\n%@",_theNewDataMedel.text,_theNewDataMedel.url];

            }
            else{//单图新闻类型
                
                int totalLenght = (int)(_theNewDataMedel.title.length + _theNewDataMedel.text.length+_theNewDataMedel.url.length);
                if (totalLenght < 990) {
                   _draft.content = [NSString stringWithFormat:@"%@\n%@\n%@",_theNewDataMedel.title,_theNewDataMedel.text,_theNewDataMedel.url];
                }
                else{
                    NSString *  string = [_theNewDataMedel.text substringToIndex:(1000 - _theNewDataMedel.url.length - _theNewDataMedel.title.length - 10)];
                    _draft.content = [NSString stringWithFormat:@"%@\n%@\n%@",_theNewDataMedel.title,string,_theNewDataMedel.url];

                }
                
            }
            
            if ([self.imagePath length] > 0) {
                imageArray = @[_imagePath];
            }
            status = [_draft sendingStatus:imageArray videoPath:nil];
            
        }
            break;
        case KDCommunityShareTypeFile:{
            if (!_fileDataModel) {
                return;
            }
            if ([_textField.text length] > 0) {
                _draft.content = _textField.text;
            }
            else{
                _draft.content = ASLocalizedString(@"KDCommunityShareView_ShareFile");
            }
            NSString * baseURL = [NSString stringWithFormat:@"%@/%@", [KDWeiboServicesContext defaultContext].serverSNSBaseURL, [KDManagerContext globalManagerContext].communityManager.currentCompany.wbNetworkId];
            status = [_draft sendingStatus:nil videoPath:nil];
            
            KDAttachment * attachment = [[KDAttachment alloc]init];
            attachment.fileId = _fileDataModel.file_id;
            attachment.filename = _fileDataModel.name;
            attachment.fileSize = [_fileDataModel.size integerValue];
            attachment.url = [NSString stringWithFormat:@"%@/filesvr/%@",baseURL,_fileDataModel.file_id];
            attachment.objectId = status.statusId;
            attachment.attachmentType = KDAttachmentTypeStatus;
            attachment.contentType = _fileDataModel.ext;
            status.attachments = @[attachment];
            

        }
            break;
            
        default:
            break;
    }
    
    KDStatusUploadTask *task = [KDStatusUploadTask taskByDraft:_draft status:status];
    [[KDUploadTaskHelper shareUploadTaskHelper] handleTask:task entityId:status.statusId];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(shareView:clickedButtonAtIndex:)]) {
        [_delegate shareViewDidSelectButtonAtIndex:KDCommunityShareButtonConfirm];
    }
    [self removeFromSuperview];
    
}

#pragma mark -
#pragma mark UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.3f animations:^{
        _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x,
                                           _backgroundView.frame.origin.y - 50,
                                           _backgroundView.frame.size.width,
                                           _backgroundView.frame.size.height);
    }];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.3f animations:^{
        _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x,
                                           _backgroundView.frame.origin.y + 50,
                                           _backgroundView.frame.size.width,
                                           _backgroundView.frame.size.height);
    }];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self resignFirstResponderShareView];
    return YES;
}

#pragma mark - 
#pragma mark UITextViewDelegate Method
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.3f animations:^{
        _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x,
                                           _backgroundView.frame.origin.y - 50,
                                           _backgroundView.frame.size.width,
                                           _backgroundView.frame.size.height);
    }];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.3f animations:^{
        _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x,
                                           _backgroundView.frame.origin.y + 50,
                                           _backgroundView.frame.size.width,
                                           _backgroundView.frame.size.height);
    }];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self resignFirstResponderShareView];
        return NO;
    }
    return YES;
}
@end
