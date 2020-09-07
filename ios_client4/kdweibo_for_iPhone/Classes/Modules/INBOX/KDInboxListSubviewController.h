//
//  KDInboxListSubviewController.h
//  kdweibo
//
//  Created by AlanWong on 14-6-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDRefreshTableView.h"

enum KDInboxType{
    KDInboxTypeAll =0,
    KDInboxTypeMetion,
    KDInboxTypeComment
    
};
typedef enum KDInboxType KDInboxType;
@interface KDInboxListSubviewController : UIViewController<KDRefreshTableViewDataSource,KDRefreshTableViewDelegate>{
    struct
    {
        unsigned int pageIndex;
        unsigned int pageSize;
        
        unsigned int sort;
        BOOL    desc;
        
       __unsafe_unretained NSString *type;
        double  latestTime;
        double  farestTime;
        
        unsigned int firstLoad;
        
    }_flag;
}
@property(nonatomic,assign) KDInboxType inboxType;

- (id)initWithInboxType:(KDInboxType )type;


@end
