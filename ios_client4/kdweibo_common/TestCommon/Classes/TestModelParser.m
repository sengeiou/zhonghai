//
//  TestModelParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-10.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "TestModelParser.h"
#import "KDParserManager.h"

#import "KDStatus.h"
#import "KDMentionMeStatus.h"
#import "KDCommentMeStatus.h"
#import "KDCommentStatus.h"

#import "KDDMThread.h"
#import "KDDMMessage.h"

#import "KDABPerson.h"
#import "KDUnread.h"
#import "KDVote.h"
#import "KDVoteOption.h"

#import "KDGroup.h"

@interface TestModelParser()

@property(nonatomic, retain) NSString *path;

@end


@implementation TestModelParser

@synthesize path=path_;

- (void)setUp {
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:[TestModelParser class]];
    self.path = [bundle resourcePath];
}

- (void)tearDown {
    [super tearDown];
    
    //KD_RELEASE_SAFELY(path_);
}

- (id)parseJSONContentWithSourceName:(NSString *)sourceName {
    id results = nil;
    
    NSString *sourcePath = [path_ stringByAppendingPathComponent:sourceName];
    NSData *data = [NSData dataWithContentsOfFile:sourcePath];
    if (data) {
        NSError *error = nil;
        results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (error != nil) {
            NSLog(@"can not parse the json with path=%@ error=%@", sourcePath, error);
        }
    }
    
    return results;
}

- (void)testActions {
    [self _parsePublicTimelineStatuses];
    
    [self _parseMentionMeStatuses];
    
    [self _parseCommentMeStatuses];
    
    [self _parseCommentsByCursor];
    
    [self _parsePublicTimelineStatuses];
    
    [self _parseDMThreads];
    
    [self _parseDMThreadMessages];
    
    [self _parseABPersons];
    
    [self _parseUnread];
    
    [self _parseVotes];
    
    [self _parseGroups];
}

- (void)_parsePublicTimelineStatuses {
    NSArray *items = [self parseJSONContentWithSourceName:@"statuses_public_timeline.json"];
    if (items != nil) {
        KDStatusParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDStatusParser class]];
        NSArray *statuses = [parser parseAsStatuses:items type:KDTLStatusTypePublic];
        
        STAssertTrue([statuses count] == 50, @"There are 50 statuses in json file");
        
        KDStatus *s = statuses[0];
        STAssertNil(s.forwardedStatus, @"There is no forwarded status in this status");
        
        STAssertNil(s.extendStatus, @"There is no extend status in this status");
        
        STAssertNotNil(s.extraMessage, @"There is extra message in this status");
        
        STAssertNil(s.compositeImageSource, @"There is no composite image source in this status");
        
        STAssertNil(s.attachments, @"There is no attachements in this status");
        
        STAssertEqualObjects(s.statusId, @"50adb1d024acfbac8937b9bf", @"The status id must be same");
        
        s = statuses[4];
        STAssertNotNil(s.forwardedStatus, @"There is a forwarded status in this status");
        STAssertEqualObjects(s.forwardedStatus.statusId, @"5097791324accf98bad6045b", @"The forwarded status id must be same");
        
        STAssertNotNil(s.forwardedStatus.author, @"The author of forwarded status can not be nil");
        
        s = statuses[49];
        STAssertNotNil(s.extendStatus, @"There is a extended status in this status");
        
        STAssertNotNil(s.extendStatus.senderName, @"extended status sender name can not be nil");
        STAssertNotNil(s.extendStatus.forwardedSenderName, @"extended status forwarded name can not be nil");
        STAssertNotNil(s.extendStatus.content, @"extended status content can not be nil");
        STAssertNotNil(s.extendStatus.forwardedContent, @"extended status forwarded content can not be nil");
        STAssertTrue([s.extendStatus.compositeImageSource hasImageSource], @"extended status has image");
        
        s = statuses[41];
        STAssertTrue([s.extraMessage isPraise], @"the extra message is praise");
        STAssertEqualObjects(s.extraMessage.extraId, @"5089ec9824ac22ba092dc98e", @"The extra message id must be same");
    
    } else {
        STFail(@"Can not load the public timeline statuses by json file");
    }
}

- (void)_parseMentionMeStatuses {
    NSArray *items = [self parseJSONContentWithSourceName:@"mentions_to_me.json"];
    if (items != nil) {
        KDStatusParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDStatusParser class]];
        NSArray *statuses = [parser parseAsMentionMeStatuses:items];
        
        STAssertTrue([statuses count] == 20, @"There are 20 statuses in json file");
        
        KDStatus *s = statuses[0];
        STAssertNil(s.forwardedStatus, @"There is no forwarded status in this status");
        
        STAssertNil(s.extendStatus, @"There is no extend status in this status");
        
        STAssertNil(s.extraMessage, @"There is no extra message in this status");
        
        STAssertNil(s.compositeImageSource, @"There is no composite image source in this status");
        
        STAssertTrue([s.attachments count] == 2, @"There are 2 attachements in this status");
        
        STAssertEqualObjects(s.statusId, @"50b589ad24ace50386b061ac", @"The status id must be same");
        
        s = statuses[8];
        STAssertNotNil(s.forwardedStatus, @"There is a forwarded status in this status");
        
        STAssertNotNil(s.forwardedStatus.author, @"The author of forwarded status can not be nil");
    
    } else {
        STFail(@"Can not load the mention me statuses by json file");
    }
}

