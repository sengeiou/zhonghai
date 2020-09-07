//
//  NSData+GIF.m
//  SDWebImage
//
//  Created by Andy LaVoy on 4/28/13.
//  Copyright (c) 2013 Dailymotion. All rights reserved.
//

#import "NSData+GIF.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Additions.h"

@implementation NSData (GIF)

- (BOOL)isGIF
{
    BOOL isGIF = NO;
    
    uint8_t c;
    [self getBytes:&c length:1];
    
    switch (c)
    {
        case 0x47:  // probably a GIF
            isGIF = YES;
            break;
        default:
            break;
    }
    
    return isGIF;
}
- (NSData *)rawGIF_ToSize:(CGSize)size
{
    if (![self isGIF]) return self;
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)self, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    NSMutableData *data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)data,
                                                                         kUTTypeGIF,
                                                                         count,
                                                                         NULL);
    for (size_t i = 0; i < count; i++)
    {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
        
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        if (image.size.width<size.width && image.size.height<size.height){
            CGImageRelease(imageRef);
            CFRelease(destination);
            CFRelease(source);
            return self;
        }
        image = [image fastCropToSize:size];
        
        NSDictionary *frameProperties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, i, NULL));

        CGImageDestinationAddImage(destination, image.CGImage, (CFDictionaryRef)frameProperties);
        
        CGImageRelease(imageRef);
    }
    
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount]
                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
    
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    CFRelease(source);
    
    return data;
}
@end
