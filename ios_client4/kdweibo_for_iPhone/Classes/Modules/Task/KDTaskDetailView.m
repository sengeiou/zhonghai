//
//  KDTaskDetailView.m
//  kdweibo
//
//  Created by Tan yingqi on 13-7-8.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTaskDetailView.h"
#import "KDUser.h"
#import "NSDate+Additions.h"
#import "KDUtility.h"
#import "NSDate+Additions.h"
#define  TASK_DETAIL_HEIGH 38

@interface KDTaskDetailViewCell : UITableViewCell
@property(nonatomic,retain)UIImageView *iconImageView;
@property(nonatomic,retain)UILabel *leftLabel;
@property(nonatomic,retain)UILabel *rightLabel;
@end
@implementation KDTaskDetailViewCell
@synthesize iconImageView = iconImageView_;
@synthesize leftLabel = leftLabel_;
@synthesize rightLabel = rightLabel_;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 1)] ;//autorelease];
        backgroundView.backgroundColor = RGBCOLOR(238, 238, 238);
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.backgroundView = backgroundView;
        
        iconImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
        iconImageView_.backgroundColor = [UIColor clearColor];
        [self addSubview:iconImageView_];
        
        leftLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        leftLabel_.backgroundColor = [UIColor clearColor];
        [self addSubview:leftLabel_];
        
        rightLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        [rightLabel_ setBackgroundColor:[UIColor clearColor]];
        [self addSubview:rightLabel_];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [iconImageView_ sizeToFit];
    CGRect frame = iconImageView_.frame;
    frame.origin.x = 10;
    frame.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(frame))*0.5;
    iconImageView_.frame = frame;
    
    [leftLabel_ sizeToFit];
    frame = leftLabel_.frame;
    frame.origin.x = CGRectGetMaxX(iconImageView_.frame) + 10;
    frame.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(frame))*0.5;
    leftLabel_.frame = frame;
    
    if (rightLabel_.text) {
        [rightLabel_ sizeToFit];
        frame = rightLabel_.frame;
        frame.origin.x = CGRectGetMaxX(leftLabel_.frame)+10;
        frame.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(frame))*0.5;
        CGFloat width = MIN(172, CGRectGetWidth(frame));
        frame.size.width = width;
        rightLabel_.frame = frame;
    }
    
    UIView *view = self.backgroundView;
    view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 1);
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(iconImageView_);
    //KD_RELEASE_SAFELY(leftLabel_);
    //KD_RELEASE_SAFELY(rightLabel_);
    //[super dealloc];
}
@end

@interface KDTaskDetailView()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,retain)UITableView *tableView;

@end

@implementation KDTaskDetailView
@synthesize tableView = tableView_;
@synthesize task = task_;
@synthesize extraMessage = extraMessage_;

