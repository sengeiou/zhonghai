//
//  KWIRemoteImage.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 20120923.
//
//

#import <Foundation/Foundation.h>
#import "EGOPhotoGlobal.h"

@interface KWIRemoteImage : NSObject <EGOPhoto>

- (id)initWithImageURL:(NSURL*)aURL;
- (id)initWithImage:(UIImage*)aImage;

@end
