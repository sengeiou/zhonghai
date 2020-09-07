//
//  NSData+GIF.h
//  SDWebImage
//
//  Created by Andy LaVoy on 4/28/13.
//  Copyright (c) 2013 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSData (GIF)

- (BOOL)isGIF;
- (NSData *)rawGIF_ToSize:(CGSize)size;
@end
