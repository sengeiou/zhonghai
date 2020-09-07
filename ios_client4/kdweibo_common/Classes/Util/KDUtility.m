//
//  GAUtility.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-25.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDUtility.h"

#import "KDManagerContext.h"

#import "NSString+Additions.h"
#import "NSDate+Additions.h"
#import "KDCache.h"
#import "KDConfigurationContext.h"
#import "NSData+Additions.h"
#import "SDWebImageManager.h"


#define KD_APP_ROOT_PATH                        @"/"

#define KD_PERSITENT_PICTURES                   @"Pictures"
#define KD_PERSITENT_PICTURES_AVATAR            @"Avatars"
#define KD_PERSITENT_PICTURES_PREVIEW           @"Preview"
#define KD_PERSITENT_PICTURES_UNSEND            @"Unsend"
#define KD_PERSITENT_PICTURES_EMAIL             @"Email"

#define KD_PERSITENT_DOWNLOADS                  @"Downloads"
#define KD_PERSITENT_DOWNLOADS_DOC              @"Documents"
#define KD_PERSITENT_DOWNLOADS_TMP              @"Temp"
#define KD_PERSITENT_DOWNLOADS_AUDIO            @"Audio"
#define KD_PERSITENT_DOWNLOADS_AUDIO_TEMP       @"AudioTemp"
#define KD_PERSITENT_DOWNLOADS_AUDIO_UNSEND     @"Unsend"
#define KD_PERSITENT_DOWNLOADS_VIDEO            @"Video"

#define KD_PERSITENT_USER_DATABASE              @"Database"
#define KD_PERSITENT_USER_DOCUMENT              @"Documents"
#define KD_PERSITENT_USER_PREVIEW               @"Preview"
#define KD_PERSITENT_USER_THUMBNAIL             @"Thumbnails"
#define KD_PERSITENT_USER_LOGS                  @"Logs"


#define KD_TEMPORARY_APP_CACHE                  @"kdweibo"
#define KD_TEMPORARY_APP_TEMP                   @"Temp"
#define KD_TEMPORARY_USER_UPLOADS               @"Uploads"
#define KD_TEMPORARY_USER_DOWNLOADS             @"Downloads"

#define KD_PERSITENT_VIDEOS                     @"Videos"

///////////////////////////////////////////////////////////////////////////////////////////////////
//Email
#define KD_EMAIL_USER_DATABASE                  @"EmailDataBase"
#define KD_EMAIL_USER_DOWNLOAD                  @"EmailDownload"
#define KD_EMAIL_UPLOADS                        @"EmailUpLoads"
#define KD_EMAIl_USER_LOGS                      @"EmailLogs"

static KDUtility *_defaultUtility = nil;


@interface KDUtility ()

@property (nonatomic, copy, readonly) NSString *uniqueUserToken;
@property (nonatomic, retain) NSMutableDictionary *cachedPaths;


@end



@implementation KDUtility

@dynamic uniqueUserToken;
@synthesize cachedPaths=cachedPaths_;


- (id) init {
	self = [super init];
	if(self){
        uniqueUserToken_ = nil;
        cachedPaths_ = nil;
	}
	
	return self;
}

/////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark class utility methods

+ (KDUtility *) defaultUtility {
    @synchronized([KDUtility class]){
        if(_defaultUtility == nil){
            _defaultUtility = [[KDUtility alloc] init];
        }
    }
    
	return _defaultUtility;
}

+ (void) setDefaultUtility:(KDUtility *)defaultUtility {
    @synchronized([KDUtility class]){
        if(_defaultUtility != defaultUtility){
            _defaultUtility = defaultUtility;// retain];
        }
    }    
}

- (NSString *)uniqueUserToken {
    //KD_RELEASE_SAFELY(uniqueUserToken_);
    
     uniqueUserToken_ = [[KDManagerContext globalManagerContext].userManager.currentUserId copy];

    return uniqueUserToken_;
}

#pragma mark -
#pragma mark device and app status methods

- (BOOL)isActiveApplication {
	return UIApplicationStateActive == [UIApplication sharedApplication].applicationState;
}

- (BOOL)isHighResolutionDevice
{
    return [UIDevice isHighResolutionDevice];
}

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark file system methods

