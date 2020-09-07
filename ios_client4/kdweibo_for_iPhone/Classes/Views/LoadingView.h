//
//  LoadingView.h
//  TwitterFon
//
//  Created by apple on 11-6-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingView : UIAlertView
{   
    UIActivityIndicatorView *activityView;
}

-(void) hide;
-(id)initLoading;

@end
