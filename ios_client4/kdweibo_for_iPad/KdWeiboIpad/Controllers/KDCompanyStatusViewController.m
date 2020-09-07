//
//  KDCompanyStatusViewController.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-1.
//
//

#import "KDCompanyStatusViewController.h"
#import "KDCompanyStatusDataProvider.h"

@interface KDCompanyStatusViewController ()

@end

@implementation KDCompanyStatusViewController

- (void)initWithDataProvider {
    self.dataProvider = [[[KDCompanyStatusDataProvider alloc] initWithViewController:self] autorelease];
}

@end
