//
//  KDDocumentsAllListViewController.h
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-26.
//
//

#import <UIKit/UIKit.h>
#import "KWIRPanelVCtrl.h"
@interface KDDocumentsAllListViewController : UIViewController<KWICardlikeVCtrl>
@property(nonatomic,retain)NSArray *downloadArray;
@property(nonatomic,retain)id data;  //status or dmmessage
@end
