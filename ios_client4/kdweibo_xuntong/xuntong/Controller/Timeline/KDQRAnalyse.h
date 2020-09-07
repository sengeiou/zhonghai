//
//  KDQRAnalyse.h
//  kdweibo
//
//  Created by kyle on 16/5/4.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _QRLoginCode{
    QRLoginNO = -1,
    KDQRCodeHTTP = 0,
    QRLoginXTWeb = 1,
    QRLoginMykingdee = 2,
    QRInvite = 3,
    QRPubAccScan = 4, //公共号二维码扫描
    QRLoginThirdPart = 5, //第三方应用
    KDQRCodeExternalGroup = 6
}QRLoginCode;

typedef void (^KDQRAnalyseCallbackBlock) (QRLoginCode qrCode,NSString *qrResult);

@interface KDQRAnalyse : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) UIViewController *lastViewController;

+ (KDQRAnalyse *)sharedManager;

- (QRLoginCode)analyse:(NSString *)qrResult;
- (void)execute:(NSString *)qrUrl callbackBlock:(KDQRAnalyseCallbackBlock)callbackBlock;
- (UIViewController *)gotoResultVCInTargetVC:(UIViewController *)targetVC withQRResult:(NSString *)qrResult andQRCode:(QRLoginCode)qrCode;
@end