- (NSString *) getCachedSearchPathForKey:(NSString *)key {
    NSString *path = nil;
    if(key != nil && cachedPaths_ != nil){
        path = [cachedPaths_ objectForKey:key];
    }
    
    return path;
}

- (void) cacheSearchDirectoryPath:(NSString *)path forKey:(NSString *)key {
    if(path != nil && key != nil){
        if(cachedPaths_ == nil){
            cachedPaths_ = [[NSMutableDictionary alloc] init];
        }
        
        [cachedPaths_ setObject:path forKey:key];
    }
}

- (NSString *) buildSearchDirectory:(KDSearchPathDirectory)directory inDomainMask:(KDSearchPathDomainMask)domainMask {
    NSString *prefix = nil;
    NSString *suffix = nil;
    
    if(domainMask == KDPersitentDomainMask){
        switch (directory) {
            case KDDocumentDirectory:
                suffix = @"";
                break;
        
            default:
                break;
        }
        
        if(suffix != nil){
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            if([paths count] > 0){
                prefix = [paths objectAtIndex:0];
            }
        }
        
    } else if(domainMask == KDTemporaryDomainMask){
        switch (directory) {
            case KDPicturesDirectory:
                suffix = KD_PERSITENT_PICTURES;
                break;
                
            case KDPicturesAvatarDirectory:
                suffix = [KD_PERSITENT_PICTURES stringByAppendingPathComponent:KD_PERSITENT_PICTURES_AVATAR];
                break;
                
            case KDPicturesPreviewDirectory:
                suffix = [KD_PERSITENT_PICTURES stringByAppendingPathComponent:KD_PERSITENT_PICTURES_PREVIEW];
                break;
                
            case KDPicturesUnsendDirectory:
                suffix = [KD_PERSITENT_PICTURES stringByAppendingPathComponent:KD_PERSITENT_PICTURES_UNSEND];
                break;
            case KDPicturesEmailDirectory:
                suffix = [KD_PERSITENT_PICTURES stringByAppendingPathComponent:KD_PERSITENT_PICTURES_EMAIL];
                break;
            case KDDownloadDirectory:
                suffix = [self.uniqueUserToken stringByAppendingPathComponent:KD_PERSITENT_DOWNLOADS];
                break;
                
            case KDDownloadDocument:
                suffix = KD_PERSITENT_DOWNLOADS_DOC;
                break;
                
            case KDDownloadDocumentTemp:
                suffix = [self.uniqueUserToken stringByAppendingPathComponent:[KD_PERSITENT_DOWNLOADS stringByAppendingFormat:@"/%@",KD_PERSITENT_DOWNLOADS_TMP]];
                break;
                
            case KDDownloadAudio:
                suffix = KD_PERSITENT_DOWNLOADS_AUDIO;
                break;
                
            case KDDownloadAudioTemp:
                suffix = [KD_PERSITENT_DOWNLOADS_AUDIO stringByAppendingPathComponent:KD_PERSITENT_DOWNLOADS_AUDIO_TEMP];
                break;
                
            case KDDownloadAudioUnsend:
                suffix = [KD_PERSITENT_DOWNLOADS_AUDIO stringByAppendingPathComponent:KD_PERSITENT_DOWNLOADS_AUDIO_UNSEND];
                break;
                
            case KDUserDirectory:
                suffix = self.uniqueUserToken;
                break;
                
            case KDUserDatabaseDirectory:
                suffix = [self.uniqueUserToken stringByAppendingPathComponent:KD_PERSITENT_USER_DATABASE];
                break;
                
            case KDUserDocumentDirectory:
                suffix = [self.uniqueUserToken stringByAppendingPathComponent:KD_PERSITENT_USER_DOCUMENT];
                break;
                
            case KDUserPreviewDirectory:
                suffix = [self.uniqueUserToken stringByAppendingPathComponent:KD_PERSITENT_USER_PREVIEW];
                break;
                
            case KDUserThumbnailDirectory:
                suffix = [self.uniqueUserToken stringByAppendingPathComponent:KD_PERSITENT_USER_THUMBNAIL];
                break;
                
            case KDUserLogsDirectory:
                suffix = [self.uniqueUserToken stringByAppendingPathComponent:KD_PERSITENT_USER_LOGS];
                break;
                
            case KDApplicationTemporaryDirectory:
                suffix = [KD_TEMPORARY_APP_CACHE stringByAppendingPathComponent:KD_TEMPORARY_APP_TEMP];
                break;
            
            case KDUserUploadsDirectory:
                suffix = [[KD_TEMPORARY_APP_CACHE stringByAppendingPathComponent:self.uniqueUserToken]
                                                    stringByAppendingPathComponent:KD_TEMPORARY_USER_UPLOADS];
                
                break;
            
            case KDUserDownloadsDirectory:
                suffix = [[KD_TEMPORARY_APP_CACHE stringByAppendingPathComponent:self.uniqueUserToken]
                                                    stringByAppendingPathComponent:KD_TEMPORARY_USER_DOWNLOADS];
                
                break;
            case KDVideosDirectory:
                suffix = [KD_PERSITENT_VIDEOS stringByAppendingPathComponent:KD_PERSITENT_DOWNLOADS_VIDEO];
                break;
                
            case KDDownloadVideosTempDirectory:
                suffix = [KD_PERSITENT_VIDEOS stringByAppendingPathComponent:KD_TEMPORARY_APP_TEMP];
                break;
                
            default:
                break;
        }
        
        if(suffix != nil){
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            if([paths count] > 0){
                prefix = [paths objectAtIndex:0];
            }
        }
        
    }
    
    NSString *path = nil;
    if(prefix != nil && suffix != nil){
        path = [prefix stringByAppendingPathComponent:suffix];
    }
    
    return path;
}

