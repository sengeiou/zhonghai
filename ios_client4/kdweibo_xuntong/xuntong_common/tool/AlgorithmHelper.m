//
//  AlgorithmHelper.m
//
//  Created by Gil on 7/1/11.
//  Edited by Gil on 2012.09.11
//  Copyright 2011 Kingdee. All rights reserved.
//

#import "AlgorithmHelper.h"
#import "NSData+Base64.h"

@implementation AlgorithmHelper

-(id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - MD5

//md5加密算法
+(NSString *)md5_Encrypt:(NSString *)str
{
    if(str == nil || [str length] == 0)
        return nil;
    
    const char *value = [str UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (int)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

#pragma mark - DES

+(NSString *)des_Encrypt:(NSString *)text key:(NSString *)key
{
    NSData *result = [self des_Encrypt2Data:text key:key];
    return [result base64EncodedString];
}

+(NSData *)des_Encrypt2Data:(NSString *)text key:(NSString *)key
{
    const char* keyByte = (const char *)[key UTF8String];
    if (strlen(keyByte) != 8) {
        //取key的前8个字节,不足8位则补零
        char keyByteNew[8] = "\0\0\0\0\0\0\0\0";
        if (strlen(keyByte) > 8) {
            for (int i = 0; i < 8; i++) {
                keyByteNew[i] = keyByte[i];
            }
        }else{
            for (int i = 0; i < strlen(keyByte); i++) {
                keyByteNew[i] = keyByte[i];
            }
        }
        keyByte = keyByteNew;
    }
    
    AlgorithmHelper *alHelper = [[AlgorithmHelper alloc] init];
    NSData *result = [alHelper doCipher:[text dataUsingEncoding:NSUTF8StringEncoding] key:keyByte context:kCCEncrypt];
    return result;
}

+(NSString *)des_Decrypt:(NSString *)text key:(NSString *)key
{
    return [self des_DecryptWithData:[NSData dataFromBase64String:text] key:key];
}

+(NSString *)des_DecryptWithData:(NSData *)text key:(NSString *)key
{
    NSData *result = [self des_Decrypt2DataWithData:text key:key];
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

+(NSData *)des_Decrypt2DataWithData:(NSData *)text key:(NSString *)key
{
    //取key的前8个字节,不足8位则补零
    const char* keyByte = (const char *)[key UTF8String];
    if (strlen(keyByte) != 8) {
        //取key的前8个字节,不足8位则补零
        char keyByteNew[8] = "\0\0\0\0\0\0\0\0";
        if (strlen(keyByte) > 8) {
            for (int i = 0; i < 8; i++) {
                keyByteNew[i] = keyByte[i];
            }
        }else{
            for (int i = 0; i < strlen(keyByte); i++) {
                keyByteNew[i] = keyByte[i];
            }
        }
        keyByte = keyByteNew;
    }
    
    AlgorithmHelper *alHelper = [[AlgorithmHelper alloc] init];
    NSData *result = [alHelper doCipher:text key:keyByte context:kCCDecrypt];
    return result;
}

#pragma mark - RSA

+(NSString *)rsa_encrypt:(NSString *)content publicKey:(NSString *)key cust3gNo:(NSString *)cust3gNo
{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *peerKey = [[infoDict objectForKey:@"CFBundleIdentifier"] stringByAppendingFormat:@".%@",cust3gNo];
    
    NSData *keyData = [self stripPublicKeyHeader:[NSData dataFromBase64String:key]];
    SecKeyRef publicKey = [self addPeerPublicKey:peerKey keyBits:keyData];
    
    if (publicKey == NULL) {
        return nil;
    }
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    
    uint8_t *cipherBuffer = NULL;
    cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    memset((void *)cipherBuffer, 0*0, cipherBufferSize);
    
    NSData *plainTextBytes = [content dataUsingEncoding:NSUTF8StringEncoding];
    int blockSize = (int)cipherBufferSize-11;
    int numBlock = (int)ceil([plainTextBytes length] / (double)blockSize);
    
    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    
    for (int i=0; i<numBlock; i++) {
        int bufferSize = MIN(blockSize,(int)[plainTextBytes length]-i*blockSize);
        NSData *buffer = [plainTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(publicKey,
                                        kSecPaddingPKCS1,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length],
                                        cipherBuffer,
                                        &cipherBufferSize);
        if (status == noErr)
        {
            NSData *encryptedBytes = [[NSData alloc]
                                      initWithBytes:(const void *)cipherBuffer
                                      length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
        }
        else
        {
            return nil;
        }
    }
    
    if (cipherBuffer)
    {
        free(cipherBuffer);
    }
    
    return [encryptedData base64EncodedString];
}

#pragma mark - private

-(NSData *)des_Encrypt:(NSData *)plainText key:(NSData *)aSymmetricKey iv:(NSString *)initVec padding:(CCOptions *)pkcs7
{
    return [self doCipher:plainText key:aSymmetricKey context:kCCEncrypt iv:initVec padding:pkcs7];
}

-(NSData *)des_Decrypt:(NSData *)plainText key:(NSData *)aSymmetricKey iv:(NSString *)initVec padding:(CCOptions *)pkcs7
{
    return [self doCipher:plainText key:aSymmetricKey context:kCCDecrypt iv:initVec padding:pkcs7];
}

-(NSData *)doCipher:(NSData *)plainText key:(const void *)aSymmetricKey context:(CCOperation)encryptOrDecrypt
{
    CCCryptorStatus ccStatus = kCCSuccess;
    // Symmetric crypto reference.
    CCCryptorRef thisEncipher = NULL;
    // Cipher Text container.
    NSData * cipherOrPlainText = nil;
    // Pointer to output buffer.
    uint8_t * bufferPtr = NULL;
    // Total size of the buffer.
    size_t bufferPtrSize = 0;
    // Remaining bytes to be performed on.
    size_t remainingBytes = 0;
    // Number of bytes moved to buffer.
    size_t movedBytes = 0;
    // Length of plainText buffer.
    size_t plainTextBufferSize = 0;
    // Placeholder for total written.
    size_t totalBytesWritten = 0;
    // A friendly helper pointer.
    uint8_t * ptr;
    
    plainTextBufferSize = [plainText length];
    
    // Create and Initialize the crypto reference.
    ccStatus = CCCryptorCreate(encryptOrDecrypt,
                               kCCAlgorithmDES,
                               kCCOptionPKCS7Padding,
                               aSymmetricKey,
                               kCCKeySizeDES,
                               aSymmetricKey,// (const void *)iv,
                               &thisEncipher
                               );
    
    // Calculate byte block alignment for all calls through to and including final.
    bufferPtrSize = CCCryptorGetOutputLength(thisEncipher, plainTextBufferSize, true);
    
    // Allocate buffer.
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t) );
    
    // Zero out buffer.
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    // Initialize some necessary book keeping.
    
    ptr = bufferPtr;
    
    // Set up initial size.
    remainingBytes = bufferPtrSize;
    // Actually perform the encryption or decryption.
    ccStatus = CCCryptorUpdate(thisEncipher,
                               (const void *) [plainText bytes],
                               plainTextBufferSize,
                               ptr,
                               remainingBytes,
                               &movedBytes
                               );
    
    // Handle book keeping.
    ptr += movedBytes;
    remainingBytes -= movedBytes;
    totalBytesWritten += movedBytes;
    
    
    // Finalize everything to the output buffer.
    ccStatus = CCCryptorFinal(thisEncipher,
                              ptr,
                              remainingBytes,
                              &movedBytes
                              );
    
    totalBytesWritten += movedBytes;
    
    if(thisEncipher) {
        (void) CCCryptorRelease(thisEncipher);
        thisEncipher = NULL;
    }
    
    if (ccStatus == kCCSuccess)
        cipherOrPlainText = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)totalBytesWritten];
    else
        cipherOrPlainText = nil;
    
    if(bufferPtr) free(bufferPtr);
    
    return cipherOrPlainText;
}

-(NSData *)doCipher:(NSData *)plainText key:(NSData *)aSymmetricKey
            context:(CCOperation)encryptOrDecrypt iv:(NSString *)initVec padding:(CCOptions *)pkcs7
{
    if (initVec == nil) {
        initVec = @"12345678";
    }
    
    if (!*pkcs7) {
        *pkcs7 = kCCOptionPKCS7Padding;
    }
    
    CCCryptorStatus ccStatus = kCCSuccess;
    // Symmetric crypto reference.
    CCCryptorRef thisEncipher = NULL;
    // Cipher Text container.
    NSData * cipherOrPlainText = nil;
    // Pointer to output buffer.
    uint8_t * bufferPtr = NULL;
    // Total size of the buffer.
    size_t bufferPtrSize = 0;
    // Remaining bytes to be performed on.
    size_t remainingBytes = 0;
    // Number of bytes moved to buffer.
    size_t movedBytes = 0;
    // Length of plainText buffer.
    size_t plainTextBufferSize = 0;
    // Placeholder for total written.
    size_t totalBytesWritten = 0;
    // A friendly helper pointer.
    uint8_t * ptr;
    
    const void *vinitVec = (const void *) [initVec UTF8String];
    
    plainTextBufferSize = [plainText length];
    
    // Create and Initialize the crypto reference.
    ccStatus = CCCryptorCreate(encryptOrDecrypt,
                               kCCAlgorithmDES,
                               *pkcs7,
                               (const void *)[aSymmetricKey bytes],
                               kCCKeySizeDES,
                               vinitVec,// (const void *)iv,
                               &thisEncipher
                               );
    
    // Calculate byte block alignment for all calls through to and including final.
    bufferPtrSize = CCCryptorGetOutputLength(thisEncipher, plainTextBufferSize, true);
    
    // Allocate buffer.
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t) );
    
    // Zero out buffer.
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    // Initialize some necessary book keeping.
    
    ptr = bufferPtr;
    
    // Set up initial size.
    remainingBytes = bufferPtrSize;
    // Actually perform the encryption or decryption.
    ccStatus = CCCryptorUpdate(thisEncipher,
                               (const void *) [plainText bytes],
                               plainTextBufferSize,
                               ptr,
                               remainingBytes,
                               &movedBytes
                               );
    
    // Handle book keeping.
    ptr += movedBytes;
    remainingBytes -= movedBytes;
    totalBytesWritten += movedBytes;
    
    
    // Finalize everything to the output buffer.
    ccStatus = CCCryptorFinal(thisEncipher,
                              ptr,
                              remainingBytes,
                              &movedBytes
                              );
    
    totalBytesWritten += movedBytes;
    
    if(thisEncipher) {
        (void) CCCryptorRelease(thisEncipher);
        thisEncipher = NULL;
    }
    
    if (ccStatus == kCCSuccess)
        cipherOrPlainText = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)totalBytesWritten];
    else
        cipherOrPlainText = nil;
    
    if(bufferPtr) free(bufferPtr);
    
    return cipherOrPlainText;
}

