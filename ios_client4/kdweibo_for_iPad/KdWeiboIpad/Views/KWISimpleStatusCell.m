//
//  KWISimpleStatusCell.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWISimpleStatusCell.h"

#import "KWIPeopleVCtrl.h"
#import "KWIStatusContent.h"
#import "KDStatus.h"
#import "KDUser.h"

@interface KWISimpleStatusCell ()

@property (retain, nonatomic) IBOutlet UILabel *usernameV;
@property (retain, nonatomic) IBOutlet UIView *inrCtnPh;
@property (retain, nonatomic) KWIStatusContent *inrCtn;

@end

@implementation KWISimpleStatusCell
@synthesize usernameV;
@synthesize inrCtnPh;
@synthesize inrCtn = _inrCtn;

@synthesize data = _data;

+ (KWISimpleStatusCell *)cell
{
    UIViewController *tmpVCtrl = [[[UIViewController alloc] initWithNibName:@"KWISimpleStatusCell" bundle:nil] autorelease];
    KWISimpleStatusCell *cell = (KWISimpleStatusCell *)tmpVCtrl.view;     
    
    return cell;
}

- (void)dealloc {
    [_data release];
    [_inrCtn release];
    
    [usernameV release];
    [inrCtnPh release];
    [super dealloc];
}

#pragma mark -
- (void)setData:(KDStatus *)data
{
    [_data release];
    _data = [data retain];
    
    self.usernameV.text = data.author.username;
    
    self.inrCtn = [KWIStatusContent viewForStatus:data frame:self.inrCtnPh.frame contentFontSize:14];
    [self.inrCtnPh removeFromSuperview];
    self.inrCtnPh = nil;
    [self addSubview:self.inrCtn];
    
    CGRect frame = self.frame;
    frame.size.height  = CGRectGetMaxY(self.inrCtn.frame);
    self.frame = frame;
}
@end
