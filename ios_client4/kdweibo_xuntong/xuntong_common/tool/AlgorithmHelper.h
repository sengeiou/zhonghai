//
//  AlgorithmHelper.h
//
//  Created by Gil on 7/1/11.
//  Edited by Gil on 2012.09.11
//  Copyright 2011 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface AlgorithmHelper : NSObject {
    
}

/*
 @desc MD5加密算法;
 @param str; -- 需要加密的字符串
 @return 加密后的字符串;
 */
+(NSString *)md5_Encrypt:(NSString *)str;

/*
 @desc DES加密算法,加密编码格式为NSUTF8StringEncoding;
 @param text; -- 需要加密的字符串
 @param key; -- 加密密钥
 @return 加密后的base64字符串;
 */
+(NSString *)des_Encrypt:(NSString *)text key:(NSString *)key;
+(NSData *)des_Encrypt2Data:(NSString *)text key:(NSString *)key;

/*
 @desc DES解密算法,解密编码格式为NSUTF8StringEncoding;
 @param text; -- 需要解密的base64字符串
 @param key; -- 解密密钥
 @return 解密后的字符串;
 */
+(NSString *)des_Decrypt:(NSString *)text key:(NSString *)key;
+(NSString *)des_DecryptWithData:(NSData *)text key:(NSString *)key;
+(NSData *)des_Decrypt2DataWithData:(NSData *)text key:(NSString *)key;

/*
 @desc RSA加密算法;
 @param content; -- 需要解密的内容
 @param publicKey; -- 加密公钥
 @param cust3gNo; -- 企业3G号，每个企业使用不同的公钥
 @return 加密后的字符串;
 */
+(NSString *)rsa_encrypt:(NSString *)content publicKey:(NSString *)key cust3gNo:(NSString *)cust3gNo;

@end