+(SecKeyRef)addPeerPublicKey:(NSString *)peerName keyBits:(NSData *)publicKey {
    OSStatus sanityCheck = noErr;
    SecKeyRef peerKeyRef = NULL;
    CFTypeRef persistPeer = NULL;
    
    NSData * peerTag = [[NSData alloc] initWithBytes:(const void *)[peerName UTF8String] length:[peerName length]];
    NSMutableDictionary * peerPublicKeyAttr = [[NSMutableDictionary alloc] init];
    
    [peerPublicKeyAttr setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [peerPublicKeyAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [peerPublicKeyAttr setObject:peerTag forKey:(__bridge id)kSecAttrApplicationTag];
    [peerPublicKeyAttr setObject:publicKey forKey:(__bridge id)kSecValueData];
    [peerPublicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&persistPeer);
    
    if (persistPeer) {
        peerKeyRef = [self getKeyRefWithPersistentKeyRef:persistPeer];
    } else {
        [peerPublicKeyAttr removeObjectForKey:(__bridge id)kSecValueData];
        [peerPublicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
        // Let's retry a different way.
        sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&peerKeyRef);
    }
    
    if (persistPeer) CFRelease(persistPeer);
    
    return peerKeyRef;
}

+(SecKeyRef)getKeyRefWithPersistentKeyRef:(CFTypeRef)persistentRef {
    
    OSStatus sanityCheck = noErr;
    SecKeyRef keyRef = NULL;
    
    NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
    
    // Set the SecKeyRef query dictionary.
    [queryKey setObject:(__bridge id)persistentRef forKey:(__bridge id)kSecValuePersistentRef];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    // Get the persistent key reference.
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&keyRef);
    
    
    return keyRef;
}

+(NSData *)stripPublicKeyHeader:(NSData *)d_key
{
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);
    
    unsigned int len = (int)[d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx    = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}


@end
