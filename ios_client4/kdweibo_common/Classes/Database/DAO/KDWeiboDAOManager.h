//
//  KDWeiboDAOManager.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-7.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDABPersonDAO.h"
#import "KDDownloadDAO.h"
#import "KDAttachmentDAO.h"
#import "KDUserDAO.h"
#import "KDGroupDAO.h"
#import "KDCompositeImageSourceDAO.h"
#import "KDDraftDAO.h"
#import "KDDMThreadDAO.h"
#import "KDDMMessageDAO.h"
#import "KDVoteDAO.h"
#import "KDStatusDAO.h"
#import "KDExtendStatusDAO.h"
#import "KDStatusExtraMessageDAO.h"
#import "KDTopicDAO.h"
#import "KDInboxDAO.h"
#import "KDTodoDAO.h"
#import "KDSigninRecordDAO.h"
#import "KDApplicationDAO.h"

@interface KDWeiboDAOManager : NSObject

+ (KDWeiboDAOManager *)globalWeiboDAOManager;

- (id<KDABPersonDAO>)ABPersonDAO;
- (id<KDDownloadDAO>)downloadDAO;
- (id<KDAttachmentDAO>)attachmentDAO;
- (id<KDUserDAO>)userDAO;
- (id<KDGroupDAO>)groupDAO;
- (id<KDCompositeImageSourceDAO>)compositeImageSourceDAO;
- (id<KDDraftDAO>)draftDAO;
- (id<KDDMThreadDAO>)dmThreadDAO;
- (id<KDDMMessageDAO>)dmMessageDAO;
- (id<KDVoteDAO>)voteDAO;
- (id<KDStatusDAO>)statusDAO;
- (id<KDExtendStatusDAO>)extendStatusDAO;
- (id<KDStatusExtraMessageDAO>)statusExtraMessageDAO;
- (id<KDTopicDAO>)topicDAO;
- (id<KDInboxDAO>)inboxDAO;
- (id<KDTodoDAO>) todoDAO;
- (id<KDSigninRecordDAO>)signinDAO;
- (id<KDApplicationDAO>)applicationDAO;
@end