- (void)dealloc {
    //KD_RELEASE_SAFELY(task_);
    //KD_RELEASE_SAFELY(extraMessage_);
    //KD_RELEASE_SAFELY(tableView_);
    //[super dealloc];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
     
        tableView_ = [[UITableView alloc] initWithFrame:frame];
        tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:tableView_];
        tableView_.delegate = self;
        tableView_.dataSource = self;
        tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView_.rowHeight = TASK_DETAIL_HEIGH;
        UIImage *image = [UIImage imageNamed:@"attachment_bg_v2"];
        image = [image stretchableImageWithLeftCapWidth:image.size.width *0.5 topCapHeight:image.size.height *0.5];
        tableView_.backgroundView = [[UIImageView alloc] initWithImage:image];// autorelease];
        
        
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UIImageView *accesoryImageView = nil;
    KDTaskDetailViewCell *cell = (KDTaskDetailViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[KDTaskDetailViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];// autorelease];
        accesoryImageView = [[UIImageView alloc] initWithFrame:CGRectZero];// autorelease];
            [cell addSubview:accesoryImageView];
        accesoryImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            accesoryImageView.tag = 100;
    }
    accesoryImageView = (UIImageView *)[cell viewWithTag:100];
    if (accesoryImageView) {
        accesoryImageView.image = nil;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch (indexPath.row) {
        case 0:
            cell.iconImageView.image = [UIImage imageNamed:@"task_exector"];
            cell.leftLabel.text = ASLocalizedString(@"KDTaskDetailView_Operator");
            if (task_) {
                  cell.rightLabel.text = [[KDUtility defaultUtility] userNamesByUsers:task_.executors];
            }else if (extraMessage_) {
                cell.rightLabel.text = extraMessage_.exctorName;
             }
          
            break;
        case 1:
            cell.iconImageView.image = [UIImage imageNamed:@"task_date"];
            cell.leftLabel.text = ASLocalizedString(@"KDTaskDetailView_Deadline");
            if (task_) {
                  cell.rightLabel.text = [task_.needFinishDate formatWithFormatter:KD_DATE_ISO_8601_SHORT_FORMATTER];
            }else if (extraMessage_) {
                cell.rightLabel.text = [[NSDate dateWithTimeIntervalSince1970:extraMessage_.needFinishDate] formatWithFormatter:KD_DATE_ISO_8601_SHORT_FORMATTER];            }
            
            break;
        case 2:
            cell.iconImageView.image = [UIImage imageNamed:@"task_share_range"];
            cell.leftLabel.text = ASLocalizedString(@"KDTaskDetailView_share_field");
            if (task_) {
                if (task_.groupName) {
                    cell.rightLabel.text = task_.groupName;
                }else {
                    if ([task_.visibility isEqualToString:@"network"]) {
                        cell.rightLabel.text = ASLocalizedString(@"大厅");
                    }else {
                        cell.rightLabel.text = ASLocalizedString(@"私密");
                    }
                }
            }else if (extraMessage_) {
                NSString *visibily = extraMessage_.visibility;
                cell.rightLabel.text = visibily;
                if ([visibily isEqualToString:@"network"]) {
                    cell.rightLabel.text = ASLocalizedString(@"大厅");
                }else if([visibily isEqualToString:@"private"]) {
                    cell.rightLabel.text = ASLocalizedString(@"私密");
                }
            }
            
            break;
        case 3:  {
            
            cell.iconImageView.image = [UIImage imageNamed:@"task_eye"];
            cell.leftLabel.textColor = [UIColor whiteColor];
            cell.leftLabel.font = [UIFont systemFontOfSize:14.0f];
            if (task_) {
                cell.leftLabel.text = ASLocalizedString(@"KDTaskDetailView_Original_msg");
            }else {
                cell.leftLabel.text = ASLocalizedString(@"KDTaskDetailView_task_detail");
            }
            cell.rightLabel.text = nil;
            accesoryImageView.image = [UIImage imageNamed:@"status_doc_arrow_icon"];
            [accesoryImageView sizeToFit];
            CGRect frame = accesoryImageView.frame;
            frame.origin.x = CGRectGetWidth(cell.frame) - CGRectGetWidth(frame) - 10;
            frame.origin.y = (CGRectGetHeight(cell.frame) - CGRectGetHeight(frame))*0.5;
            accesoryImageView.frame = frame;
//            UIImage *image = [UIImage imageNamed:@"left_catalog_cell_secondary_bg_selected"];
//            image = [image stretchableImageWithLeftCapWidth:image.size.width *0.5 topCapHeight:image.size.height*0.5];
//            UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
            UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)];// autorelease];
            backgroundView.backgroundColor = UIColorFromRGBA(0x000000, 0.77f);
            cell.backgroundView = backgroundView;

        }
            break;
        default:
            break;
    }
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = 4;
    if (extraMessage_) {
        if (![extraMessage_ propertyForKey:@"access"]) {
            num = 3;
        }
    }else if (task_) {
        if (![task_ canCheckOrigin]) {
            num = 3;
        }
    }
    return num;
}

- (CGFloat)height {
    NSInteger num = [self tableView: nil numberOfRowsInSection:0];
    return num *TASK_DETAIL_HEIGH;
}
- (void)setTask:(KDTask *)task {
    if (task_ != task) {
//        [task_ release];
        task_ = task;// retain];
        //[self updateUI];
        [tableView_ reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 3) {
        if (task_) { //查看原信息
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"KDTaskDetailViewStatusCheckOrigin" object:self.nocationSender userInfo:@{@"task":task_}];
       
//             [[NSNotificationCenter defaultCenter] postNotificationName:@"KDTaskDetailViewStatusCheckOrigin" object:nil userInfo:@{@"task":task_}];
        }else { //查看任务详情
              [[NSNotificationCenter defaultCenter] postNotificationName:@"KDTaskDetailViewStatusDisclosure" object:self.nocationSender userInfo:@{@"taskId":extraMessage_.referenceId}];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
