//
//  KWIRemoteImage.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 20120923.
//
//

#import "KWIRemoteImage.h"

@implementation KWIRemoteImage

@synthesize URL=_URL;
@synthesize image=_image;
@synthesize size=_size;
@synthesize failed=_failed;

- (id)initWithImageURL:(NSURL*)aURL
{
    if (self = [super init]) {
        _URL = [aURL retain];
    }

	return self;
}

- (id)initWithImage:(UIImage*)aImage
{
	if (self = [super init]) {
        _image = [aImage retain];
    }

	return self;
}

- (NSString *)caption
{
    return @"";
}

- (void)setCaption:(NSString *)caption
{
    // do nothing
}

- (void)dealloc
{

	[_URL release], _URL=nil;
	[_image release], _image=nil;
	[super dealloc];
}

@end
