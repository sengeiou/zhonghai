//
//  KDInboxListViewController.h
//  kdweibo
//
//  Created by bird on 13-7-1.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDRefreshTableView.h"

enum InboxType{
    
    kInboxTypeAll =1,
    kInboxTypeComment,
    kInboxTypeMeion
};
typedef enum InboxType InboxType;

@interface KDInboxListViewController : UIViewController<KDRefreshTableViewDataSource, KDRefreshTableViewDelegate>
{
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
- (id)initWithInboxType:(InboxType)type;
@end
