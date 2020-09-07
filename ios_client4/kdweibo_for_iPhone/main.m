//
//  main.m
//  kdweibo
//
//

#import <UIKit/UIKit.h>

#import "KDWeiboAppDelegate.h"

int main(int argc, char *argv[]) {
//	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    @autoreleasepool {
	int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([KDWeiboAppDelegate class]));
   
//	[pool release];
	return retVal;
         }
}

