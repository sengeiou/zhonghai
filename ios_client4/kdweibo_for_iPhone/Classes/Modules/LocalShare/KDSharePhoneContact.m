//
//  KDSharePhoneContact.m
//  kdweibo
//
//  Created by weihao_xu on 14-8-14.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDSharePhoneContact.h"
#import "KDABHelper.h"
#import "KDABPerson.h"
#import "SBJSON.h"

static NSString *const filePathExponent = @"phoneContact";
static const char *serialQueueName = "com.kdweibo.startAccessingAddressQueue";
static KDSharePhoneContact *defaultContactManager = nil;

static inline NSString *sharePhoneFilePath(){
    NSString *path = [[KDUtility defaultUtility]searchDirectory:KDUserDatabaseDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];
    path = [path stringByAppendingPathComponent:filePathExponent];
    return path;
}

@interface KDSharePhoneContact(){
    dispatch_queue_t queue;
}
@property (nonatomic, retain)NSMutableArray *phoneContactArray;
@end

@implementation KDSharePhoneContact
@synthesize phoneContactArray = phoneContactArray_;
+ (KDSharePhoneContact *)defaultContactManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultContactManager = [[KDSharePhoneContact alloc]init];
    });
    return defaultContactManager;
}

- (id)init{
    if(self = [super init]){
    }
    return self;
}

- (void)startAccessingAddressPerson{
    
    queue = dispatch_queue_create(serialQueueName, NULL);
    
    dispatch_async(queue, ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        if([fm fileExistsAtPath:sharePhoneFilePath()]){
            [self sharePersonContactWithOldPersionContact:[self getPhoneContactFromFile]];
        }
        else{
            [self sharePersonContactWithOldPersionContact:nil];
        }
    });
//    dispatch_release(queue);
}


//把数组转换成data数据的字典
- (NSArray *)transferKDABRecordsToNSDictionary{
    NSMutableArray *dicArray = [[NSMutableArray alloc]initWithCapacity:[phoneContactArray_ count]];//autorelease];
    for(KDABPerson *person in phoneContactArray_){
        NSDictionary *recordDic = [NSDictionary dictionaryWithObjectsAndKeys:person.name,@"name",
                                   person.mobiles,@"phones",
                                   person.emails,@"emails",
                                   nil];
        [dicArray addObject:recordDic];
    }
    return [NSArray arrayWithArray:dicArray];
}


//分享通讯录至网络服务器
- (void)sharePhoneContactInfoWithWillSaveContacts : (NSArray *)saveContacts{
    return ;
    if([phoneContactArray_ count] > 0){
        SBJSON *sbJson = [[SBJSON alloc]init];//autorelease];
        NSError *error = nil ;
        NSString *data = [sbJson stringWithObject:[self transferKDABRecordsToNSDictionary] error:&error];
        if(error) {
            DLog(@"%@",error);
            return;
        }
        NSString *userid = [[[KDManagerContext globalManagerContext]userManager]currentUser].userId;

        KDQuery *query = [KDQuery query];
        [query setParameter:@"userid" stringValue:userid];

        [query setParameter:@"data" stringValue:data];
        __block KDSharePhoneContact *weakSelf = self;
        [KDServiceActionInvoker invokeWithSender:self actionPath:@"/infocollect/:contact" query:query configBlock:nil completionBlock:^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
            if([results[@"success"] isEqualToNumber:[NSNumber numberWithInt:1]]){
                DLog(@"上传通讯录成功");
                //上传通讯录成功之后才保存于本地
                weakSelf.phoneContactArray = [NSMutableArray arrayWithArray:saveContacts];
                [weakSelf storePhoneContactToFile];
            }
            else{
                DLog(@"%@",results[@"errorMessage"]);
            }
        }];
    }
}
//保存到本地文件
- (void)storePhoneContactToFile{
    [NSKeyedArchiver archiveRootObject:phoneContactArray_ toFile:sharePhoneFilePath()];
}
//从本地文件获取通讯录
- (NSArray *)getPhoneContactFromFile{
    NSArray *localPhoneContact = [NSKeyedUnarchiver unarchiveObjectWithFile:sharePhoneFilePath()];
    return localPhoneContact;
}

- (void)sharePersonContactWithOldPersionContact : (NSArray *)oldPersons{

    self.phoneContactArray = [NSMutableArray arrayWithArray: [KDABHelper allPhoneCompleteContacts]];
            

    if(oldPersons == nil){
        //分享到服务器
        [self sharePhoneContactInfoWithWillSaveContacts:phoneContactArray_];
    }
    else{
        //找出文件差，发送请求
        NSArray *allPhoneContacts = [NSArray arrayWithArray:phoneContactArray_];
        for(KDABPerson *oldPerson in oldPersons){
            for (KDABPerson *newPerson in phoneContactArray_) {
                if([oldPerson.md5String isEqualToString:newPerson.md5String]){
                    [phoneContactArray_ removeObject:newPerson];
                    break;
                }
            }
            if(phoneContactArray_.count == 0){
                break;
            }
        }
        //分享到服务器

        [self sharePhoneContactInfoWithWillSaveContacts:allPhoneContacts];
    }
}

- (void)cancelSharePhoneContact{
    if(queue){
//        dispatch_release(queue);
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    }
}

- (void)dealloc{
    
    //KD_RELEASE_SAFELY(phoneContactArray_);
    //[super dealloc];
}

@end