- (NSString *) searchDirectory:(KDSearchPathDirectory)directory inDomainMask:(KDSearchPathDomainMask)domainMask needCreate:(BOOL)needCreate {
    NSString *key = [NSString stringWithFormat:@"%lu-%lu", (unsigned long)domainMask, (unsigned long)directory];
    NSString *path = [self getCachedSearchPathForKey:key];
    
    if(path == nil){
        path = [self buildSearchDirectory:directory inDomainMask:domainMask];
    }
    
    if(path != nil && needCreate){
        BOOL isDir = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
        if(!exists || !isDir){
            NSError *error = nil;
            BOOL succeed = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        
            if(!succeed && error != nil){
                NSLog(@"%@", [error localizedDescription]);
            }
        }
    }
    
    return path;
}

- (void) removeAllCachedDataForCurrentUser {
    // persitent folder
    NSString *path = [self searchDirectory:KDUserDirectory inDomainMask:KDPersitentDomainMask needCreate:NO];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
    
    // temporary folder
    path = [self searchDirectory:KDUserDirectory inDomainMask:KDTemporaryDomainMask needCreate:NO];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
    
}

- (KDUInt64)fileSizeForPath:(NSString*)path  {  //计算文件夹下文件的总大小
  
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) { //目录
        KDUInt64 fileSize = 0;
        NSArray *subArray = [fileManager contentsOfDirectoryAtPath:path error:NULL];
        for (NSString *subPath in subArray) {
            fileSize +=[self fileSizeForPath:[path stringByAppendingPathComponent:subPath]];
        }
        return fileSize;
        
    }
    else {
        if ([fileManager fileExistsAtPath:path]) { // 文件
             NSDictionary *fileAttributeDic=[fileManager attributesOfItemAtPath:path error:NULL];
            if (fileAttributeDic) {
                return fileAttributeDic.fileSize;
            }else {
                return 0;
            }
            //
        }
        else { // 不存在
            return 0;
        }
        
    }
        
}





//////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark file system utility methods

- (BOOL) isAppDocumentWithPath:(NSString *)path {
	if(path != nil){
        NSString *documentPath = [self searchDirectory:NSDocumentDirectory inDomainMask:KDTemporaryDomainMask needCreate:NO];
        if([path length] <= [documentPath length] 
		   || [[path stringByDeletingLastPathComponent] length] <= [[documentPath stringByDeletingLastPathComponent] length]){
			return YES;
		}	
	}
	
	return NO;
}

