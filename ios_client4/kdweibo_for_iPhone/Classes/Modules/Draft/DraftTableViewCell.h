//
//  DraftViewControllerCell.h
//  TwitterFon
//
//  Created by kingdee on 11-6-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommenMethod.h"
#import "KDProgressIndicatorView.h"

@class KDDraft;

@interface DraftTableViewCell : UITableViewCell {
@private    
    KDDraft *draft_;
    
    UILabel *creationDateLabel_;
    UILabel *draftTypeLabel_;
    
    UILabel *contentLabel_;
    UIImageView *imageAttachmentImageView_;
    UIImageView *videoAttachmentImageView_;
    
    UIImageView *forwardImageView_;
    UILabel *forwardContentLabel_;
    
    UILabel *groupNameLabel_;
    
    UIImageView *separatorImageView_;
    
    KDProgressIndicatorView *sendingProgress_;
    
    UILabel *sendingLabel;
}

@property (nonatomic, retain) KDDraft *draft;
@property (nonatomic, retain) KDProgressIndicatorView *sendingProgress;
@property (nonatomic, assign) BOOL isSending;

- (void) refresh;

@end
