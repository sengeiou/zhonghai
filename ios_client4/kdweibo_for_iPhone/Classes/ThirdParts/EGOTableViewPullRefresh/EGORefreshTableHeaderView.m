//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"
#import "ResourceManager.h"




@implementation EGORefreshTableHeaderView

@synthesize state=_state;
@synthesize reloading = reloading_;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
    {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIImage *imageTest=[UIImage imageNamed:@"refresh_backgroud.png"];
        backGroudView=[[UIImageView alloc ]initWithImage:imageTest];//autorelease];
        [self addSubview:backGroudView];
        backGroudView.frame=CGRectMake(0,frame.size.height-300,320,300);
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = TEXT_COLOR;
        
		
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
//		[label release];

		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"EGORefreshTableView_LastRefresh"]) {
			_lastUpdatedLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"EGORefreshTableView_LastRefresh"];
		} else {
			[self setCurrentDate:nil];
		}
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = TEXT_COLOR;
		//label.shadowColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
		//label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
//		[label release];
		
		CALayer *layer = [[CALayer alloc] init];
		layer.frame = CGRectMake(25.0f, frame.size.height - 48.0f, 22.0f, 28.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"downflag_black.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
//		[layer release];
		
		
        
        footImage=[[UIImageView alloc ]initWithImage:[UIImage imageNamed:@"footImage.png"]];//autorelease];
        footImage.frame=CGRectMake(19,frame.size.height - 43.0f,31,31);
        [self addSubview:footImage];
        footImage.hidden=true;
        
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		view.frame = CGRectMake(25, frame.size.height - 38.0f, 20.0, 20.0);
		[self addSubview:view];
		_activityView = view;
//		[view release];
		
		[self setState:EGOOPullRefreshNormal];		
       // self.backgroundColor = [UIColor colorWithRed:67.0/255.0 green:76.0/255.0 blue:83.0/255.0 alpha:1.0];
    }
    return self;
}

-(void) setEGOStyle:(int)egoStyle
{
    _egoStyle=egoStyle;
    if(egoStyle==1)
    {
        self.backgroundColor=[ResourceManager defaultBackGroudColor] ;
        _lastUpdatedLabel.textColor = [UIColor blackColor];
        _statusLabel.textColor = [UIColor blackColor];
        
        /*[_arrowImage removeFromSuperlayer];
        CALayer *layer = [[CALayer alloc] init];
		layer.frame = CGRectMake(25.0f, self.frame.size.height - 48.0f, 22.0f, 28.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"downflag_black.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		[layer release];*/
        [backGroudView removeFromSuperview];
    }
    else
    {
        self.backgroundColor = [UIColor colorWithRed:67.0/255.0 green:76.0/255.0 blue:83.0/255.0 alpha:1.0];
        _lastUpdatedLabel.textColor = TEXT_COLOR;
        _statusLabel.textColor = TEXT_COLOR;
        
       /* [_arrowImage removeFromSuperlayer];
        CALayer *layer = [[CALayer alloc] init];
		layer.frame = CGRectMake(25.0f, self.frame.size.height - 48.0f, 22.0f, 28.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"downflag_blug.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		[layer release];*/
    }
}

- (void)setCurrentDate:(NSDate *) date;
{
	if(date==nil)
	{
		_lastUpdatedLabel.text=@"";
	}
	else 
	{
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:ASLocalizedString(@"KDSignInCell_Morning")];
		[formatter setPMSymbol:ASLocalizedString(@"KDSignInCell_Afternoon")];
		[formatter setDateFormat:@"MM-dd hh:mm:ss a"];
		_lastUpdatedLabel.text = [NSString stringWithFormat:ASLocalizedString(@"UpdateTime"), [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
//		[formatter release];
	}

}/*RefreshTableFootView.m*/

- (void)setState:(EGOPullRefreshState)aState{
    
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			_statusLabel.text = ASLocalizedString(@"Release_refresh");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
            _statusLabel.text = ASLocalizedString(@"PullDown_refresh");
			[_activityView stopAnimating];
            if(_egoStyle==1)
                footImage.hidden=TRUE;
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = ASLocalizedString(@"RefreshTableFootView_Loading");
			[_activityView startAnimating];
            if(_egoStyle==1)
                footImage.hidden=FALSE;
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

- (void)dealloc {
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    //[super dealloc];
}


@end