- (NSString *) pathByDeletingAppDocumentFromPath:(NSString *)path {
	NSString *results = nil;
	if(path != nil){
        NSString *documentPath = [self searchDirectory:NSDocumentDirectory inDomainMask:KDTemporaryDomainMask needCreate:NO];
        
		NSInteger fromIndex = [documentPath length];
		if([path length] > fromIndex){
			results = [path substringFromIndex:fromIndex];
		}
	}
	
	return results;
}

- (NSString *) pathByDeletingAppDocumentFromPath:(NSString *)path isDir:(BOOL)isDir {
	NSString *results = nil;
	if(path != nil){
		NSString *parentPath = (isDir) ? path : [path stringByDeletingLastPathComponent];
		results = ([self isAppDocumentWithPath:parentPath]) ? KD_APP_ROOT_PATH : [self pathByDeletingAppDocumentFromPath:parentPath];
	}
	
	return results;
}


- (NSString *)duplicateFileAtPath:(NSString *)srcPath toPath:(NSString *)toPath succeed:(BOOL *)succeed {
	if(srcPath == nil || toPath == nil){
		if(succeed != NULL)
			*succeed = NO;
		
		return nil;
	}
	
	NSString *filename = [srcPath lastPathComponent];
	NSString *destPath = [toPath stringByAppendingPathComponent:filename];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:destPath]){
		filename = [self uniqueNameAtPath:destPath];
		destPath = [toPath stringByAppendingPathComponent:filename];
	}
	
	BOOL flag = [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:destPath error:NULL];
	if(succeed != NULL)
		*succeed = flag;
	
	return filename;
}

- (NSString *) uniqueNameAtPath:(NSString *)path {
	if(path == nil)
		return nil;
	
	NSString *newName = nil;	
	NSString *name = [path lastPathComponent];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:path]){
		NSString *namePrefix = [name stringByDeletingPathExtension];
		NSString *nameSuffix = [name pathExtension];
		
		NSString *prefix = nil;
		NSString *suffix = nil;
        NSMutableArray *hits = [[NSMutableArray alloc] init];// autorelease];
		
		NSString *parentPath = [path stringByDeletingLastPathComponent];
		NSArray *subItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:parentPath error:NULL];
		
		if(subItems != nil){
			for(NSString *item in subItems){
				prefix = [item stringByDeletingPathExtension];
				suffix = [item pathExtension];
				
				if([prefix hasPrefix:namePrefix] && (NSOrderedSame == [nameSuffix caseInsensitiveCompare:suffix])){
					[hits addObject:item];
				}
			}
		}
		
		if([hits count] <= 1){
			newName = [namePrefix stringByAppendingFormat:@"(%d).%@", 1, nameSuffix];
			
		}else {
			BOOL found = NO;
			BOOL useIndex = NO;
			int boundary = 1;
			
			for(; boundary<=10; boundary++){
				found = NO;
				for(NSString *hit in hits){
					if(boundary>=10){
						break;
					}
					
					newName = [namePrefix stringByAppendingFormat:@"(%d)", boundary];
					if(NSOrderedSame == [newName caseInsensitiveCompare:[hit stringByDeletingPathExtension]]){
						found = YES;
						break;
					}
				}
				
				if(!found){
					useIndex = YES;
					break;
				}
			}
			
			if(boundary<10){
				if(!useIndex){
					boundary++;
				}
				newName = [namePrefix stringByAppendingFormat:@"(%d).%@", boundary, nameSuffix];
				
			}else {
				newName = [namePrefix stringByAppendingFormat:@" %@.%@", 
						   [[NSDate date] formatWithFormatter:KD_DATE_ISO_8601_LONG_FORMATTER], nameSuffix];
			}
		}
		
	}else {
		newName = name;
	}
	
	if([newName length]>1 && [newName hasSuffix:@"."]){
		newName = [newName substringToIndex:([newName length]-1)];
	}
	
	return newName;
}

