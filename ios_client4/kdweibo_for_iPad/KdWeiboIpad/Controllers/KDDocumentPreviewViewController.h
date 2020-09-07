//
//  KDDocumentPreviewViewController.h
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-27.
//
//

#import <UIKit/UIKit.h>
#import "KWIRPanelVCtrl.h"
@class KDDownload;
@interface KDDocumentPreviewViewController : UIViewController<KWICardlikeVCtrl>
@property(nonatomic,retain)KDDownload *download;
- (void)shouldFullScreened:(BOOL)should;
- (IBAction)closeBtnTapped:(id)sender;
- (void)replaceTootViewControllerOfNavgationCongtroller;

@end
