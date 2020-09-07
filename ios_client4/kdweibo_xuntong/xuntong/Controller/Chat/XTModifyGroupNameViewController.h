//
//  EdidGroupNameViewController.h
//  ContactsLite
//
//  Created by kingdee eas on 13-2-28.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol XTModifyGroupNameViewControllerDelegate;
@class GroupDataModel;
@interface XTModifyGroupNameViewController : UIViewController {
    
}
@property (nonatomic, weak) id<XTModifyGroupNameViewControllerDelegate> delegate;

- (id)initWithGroup:(GroupDataModel *)group;

@end


@protocol XTModifyGroupNameViewControllerDelegate <NSObject>

- (void)modifyGroupNameDidFinish:(XTModifyGroupNameViewController *)controller groupName:(NSString *)groupName;

@end
