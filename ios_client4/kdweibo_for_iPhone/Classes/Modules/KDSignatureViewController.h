//
//  KDSignatureViewController.h
//  kdweibo
//
//  Created by Joyingx on 16/6/23.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KDSignatureType) {
    KDSignatureTypeHandWritting = 1,
    KDSignatureTypeText,
    KDSignatureTypeMatts,
    KDSignatureTypeMix
};

@protocol KDSignatureViewControllerDelegate <NSObject>

- (void)signatureDidFinished:(NSString *)imageString imageSize:(CGSize)imageSize;
- (void)signatureDidFailed:(NSString *)errorMessage;

@end

@interface KDSignatureViewController : UIViewController

@property (nonatomic, weak) id<KDSignatureViewControllerDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL isPresented;

@property (nonatomic, assign) KDSignatureType type;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, copy) NSString *stamp;

@property (nonatomic, copy) NSString *serverURL;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *recordID;
@property (nonatomic, copy) NSString *fieldName;

- (void)setMaxSize:(CGSize)maxSize;
- (void)setWebSize:(CGSize)webSize;
- (void)setPenType:(NSInteger)penType color:(NSString *)color width:(CGFloat)width;

@end
