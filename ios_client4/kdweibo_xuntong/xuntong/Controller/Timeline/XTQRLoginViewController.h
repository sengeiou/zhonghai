//
//  XTQRLoginViewController.h
//  XT
//
//  Created by Gil on 13-8-23.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASIFormDataRequest;
@interface XTQRLoginViewController : UIViewController
{
    ASIFormDataRequest *_requestScan;
    ASIFormDataRequest *_requestConfirm;
}

@property (nonatomic, copy) NSString *url;
@property (nonatomic) int qrLoginCode;

- (id)initWithURL:(NSString *)url qrLoginCode:(int)qrLoginCode;

@end
