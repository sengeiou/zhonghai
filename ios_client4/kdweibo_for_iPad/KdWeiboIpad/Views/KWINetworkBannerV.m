//
//  KWINetworkBannerV.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/7/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWINetworkBannerV.h"

#import "UIImageView+WebCache.h"

#import "KDCommunity.h"

@implementation KWINetworkBannerV
{
    UILabel *_unreadCountV;
    UIImageView *_unreadBgV;
}

@synthesize network = _network;

+ (KWINetworkBannerV *)viewWithNetwork:(KDCommunity *)network
{
    return [[[self alloc] initWithNetwork:network] autorelease];
}

- (id)initWithNetwork:(KDCommunity *)network
{
    UIImageView *bgv = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"networkBanner.png"]] autorelease];
    self = [super initWithFrame:bgv.frame];
    if (self) {
        self.network = network;
        
        [self addSubview:bgv];
        
        __block UIImageView *logoV = [[[UIImageView alloc] initWithFrame:CGRectMake(19, 19, 80, 80)] autorelease];
        UIImage *ph = [network isCompany] ?[UIImage imageNamed:@"defCompanyLogo.png"]:[UIImage imageNamed:@"defNetworkLogo.png"];
        logoV.image = ph;
        [self addSubview:logoV];
        if (network.logoURL) {
            [logoV setImageWithURL:[NSURL URLWithString:network.logoURL]
                  placeholderImage:ph
                           success:^(UIImage *image, BOOL cached) {
                               CGRect imgFrame = logoV.frame;
                               imgFrame.size = image.size;
                               imgFrame.origin.x += (80 - imgFrame.size.width) / 2;
                               imgFrame.origin.y += (80 - imgFrame.size.height) / 2;
                               logoV.frame = imgFrame;
                           } 
                           failure:^(NSError *error) {
                               // silently
                           }];
        }
        
        UILabel *nameV = [[[UILabel alloc] initWithFrame:CGRectMake(10, 104, self.frame.size.width - 21, 18)] autorelease];
        nameV.backgroundColor = [UIColor clearColor];
        nameV.font = [UIFont systemFontOfSize:12];
        nameV.textColor = [UIColor colorWithHexString:@"555"];       
        nameV.textAlignment = UITextAlignmentCenter;
        nameV.text = network.name;
        [self addSubview:nameV];
        
        _unreadBgV = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"networkUnreadCountBg.png"]] autorelease];
        CGRect unreadBgFrame = _unreadBgV.frame;
        unreadBgFrame.origin.x = 12;
        unreadBgFrame.origin.y = 0;
        _unreadBgV.frame = unreadBgFrame;
        _unreadBgV.hidden = YES;
        [self addSubview:_unreadBgV];
        
        CGRect unreadCountFrame = unreadBgFrame;
        unreadCountFrame.origin.y = 1;
        unreadCountFrame.size.height = 18;
        _unreadCountV = [[[UILabel alloc] initWithFrame:unreadCountFrame] autorelease];
        _unreadCountV.backgroundColor = [UIColor clearColor];
        _unreadCountV.font = [UIFont systemFontOfSize:12];
        _unreadCountV.textColor = [UIColor whiteColor];       
        _unreadCountV.textAlignment = UITextAlignmentCenter;
        _unreadCountV.shadowColor = [UIColor blackColor];
        _unreadCountV.shadowOffset = CGSizeMake(1, 1);
        [self addSubview:_unreadCountV];
        
//        if (network.notices) {
//            _unreadCountV.text = [NSString stringWithFormat:@"%d", network.notices];
//            _unreadBgV.hidden = NO;
//        }
//        
//        [network addObserver:self forKeyPath:@"notices" options:NSKeyValueObservingOptionNew context:nil];
        
        /*KWEngine *api = [KWEngine sharedEngine];
        [api request:@"statuses/unread.json" 
              params:nil
                data:nil
              method:@"GET"
             network:network
           onSuccess:^(NSDictionary *result) { //NSLog(@"%@", network.sub_domain_name); NSLog(@"%@", result); //NSLog(@"%@", [network.sub_domain_name class]); //NSLog(@"%@", result);
               NSNumber *countNum = [result objectForKey:@"notices"]; 
               if (countNum && countNum.intValue) {
                   unreadCountV.text = [NSString stringWithFormat:@"%d", countNum.intValue];
                   unreadBgV.hidden = NO;
               }

               
               count += [[result objectForKey:@"comments"] intValue];
               
               for (NSNumber *v in [[result objectForKey:@"communityNotices"] allValues]) {
                   count += v.intValue;
               }
               
               for (NSNumber *v in [[result objectForKey:@"communityUnreads"] allValues]) {
                   count += v.intValue;
               }
               
               count += [[result objectForKey:@"dm"] intValue];
               
               count += [[result objectForKey:@"mentions"] intValue];
               
               count += [[result objectForKey:@"new_status"] intValue];
               
               count += [[result objectForKey:@"statuses"] intValue];
               
               unreadCountV.text = [NSString stringWithFormat:@"%d", count]; 
           } 
             onError:^(NSError *err) {
                 //NSLog(@"%@", err);
             }];*/
        
        UITapGestureRecognizer *tgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTapped:)] autorelease];
        [self addGestureRecognizer:tgr];
    }
    return self;
}

- (void)dealloc
{
    //[self.network removeObserver:self forKeyPath:@"notices"];
    [_network release];
    [super dealloc];
}

- (void)_onTapped:(UITapGestureRecognizer *)tgr
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWNetwork.selected" 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:self.network forKey:@"network"]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([@"notices" isEqualToString:keyPath] && (object == self.network)) {
        NSNumber *noticesNum = [change objectForKey:@"new"];
        if (noticesNum) {
            _unreadCountV.text = noticesNum.stringValue;
            _unreadBgV.hidden = (0 == noticesNum.intValue);
        }
    }
}

@end