- (KDCompositeImageSource *)compositeImageSourceByLocalImageSources:(NSArray *)sources {
    if (!sources ||[sources count] == 0) {
        return nil;
    }
    KDImageSource *imageSource;
    NSMutableArray *imageSoures = [NSMutableArray array];

    UIImage* image = nil;
    for (NSString *path in sources) {
        //
        imageSource = [[KDImageSource alloc] init];// autorelease];
        
        KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
        NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
    
        NSURL *url = [NSURL URLWithString:baseURL];
        
        baseURL = [NSString stringWithFormat:@"http://%@",[url host]];
        
        baseURL = [baseURL stringByAppendingString:@"/microblog/filesvr/"];
        
        imageSource.thumbnail = [baseURL stringByAppendingFormat:@"%@?thumbnail",imageSource.fileId];
        imageSource.middle = [baseURL stringByAppendingString:imageSource.fileId];
        imageSource.original = [baseURL stringByAppendingFormat:@"%@?big",imageSource.fileId];
        
        image = [UIImage imageWithContentsOfFile:path];
        if (image) {
            [[KDCache sharedCache] storeImage:image forURL:imageSource.original imageType:KDCacheImageTypeOrigin finishedBlock:^(BOOL finish) {
                [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.original type:KDCacheImageTypePreview];
                [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.original type:KDCacheImageTypePreviewBlur];
                [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.middle type:KDCacheImageTypeMiddle];
                [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.thumbnail type:KDCacheImageTypeThumbnail];
                
            }];
            //        [[KDCache sharedCache] storeImage:image forURL:imageSource.original imageType:KDCacheImageTypePreview];
            //        [[KDCache sharedCache] storeImage:image forURL:imageSource.original imageType:KDCacheImageTypePreviewBlur];
            //        [[KDCache sharedCache] storeImage:image forURL:imageSource.middle  imageType:KDCacheImageTypeMiddle];
            //        [[KDCache sharedCache] storeImage:image forURL:imageSource.thumbnail imageType:KDCacheImageTypeThumbnail];
            //        [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.original type:KDCacheImageTypePreview];
            //        [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.original type:KDCacheImageTypePreviewBlur];
            //        [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.middle type:KDCacheImageTypeMiddle];
            //        [[KDCache sharedCache] linkImageFromURL:imageSource.original sourceType:KDCacheImageTypeOrigin toURL:imageSource.thumbnail type:KDCacheImageTypeThumbnail];
            
            [imageSoures addObject:imageSource];
        }
        
    }
    if (imageSoures.count >0) {
        return [[KDCompositeImageSource alloc] initWithImageSources:imageSoures];// autorelease];
    }else {
        DLog(@"can not create KDCompositeImageSource");
        return nil;
    }
}


#pragma mark - About Status
- (BOOL)isMyStatus:(KDStatus *)status {
    KDUserManager *manager = [[KDManagerContext globalManagerContext] userManager];
    NSString *userId = [manager currentUserId];
    return [userId isEqualToString:status.author.userId];
}

- (NSString *)currentUserId {
    KDUserManager *manager = [[KDManagerContext globalManagerContext] userManager];
    return [manager currentUserId];
}

- (KDUser *)currentUser {
    KDUserManager *manager = [[KDManagerContext globalManagerContext] userManager];
    return [manager currentUser];
}
- (NSString *)userNamesByUsers:(NSArray *)users {
    NSUInteger count = (users != nil) ? [users count] : 0;
    if(count < 0x01) return nil;
    
    NSMutableString *names = [NSMutableString string];
    NSUInteger idx = 0;
    for(KDUser *item in users){
        [names appendString:item.screenName];
        if(idx++ != (count - 1)){
            [names appendString:@","];
        }
    }
    return names;
}

- (NSString *)currentCompanyId {
      KDCommunityManager *communityManager = [KDManagerContext globalManagerContext].communityManager;
      return communityManager.currentCompany.eid;
}

- (NSString *)companySpecifickey:(NSString *)key {
    return [NSString stringWithFormat:@"%@_%@_%@", [self currentCompanyId], [self currentUserId], key];
}

- (void) dealloc {
    
    //KD_RELEASE_SAFELY(uniqueUserToken_);
    //KD_RELEASE_SAFELY(cachedPaths_);
    
	//[super dealloc];
}

@end


/////////////////////////////////////////////////////////////////////////

// utility methods

NSTimeInterval millisecondsToSeconds(NSTimeInterval milliseconds) {
	return milliseconds / 1000.0;
}

NSTimeInterval secondsToMilliseconds(NSTimeInterval seconds) {
	return seconds * 1000.0;
}

