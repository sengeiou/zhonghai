//
//  KDScanHelper.m
//  kdweibo
//
//  Created by Gil on 16/4/12.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDScanHelper.h"

@implementation KDScanHelper

+ (NSString *)scanQRWithImage:(UIImage *)srcImage {
	if (!isAboveiOS8) {
		return nil;
	}

	CIContext *context = [CIContext contextWithOptions:nil];
	CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
	CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];

	NSString *result = nil;
	NSArray *features = [detector featuresInImage:image];

	if (features.count) {
		for (CIFeature *feature in features) {
			if ([feature isKindOfClass:[CIQRCodeFeature class]]) {
				result = ((CIQRCodeFeature *)feature).messageString;
				break;
			}
		}
	}

	return result;
}

@end
