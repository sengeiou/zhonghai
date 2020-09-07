//
//  XTQRLoginViewController.m
//  XT
//
//  Created by Gil on 13-8-23.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTQRLoginViewController.h"
#import "UIButton+XT.h"
#import "UIImage+XT.h"
#import "ASIFormDataRequest.h"
#import "BOSSetting.h"
#import "AlgorithmHelper.h"
#import "XTQRScanViewController.h"
#import "UIButton+XT.h"
#import "BOSConfig.h"
#import "KDErrorDisplayView.h"

@interface XTQRLoginViewController ()
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, strong) MCloudClient *mCloudClient;
@property (nonatomic, strong) NSMutableDictionary *urlDict;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *qrImageView;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@end

@implementation XTQRLoginViewController

- (void)dealloc
{
    if (_requestScan) {
        [_requestScan clearDelegatesAndCancel];
    }
    
    if (_requestConfirm) {
        [_requestConfirm clearDelegatesAndCancel];
    }
    
}

- (id)initWithURL:(NSString *)url qrLoginCode:(int)qrLoginCode
{
    self = [super init];
    if (self) {
        self.url = url;
        self.qrLoginCode = qrLoginCode;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title  = self.qrLoginCode == QRLoginXTWeb ? [NSString stringWithFormat:ASLocalizedString(@"XTQRLoginViewController_Sure"),KD_APPNAME]: ASLocalizedString(@"XTQRLoginViewController_Login");
    self.view.backgroundColor = BOSCOLORWITHRGBA(0xF0F0F0, 1.0);
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 64.f, ScreenFullWidth, ScreenFullHeight - 64.f)];
    UIImage *image = self.qrLoginCode == QRLoginXTWeb ? [XTImageUtil qrLoginXTWebImage] : [XTImageUtil qrLoginMyKingdeeImage];
    _qrImageView = [[UIImageView alloc] initWithImage:image];
    [baseView addSubview:_qrImageView];
    
    if(self.qrLoginCode == QRLoginThirdPart){
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = RGBCOLOR(123, 123, 123);
        _label.text = ASLocalizedString(@"XTQRLoginViewController_ThirdPart");
        _label.numberOfLines = 2;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:14.0f];
        [_label sizeToFit];
        _label.frame = CGRectMake((CGRectGetMaxX(_qrImageView.frame) -  CGRectGetWidth(_label.bounds))* 0.5f, CGRectGetHeight(_qrImageView.frame) - 40.f, CGRectGetWidth(_label.bounds), CGRectGetHeight(_label.bounds));
        [baseView addSubview:_label];
    }
   
    CGRect rect = _qrImageView.frame;
    rect.origin.y += (rect.size.height + 45.0);
    _confirmBtn = [UIButton greenButtonWithTitle:self.qrLoginCode == QRLoginXTWeb ?[NSString stringWithFormat:ASLocalizedString(@"XTQRLoginViewController_Sure"),KD_APPNAME]: ASLocalizedString(@"XTQRLoginViewController_Login")];
    [_confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _confirmBtn.center = CGPointMake(ScreenFullWidth / 2, rect.origin.y);
    [baseView  addSubview:_confirmBtn];
    
    rect.origin.y += (43.0 + 13.0);
     _cancelBtn = [UIButton whiteButtonWithTitle:ASLocalizedString(@"Global_Cancel")];
    [_cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _cancelBtn.center = CGPointMake(ScreenFullWidth / 2, rect.origin.y);
    [baseView addSubview:_cancelBtn];
    [self.view addSubview:baseView];
    //调用一次,scan
    if(self.qrLoginCode == QRLoginThirdPart){
        [self setViewHidden:YES];
        self.urlDict = [self translateURLParamToDictionary:self.url];
        [self.mCloudClient getLightAppURLWithMid:[self.urlDict objectForKey:@"mid"] appid:[self.urlDict objectForKey:@"appid"] openToken:[BOSConfig sharedConfig].user.token groupId:nil userId:nil msgId:nil urlParam:nil todoStatus:nil];
    }else{
        _requestScan = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
        [_requestScan setRequestMethod:@"POST"];
        if (self.qrLoginCode == QRLoginXTWeb)
        {
            [_requestScan setPostValue:@"1" forKey:@"type"];
            [_requestScan setPostValue:[AlgorithmHelper des_Encrypt:[BOSSetting sharedSetting].cust3gNo key:@"xtweb102"] forKey:@"3gNo"];
            [_requestScan setPostValue:@"" forKey:@"token"];
            NSString *openToken = [BOSConfig sharedConfig].user.token;
            if (openToken) {
                [_requestScan addRequestHeader:@"openToken" value:openToken];
            }
            
        }
        else
        {
            if ([BOSConfig sharedConfig].user.oId.length > 0)
            {
                self.userName = [BOSConfig sharedConfig].user.oId;
            }
            
            if (self.userName.length > 0)
            {
                [_requestConfirm setPostValue:@"xt" forKey:@"client"];
                [_requestConfirm setPostValue:self.userName forKey:@"userName"];
                
                self.token = [AlgorithmHelper md5_Encrypt:[self.userName stringByAppendingFormat:@"%@%@",@"xt",@",ki8(ol."]];
                [_requestConfirm setPostValue:self.token forKey:@"token"];
            }
        }
        
        [_requestScan startAsynchronous];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setViewHidden:(BOOL)isHidden
{
    [_label setHidden:isHidden];
    [_qrImageView setHidden:isHidden];
    [_confirmBtn setHidden:isHidden];
    [_cancelBtn setHidden:isHidden];
}

- (MCloudClient *)mCloudClient
{
    if (_mCloudClient == nil) {
        _mCloudClient = [[MCloudClient alloc] initWithTarget:self action:@selector(getLightAppURLDidReceived:result:)];
    }
    return _mCloudClient;
}

//将URL后面的参数转换成字典
-(NSMutableDictionary *)translateURLParamToDictionary:(NSString *)urlStr
{
    NSRange range = [urlStr rangeOfString:@"?"];
    //获取参数列表
    NSString *propertys = [urlStr substringFromIndex:(int)(range.location+1)];
    NSArray *subArray = [propertys componentsSeparatedByString:@"&"];
    //把subArray转换为字典
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:4];
    for(int j = 0 ; j < subArray.count; j++)
    {
        //在通过=拆分键和值
        NSArray *dicArray = [subArray[j] componentsSeparatedByString:@"="];
        //给字典加入元素
        [tempDic setObject:dicArray[1] forKey:dicArray[0]];
    }
    
    return tempDic;
}

- (void)getLightAppURLDidReceived:(XTOpenSystemClient *)client result:(BOSResultDataModel *)result
{
    if (result.success && result.data && [result.data isKindOfClass:[NSDictionary class]]) {
        [self setViewHidden:NO];
        NSDictionary *data = (NSDictionary *)result.data;
        NSString *url = data[@"url"];
        NSString *name = data[@"name"];
        if (![name isKindOfClass:[NSNull class]] && name.length > 0) {
            self.navigationItem.title = name;
            _label.text = [NSString stringWithFormat:ASLocalizedString(@"XTQRLoginViewController_BeSure"),name];
        }
        if (![url isKindOfClass:[NSNull class]] && url.length > 0) {
            self.url = url;
            [self.urlDict addEntriesFromDictionary:[self translateURLParamToDictionary:self.url]];
            return;
        }
    }
    [KDErrorDisplayView showErrorMessage:result.error inView:self.view];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - btn click

- (void)confirmBtnClick:(UIButton *)btn
{
    if(self.qrLoginCode == QRLoginThirdPart){
        NSRange findRange = [self.url rangeOfString:@"?"];
        NSString *strUrl = nil;
        if (findRange.length >0)
        {
            strUrl = [self.url substringToIndex:findRange.location];
        }
        _requestConfirm = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:strUrl]];
        [_requestConfirm setRequestMethod:@"POST"];
        NSString *openToken = [BOSConfig sharedConfig].user.token;
        if (openToken) {
            [_requestConfirm addRequestHeader:@"openToken" value:openToken];
        }
        
        //过滤掉ticket
        for (NSString *key in self.urlDict) {
//            NSLog(@"key: %@ value: %@", key, self.urlDict[key]);
//            if (![key isEqualToString:@"ticket"]) {
                [_requestConfirm setPostValue:self.urlDict[key] forKey:key];

//            }
        }
    }else{
        //调用一次,confirm
        _requestConfirm = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
        [_requestConfirm setRequestMethod:@"POST"];
        
        if (self.qrLoginCode == QRLoginXTWeb)
        {
            [_requestConfirm setPostValue:@"2" forKey:@"type"];
            [_requestConfirm setPostValue:[AlgorithmHelper des_Encrypt:[BOSSetting sharedSetting].cust3gNo key:@"xtweb102"] forKey:@"3gNo"];
            [_requestConfirm setPostValue:@"" forKey:@"token"];
            NSString *openToken = [BOSConfig sharedConfig].user.token;
            if (openToken) {
                [_requestConfirm addRequestHeader:@"openToken" value:openToken];
            }
        }
        else
        {
            if (self.userName.length > 0)
            {
                [_requestConfirm setPostValue:@"xt" forKey:@"client"];
                [_requestConfirm setPostValue:self.userName forKey:@"userName"];
                [_requestConfirm setPostValue:self.token forKey:@"token"];
                [_requestConfirm setPostValue:@"1" forKey:@"dc"];
            }
        }
    }
    
//    __weak typeof(self) weakSelf = self;
    __weak XTQRLoginViewController * weakSelf = self;
    [_requestConfirm setCompletionBlock:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [_requestConfirm setFailedBlock:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [_requestConfirm startAsynchronous];
}

- (void)cancelBtnClick:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
