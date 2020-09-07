//
//  KDMentionMeStatusViewController.m
//  KdWeiboIpad
//
//  Created by Tan yingqi on 13-4-3.
//
//

#import "KDMentionMeStatusViewController.h"
#import "KDMentionMeStatusDataProvider.h"

@interface KDMentionMeStatusViewController ()

@end

@implementation KDMentionMeStatusViewController

- (void)initWithDataProvider {
    self.dataProvider = [[[KDMentionMeStatusDataProvider alloc] initWithViewController:self] autorelease];
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *identifier = @"cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
//    }
//    KDStatus *status = [dataProvider_.dataSet statusAtIndex:indexPath.row ];
//    cell.textLabel.text = status.text;
//    return cell;
//    // return [dataProvider_ timelineStatusCellInTableView:tableView status:status];
//}

@end
