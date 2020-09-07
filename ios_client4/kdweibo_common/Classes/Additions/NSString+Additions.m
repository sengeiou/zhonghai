//
//  NSString+Additions.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-25.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "NSString+Additions.h"
#import "pinyin.h"

static char randomTable[62] = {
	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
	'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
	'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
	'w','x','y','z','0','1','2','3','4','5','6','7','8','9'};



unsigned char randomSeedTable[256] = {
    0,   8, 109, 220, 222, 241, 149, 107,  75, 248, 254, 140,  16,  66 ,
    74,  21, 211,  47,  80, 242, 154,  27, 205, 128, 161,  89,  77,  36 ,
    95, 110,  85,  48, 212, 140, 211, 249,  22,  79, 200,  50,  28, 188 ,
    52, 140, 202, 120,  68, 145,  62,  70, 184, 190,  91, 197, 152, 224 ,
    149, 104,  25, 178, 252, 182, 202, 182, 141, 197,   4,  81, 181, 242 ,
    145,  42,  39, 227, 156, 198, 225, 193, 219,  93, 122, 175, 249,   0 ,
    175, 143,  70, 239,  46, 246, 163,  53, 163, 109, 168, 135,   2, 235 ,
    25,  92,  20, 145, 138,  77,  69, 166,  78, 176, 173, 212, 166, 113 ,
    94, 161,  41,  50, 239,  49, 111, 164,  70,  60,   2,  37, 171,  75 ,
    136, 156,  11,  56,  42, 146, 138, 229,  73, 146,  77,  61,  98, 196 ,
    135, 106,  63, 197, 195,  86,  96, 203, 113, 101, 170, 247, 181, 113 ,
    80, 250, 108,   7, 255, 237, 129, 226,  79, 107, 112, 166, 103, 241 ,
    24, 223, 239, 120, 198,  58,  60,  82, 128,   3, 184,  66, 143, 224 ,
    145, 224,  81, 206, 163,  45,  63,  90, 168, 114,  59,  33, 159,  95 ,
    28, 139, 123,  98, 125, 196,  15,  70, 194, 253,  54,  14, 109, 226 ,
    71,  17, 161,  93, 186,  87, 244, 138,  20,  52, 123, 251,  26,  36 ,
    17,  46,  52, 231, 232,  76,  31, 221,  84,  37, 216, 165, 212, 106 ,
    197, 242,  98,  43,  39, 175, 254, 145, 190,  84, 118, 222, 187, 136 ,
    120, 163, 236, 249
};

static int kGuardRandomIndex = 0;

int nextRandomSeed(void) {
    kGuardRandomIndex = (kGuardRandomIndex + 1) & 0xFF;
    return randomSeedTable[kGuardRandomIndex];
}


@implementation NSString (KD_Additions)

+ (NSString *)randomStringWithWide:(int)randomWide {
	int randomWideSafety = randomWide;
	if(randomWide < 0x01 || randomWide > 0x0F){
		randomWideSafety = 0x08;
	}
	
	char randomCodes[randomWideSafety+1];
    memset(randomCodes, '\0', randomWideSafety+1);
    
	int count = sizeof(randomTable)/sizeof(char) - 1;
	for(int i=0; i<randomWideSafety; i++){
		randomCodes[i] = randomTable[nextRandomSeed() % count];
	}
    
	NSString *randomStr = [NSString stringWithCString:randomCodes encoding:NSUTF8StringEncoding];
	
	return randomStr;
}

+ (NSString *)formatContentLengthWithBytes:(KDUInt64) bytes {
	NSString *contentLengthInStr = nil;
	static KDUInt64 base = 0x0400;
	
	if (bytes >= pow(base, 3)) {
		contentLengthInStr = [NSString stringWithFormat:@"%0.2f GB", (bytes+0.0)/pow(base, 3)];
		
	} else if (bytes >= pow(base, 2)) {
		contentLengthInStr = [NSString stringWithFormat:@"%0.2f MB", (bytes+0.0)/pow(base, 2)];
		
	} else if (bytes >= base) {
		contentLengthInStr = [NSString stringWithFormat:@"%0.2f KB", (bytes+0.0)/base];
		
	} else {
		contentLengthInStr = [NSString stringWithFormat:@"%0.2f B", (bytes+0.0)];
	}
	
	return contentLengthInStr;
}

- (NSString*)encodeAsURLWithEncoding:(NSStringEncoding)encoding {
	NSString *newString = nil;
	if(self != nil){
//		newString = NSMakeCollectable((NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(encoding)));
        newString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(encoding)));
	}
    
    
	
	return (newString != nil) ? newString : @"";
}

- (NSString *)escapeAsURLQueryParameter {
    if(self == nil) {
        return nil;
    }
    
    NSString* escapedValue = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    
    return escapedValue;
}

