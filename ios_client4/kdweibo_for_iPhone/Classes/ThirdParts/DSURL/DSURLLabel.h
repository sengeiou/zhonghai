//
//  DSURLLabel.h
//  urltextview
//
//  Created by duansong on 10-10-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSStyleString.h"

@protocol DSURLLabelDelegate;

@interface DSURLLabel : UIView {
	NSString					*_urlString;
	UILabel						*_urlLabel;
//	id<DSURLLabelDelegate>		_delegate;
    DSStyle                     _style;
}

@property (nonatomic, retain) NSString					*urlString;
@property (nonatomic, retain) UILabel					*urlLabel;
@property (nonatomic, assign) id<DSURLLabelDelegate>	delegate;
@property (nonatomic)DSStyle                     style;

@end




@protocol DSURLLabelDelegate

@optional

- (void)urlTouchesBegan:(DSURLLabel *)urlLabel;
- (void)urlTouchesEnd:(DSURLLabel *)urlLabel;
- (void)urlTouchesCancle:(DSURLLabel *)urlLabel;

@end

