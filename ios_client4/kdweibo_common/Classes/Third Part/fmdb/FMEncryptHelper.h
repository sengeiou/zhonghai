#import <Foundation/Foundation.h>
#import "sqlite3.h"

static NSString *encryptKey_ = @"IU*LAFJO*&UJR*&YUI4$#T)>3^:}9T#!~%R";

@interface FMEncryptHelper : NSObject

/** 对数据库加密 */
+ (BOOL)encryptDatabase:(NSString *)path;

/** 对数据库解密 */
+ (BOOL)unEncryptDatabase:(NSString *)path;

/** 对数据库加密 */
+ (BOOL)encryptDatabase:(NSString *)sourcePath targetPath:(NSString *)targetPath;

/** 对数据库解密 */
+ (BOOL)unEncryptDatabase:(NSString *)sourcePath targetPath:(NSString *)targetPath;

/** 修改数据库秘钥 */
+ (BOOL)changeKey:(NSString *)dbPath originKey:(NSString *)originKey newKey:(NSString *)newKey;

@end
