//
//  KDCommentToMeViewController.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-3.
//
//

#import "KDCommentToMeViewController.h"
#import "KDCommentToMeDataProvider.h"
#import "KWICommentMPCell.h"
#import "KWIStatusVCtrl.h"
@interface KDCommentToMeViewController ()

@end

@implementation KDCommentToMeViewController

- (void)initWithDataProvider {
    self.dataProvider = [[[KDCommentToMeDataProvider alloc] initWithViewController:self] autorelease];
}

- (UITableViewCell *)loadCellForStatus:(KDStatus *)status {
    KWICommentMPCell *cell = [self.cellCache objectForKey:status.statusId];
    if (nil == cell) {
        cell = [KWICommentMPCell cell];
        cell.data = (KDCommentMeStatus *)status;
        [self.cellCache setObject:cell forKey:status.statusId];
    }
    
    return cell;
    
}
- (void)cellSelected {
    KWIStatusVCtrl *vctrl = [KWIStatusVCtrl vctrlWithStatusId:self.selectStatus.replyStatusId];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusVCtrl.show" object:self userInfo:inf];
}

@end
