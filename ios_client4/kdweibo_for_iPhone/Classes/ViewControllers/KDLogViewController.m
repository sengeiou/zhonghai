//
//  KDLogViewController.m
//  kdweibo
//
//  Created by 王浩芳 on 2018/1/22.
//  Copyright © 2018年 www.kingdee.com. All rights reserved.
//

#import "KDLogViewController.h"

@interface KDLogViewController ()

@property (nonatomic, strong) ContactClient *uploadLogFileClient;
@end

@implementation KDLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor kdBackgroundColor1];
    self.title = ASLocalizedString(@"调试");
    
    UIButton *signinBtn = [self buttonWithTitle:@"上传签到日志"];
    [signinBtn addTarget:self action:@selector(uploadLogFile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signinBtn];
    [signinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(signinBtn.superview).with.offset(kd_StatusBarAndNaviHeight);
        make.leading.trailing.equalTo(signinBtn.superview);
        make.height.mas_equalTo(44);
    }];
    
}

- (void)uploadLogFile {
    if (!self.uploadLogFileClient) {
        self.uploadLogFileClient = [[ContactClient alloc] initWithTarget:self action:@selector(sendLogFileDidReceived:result:)];
    }
    
    //文件读取
    NSString *filePath = [BOSFileManager getSignInInfoTxtPath];
    NSData *readData = [NSData dataWithContentsOfFile:filePath];
    //调试log
    NSString *newStr = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
    DLog(@"%@",newStr);
    NSDate *date = [NSDate date];
    NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
    [forMatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateStr = [forMatter stringFromDate:date];
    NSString *fileName = [NSString stringWithFormat:@"%@_clockIn.txt",dateStr];
    [self.uploadLogFileClient sendLogFileWithPhone:[BOSConfig sharedConfig].user.phone upload:readData fileName:fileName contentType:@"txt" logType:@"clockIn"];
}

- (void)sendLogFileDidReceived:(ContactClient *)client result:(BOSResultDataModel *)result {
    if (result.success) {
        [KDPopup showHUDToast:@"请求成功！"];
    } else {
        [KDPopup showHUDToast:@"请求失败！"];
    }
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    button.titleLabel.font = FS4;
    
    return button;
}

@end
