//
//  KWIAvatarV.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/10/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KWIAvatarV : UIView

+ (KWIAvatarV *)viewForUrl:(NSString *)url size:(NSUInteger)size;
@property (nonatomic,retain)UIImageView *imageView;

- (void)replacePlaceHolder:(UIView *)placeHolder;
- (id) initWithFrame:(CGRect)frame size:(NSUInteger)size url:(NSString *)url;
- (void)downloadImageWithUrl:(NSString *)url;
@end