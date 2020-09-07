//
//  KWIRemoteAlbum.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 20120923.
//
//

#import <Foundation/Foundation.h>
#import "EGOPhotoGlobal.h"

@interface KWIRemoteAlbum : NSObject <EGOPhotoSource>

- (id)initWithPhotos:(NSArray*)photos;

@end