- (void)_parseCommentMeStatuses {
    NSArray *items = [self parseJSONContentWithSourceName:@"comments_to_me.json"];
    if (items != nil) {
        KDStatusParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDStatusParser class]];
        NSArray *statuses = [parser parseAsCommentMeStatuses:items];
        
        STAssertTrue([statuses count] == 11, @"There are 11 statuses in json file");
        
        KDCommentMeStatus *s = statuses[0];
        STAssertNil(s.forwardedStatus, @"There is no forwarded status in this status");
        
        STAssertNil(s.extendStatus, @"There is no extend status in this status");
        
        STAssertNil(s.extraMessage, @"There is no extra message in this status");
        
        STAssertNil(s.compositeImageSource, @"There is no composite image source in this status");
        
        STAssertNil(s.attachments, @"There are no attachements in this status");
        
        STAssertEqualObjects(s.statusId, @"50a4aa6024acc380a8d4133a", @"The status id must be same");
        
        STAssertNotNil(s.replyStatusText, @"in reply to status text is not nil");
    
    } else {
        STFail(@"Can not load the comment me statuses by json file");
    }
}

- (void)_parseCommentsByCursor {
    NSDictionary *body = [self parseJSONContentWithSourceName:@"comments_by_cursor.json"];
    if (body != nil) {
        NSArray *items = [body objectNotNSNullForKey:@"comments"];
        
        KDStatusParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDStatusParser class]];
        NSArray *statuses = [parser parseAsCommentStatuses:items];
        
        STAssertTrue([statuses count] == 8, @"There are 8 statuses in json file");
        
        KDCommentStatus *s = statuses[1];
        STAssertEqualObjects(s.statusId, @"5003c17124acba8524181278", @"The status id must be same");
        STAssertEqualObjects(s.replyUserId, @"4e1669d3cce79c8d549c6df1", @"The reply user id must be same");
    
    } else {
        STFail(@"Can not load the comments by json file");
    }
}

- (void)_parseDMThreads {
    NSDictionary *body = [self parseJSONContentWithSourceName:@"dm_threads.json"];
    if (body != nil) {
        NSArray *items = [body objectNotNSNullForKey:@"threads"];
        
        KDDMThreadParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDDMThreadParser class]];
        NSArray *threads = [parser parse:items];
        
        STAssertTrue([threads count] == 20, @"There are 20 dm threads in json file");
        
        KDDMThread *t = threads[0];
        STAssertTrue(t.unreadCount == 6, @"There are 6 unread count");
        STAssertTrue(t.participantsCount == 14, @"There are 14 participants count");
        STAssertTrue(t.isPublic, @"this is public dm thread");
        
        STAssertEqualObjects(t.latestDMId, @"50b70ff6e4b07e989ae30c82", @"The thread'message id must be same");
    
    } else {
        STFail(@"Can not load the dm threads by json file");
    }
}

- (void)_parseDMThreadMessages {
    NSArray *items = [self parseJSONContentWithSourceName:@"dm_messages.json"];
    if (items != nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            KDDMMessageParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDDMMessageParser class]];
            NSArray *messages = [parser parseAsDMMessageList:items];
        
            STAssertTrue([messages count] == 4, @"There are 4 dm thread messages in json file");
            
            KDDMMessage *m = messages[0];
            
            STAssertEqualObjects(m.messageId, @"5005247ce4b0c3813fdf8506", @"The message id must be same");
            STAssertEqualObjects(m.sender.userId, @"4f6ab6e9e4b03be9ea33925f", @"The sender id must be same");
        });
        
    } else {
        STFail(@"Can not load the dm messages by json file");
    }
}

- (void)_parseABPersons {
    NSDictionary *body = [self parseJSONContentWithSourceName:@"ab_person_member_list_simple.json"];
    if (body != nil) {
        NSArray *items = [body objectNotNSNullForKey:@"list"];
        
        KDABPersonParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDABPersonParser class]];
        NSArray *persons = [parser parse:items type:KDABPersonTypeRecently];
        
        STAssertTrue([persons count] == 20, @"There are 20 ab persons in json file");
        
        KDABPerson *p = persons[0];
        
        STAssertEqualObjects(p.pId, @"509372b724ac46fb9503a3d7", @"The person id must be same");
        STAssertEqualObjects(p.userId, @"4e1fcad4cce73e504ebfc40d", @"The user id must be same");
        STAssertEqualObjects(p.networkId, @"383cee68-cea3-4818-87ae-24fb46e081b1", @"The network must be same");
        
        STAssertEqualObjects(p.jobTitle, @"Chief Admin", @"The job title must be same");
        STAssertEqualObjects(p.department, @"Admin office", @"The department must be same");
        
        STAssertTrue([p.emails count] == 2, @"There are 2 emails");
        
        STAssertNotNil(p.profileImageURL, @"The profile url can not be nil");
    
    } else {
        STFail(@"Can not load the ab persons by json file");
    }
}

