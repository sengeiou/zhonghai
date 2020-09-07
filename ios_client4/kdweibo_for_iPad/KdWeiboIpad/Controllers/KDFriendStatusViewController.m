//
//  KDFriendStatusViewController.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-3.
//
//

#import "KDFriendStatusViewController.h"
#import "KDFriendStatusDataProvider.h"
@interface KDFriendStatusViewController ()

@end

@implementation KDFriendStatusViewController

- (void)initWithDataProvider {
    self.dataProvider = [[[KDFriendStatusDataProvider alloc] initWithViewController:self] autorelease];
}

@end
