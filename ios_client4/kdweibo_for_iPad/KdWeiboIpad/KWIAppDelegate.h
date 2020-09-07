//
//  KWIAppDelegate.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @mainpage 
 
 @section KWEngine 
 
 - send request to API, handle auth.
 - parse response, handle and envelop errors.
 - focus on network and data parsing.
 
 @sa KWEngine and other files in group %KWEngine
 
 @section model
 
 @subsection KWData
 
 - act as middle tier between KWEngine and data consumer.
 - manage Core Data.
 - focus on business logic and data persistance.
 
 working in progress
 
 @sa KWDataProvider and other files in group %KdWeiboIpad/%KWData
 
 @subsection data model
 - User
 - Status
 
 @section UI
 working in progress
 
 @section third-party lib 
 
 @section naming convention
 
 - VCtrl, VCtrlr: ViewController
 - LVCtrl, LVCtrlr: ViewController for landscape
 - PVCtrl, PVCtrlr: ViewController for portrait
 
 */

@interface KWIAppDelegate : UIResponder <UIApplicationDelegate>
{
    NSString *fileURL;
    NSString *commentURL_;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UISplitViewController *splitViewController;

- (NSString *)commentURL;
+(KWIAppDelegate *)getAppDelegate;
- (void)showTimelineViewController;
- (void)dismissAuthViewController;
- (void)openWebView:(NSString*)url;
- (void)showSingInViewController;
- (void)postInit:(BOOL)bLoadTimeline;
@end