- (void)_parseUnread {
    NSDictionary *body = [self parseJSONContentWithSourceName:@"unread.json"];
    if (body != nil) {
        KDCompositeParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDCompositeParser class]];
        KDUnread *unread = [parser parseAsUnread:body];
        
        STAssertNotNil(unread, @"The unread can not be nil");
        
        STAssertTrue(unread.newStatus == 1, @"There is exist 1 new status");
        STAssertTrue(unread.friendsStatuses == 62, @"There are exists 62 friend statuses");
        STAssertTrue(unread.notices == 5, @"There are exists 5 notices");
        
        STAssertTrue([unread unreadForGroupId:@"4fed439524acba70a56a03c2"] == 195, @"There are exists 195 group unreads");
        STAssertTrue([unread unreadForGroupId:@"4e8346a6cce759fbdeca458e"] == 67, @"There are exists 67 group unreads");
        
        STAssertTrue([unread unreadForCommunityId:@"011166"] == 12, @"There are 12 community unreads");
        STAssertTrue([unread unreadForCommunityId:@"012473"] == 5, @"There are 5 community unreads");
        
        STAssertTrue([unread noticeForCommunityId:@"007056"] == 1, @"There is 1 community notices");
        STAssertTrue([unread noticeForCommunityId:@"004844"] == 1, @"There is 1 community notices");
    
    } else {
        STFail(@"Can not load the unread by json file");
    }
}

- (void)_parseVotes {
    NSArray *body = [self parseJSONContentWithSourceName:@"vote_popular_all.json"];
    if (body != nil) {
        STAssertTrue([body count] == 5, @"There are 5 votes");
        
        KDVoteParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDVoteParser class]];
        
        NSDictionary *item = body[0];
        KDVote *v = [parser parse:item];
        STAssertNotNil(v, @"The vote can not be nil");
        
        STAssertTrue([v.voteId isEqualToString:@"4f1686e124ac5c307165525f"], @"the vote id must be same");
        STAssertTrue([v.author.userId isEqualToString:@"4e093fecf82481f54ff910c2"], @"the user id must be same");
        
        STAssertTrue((v.createdTime > 1326876385.0 - 0.001 && v.createdTime < 1326876385.0 + 0.999), @"time must in range");
        STAssertTrue(v.isEnded, @"this vote has been closed");
        
        STAssertTrue(v.maxVoteItemCount == 1, @"this is a single vote");
        STAssertTrue(v.participantCount == 1928, @"There are 1928 participants");
        
        STAssertTrue(!v.votedVote, @"not been voted this vote");
        //STAssertTrue([v.statusId isEqualToString:@"4f1686e124ac5c307165526d"], @"the status id must be same");
        
        NSArray *options = v.voteOptions;
        STAssertTrue([options count] == 13, @"There are 13 vote options");
        
        KDVoteOption *option = options[0];
        STAssertTrue([option.optionId isEqualToString:@"4f1686e124ac5c3071655265"], @"the option id must be same");
        STAssertTrue(option.count == 0, @"the option count must be 0");
        
    } else {
        STFail(@"Can not load the unread by json file");
    }
}

- (void)_parseGroups {
    NSArray *body = [self parseJSONContentWithSourceName:@"group_joined.json"];
    if (body != nil) {
        STAssertTrue([body count] == 15, @"There are 15 groups");
        
        KDGroupParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDGroupParser class]];
        NSArray *groups = [parser parseAsGroupList:body];
        
        STAssertTrue([groups count] == 15, @"There are 15 groups");
        
        KDGroup *g = groups[0];
        STAssertNotNil(g, @"The group can not be nil");
        
        STAssertTrue([g.groupId isEqualToString:@"4f137222cce7da5f0634ec33"], @"group id must be same");
        STAssertNotNil(g.name, @"group name can not be nil");
        STAssertNotNil(g.profileImageURL, @"the profile image url can not be nil");
        STAssertNotNil(g.summary, @"the summary not be nil");
        STAssertNotNil(g.bulletin, @"the bulletin can not be nil");
        
        STAssertTrue([g isPrivate], @"this is private group");
        
    } else {
        STFail(@"Can not load the groups by json file");
    }
}

- (void)dealloc {
    //[super dealloc];
}

@end