- (NSString *)searchAsURLQueryWithNeedle:(NSString *)needle {
    if(self == nil || needle == nil) return nil;
    
    NSString * str = nil;
    NSRange start = [self rangeOfString:needle];
    if (start.location != NSNotFound) {
        NSRange end = [[self substringFromIndex:start.location+start.length] rangeOfString:@"&"];
        NSUInteger offset = start.location + start.length;
        str = (end.location == NSNotFound) ? [self substringFromIndex:offset]
                                            : [self substringWithRange:NSMakeRange(offset, end.location)];
        
        str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return str;
}


/////////////////////////////////////////////////////////////////////////////

- (NSInteger)textLength {
    if(self == nil || [self length] == 0){
        return 0;
    }
    
    float number = 0.0;
    for (int index = 0; index < [self length]; index++) {
        NSString *character = [self substringWithRange:NSMakeRange(index, 1)];
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3) {
            number++;
            
        } else {
            number = number + 0.5;
        }
    }
    
    return ceil(number);
}

- (NSString *)MD5DigestKey {
	if(self == nil){
		return nil;
	}
    
	const char* str = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, strlen(str), result);
	
	NSString *key = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
					 result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
					 result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
	
	return key;
}


static NSString * const chinesePolyphone =@"曾解仇朴查能乐单";
static NSString * const mappedChinesePolyphoneCharacters = @"ZXQPZNYS";

- (unichar)firstChineseToPolyphoneCharacter {
    unichar ch = '\0';
    
    NSString *str = [self substringToIndex:0x01];
    NSRange range = [chinesePolyphone rangeOfString:str];
    if(NSNotFound != range.location){
        ch = [mappedChinesePolyphoneCharacters characterAtIndex:range.location];
    }
    
    return ch;
}

- (unichar)convertFirstToAZCharacter {
    if(self == nil || [self length] < 1){
        return '\0';
    }
    
    unichar ch = [self firstChineseToPolyphoneCharacter];
    if('\0' != ch){
        return ch;
    }
    
    ch = [self characterAtIndex:0x00];
    ch = pinyinFirstLetter(ch);

    return ch;
}

// 好人 -> HR    你好吗  ->  NHM
- (NSString *)convertChineseToAZSequence {
    if(self == nil || [self length] < 1){
        return @"";
    }
    
    NSMutableString *strs = [NSMutableString string];
    
    NSUInteger len = [self length];
    
    unichar ch = '\0';
    unichar temp = '\0';
    int idx = 0;
    for(; idx < len; idx++){
        ch = [self characterAtIndex:idx];
        if(ch > 128){
            temp = ch;
            
            // not ASCII code
            ch = [self firstChineseToPolyphoneCharacter];
            if('\0' == ch){
                ch = pinyinFirstLetter(temp);
            }
        }
        
        [strs appendFormat:@"%c", ch];
    }
    
    return strs;
}

- (NSUInteger)convertFirstCharacterToAZIndex {
    if(self == nil || [self length] < 1){
        return NSNotFound;
    }
    
    unichar ch = [self characterAtIndex:0x00];
    unichar temp = ch;
    
    ch = [self firstChineseToPolyphoneCharacter];
    if('\0' == ch){
        ch = pinyinFirstLetter(temp);
    }
    
    NSRange range = [ALPHA rangeOfString:[[NSString stringWithFormat:@"%c", ch] uppercaseString]];
    return range.location;
}

//去掉开头的"/"
- (NSString *)stringByAdjustingToValidURLSuffix {
    NSString *string = nil;
    NSRange range = NSMakeRange(0, 1);
    if ([[self substringWithRange:range]isEqualToString:@"/"]) {
        string = [self stringByReplacingCharactersInRange:range withString:@""];
    }
    return string;
}

- (NSString *)stringByRemovingDMSubjectPostfix {
    NSString *string = self;
    NSRegularExpression *regx= [NSRegularExpression regularExpressionWithPattern:ASLocalizedString(@"NSString+Additions_regx")options:0 error:nil];
    NSRange range = [regx rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    if (range.location != NSNotFound) {
        string = [self stringByReplacingCharactersInRange:range withString:@""];

    }
    return string;

}

//- (NSString *)truncateLocationInfo {
//    NSString *result = nil;
//    if (self && self.length >0) {
//        NSRange range = [self rangeOfString:ASLocalizedString(@"NSString+Additions_Me")options:NSBackwardsSearch];
//        if (NSNotFound != range.location) {
//            //
//            result = [self substringToIndex:range.location];
//        }
//        else {
//            result = self;
//        }
//    }
//    return result;
//}
//
//- (NSString *)stringByAddLocationInfo:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate {
//    //http://www.amap.com/?q=22.534101,113.954924&name=%E9%AB%98%E6%96%B0%E5%8D%97%E4%B8%83%E9%81%93&dev=0
//    NSString *result = nil;
//    NSString *url = [NSString stringWithFormat:@"http://www.amap.com/?q=%f,%f&name=%@&dev=0",(float)coordinate.latitude,(float)coordinate.longitude,address];
//    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    result = [self stringByAppendingFormat:ASLocalizedString(@"NSString+Additions_Me_In"),address,url];
//    
//    return result;
//}
+ (NSString *)getGuid {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
	//get the string representation of the UUID
	NSString	*uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
	CFRelease(uuidObj);
	return uuidString ;
}
@end
