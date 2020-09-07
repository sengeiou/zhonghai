//
//  KDDMThreadMembersViewController.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-3.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDDMThread.h"
#import "KDRequestWrapper.h"
#import "KDDMParticipantPickerView.h"
#import "KDDMConversationViewController.h"

@interface KDDMThreadMembersViewController : UIViewController <KDRequestWrapperDelegate> {
@private
    KDDMThread *dmThread_;
    NSString *dmThreadId_;
    NSMutableArray *users_;
    
    struct {
        unsigned int initilization:1;
    }viewControllerFlags_;
    
    
    KDDMParticipantPickerView *pickerView_;

}

@property (nonatomic, retain) KDDMParticipantPickerView *pickerView;
@property (nonatomic, retain) KDDMThread *dmThread;
@property (nonatomic, copy)   NSString   *dmThreadId;

@property (nonatomic,assign) KDDMConversationViewController * conversationViewController;

- (void)updateDMThreadSubject:(NSString *)subject completedBlock:(id (^)(BOOL, BOOL))block;

@end
