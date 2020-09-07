//
//  KDSingleInputViewController.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-1.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    KDSingleInputContentTypeAny,
    KDSingleInputContentTypeUsername,
    KDSingleInputContentTypeDMThreadSubject
};

typedef void (^KDSingleInputViewBlock)(NSString *);

typedef NSUInteger KDSingleInputContentType;


@interface KDSingleInputViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
@private
//    UIViewController *baseViewController_; // weak referece
    
    NSString *content_;
    KDSingleInputContentType contentType_;
    
    UITextField *inputTextField_;
}

- (id) initWithBaseViewController:(UIViewController *)baseViewController content:(NSString *)content type:(KDSingleInputContentType)type;

@property(nonatomic, assign) UIViewController *baseViewController;

@property(nonatomic, copy) NSString *content;
@property(nonatomic, assign) KDSingleInputContentType contentType;

@property(nonatomic, copy) KDSingleInputViewBlock block;

@end
