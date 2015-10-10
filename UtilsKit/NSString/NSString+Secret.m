//
//  NSString+MD5.m
//  lib51PKUserCenter
//
//  Created by L.T.ZERO on 14-4-24.
//  Copyright (c) 2014年 51pk. All rights reserved.
//

#import "NSString+Secret.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString(Secret)

- (NSString *)MD5String{

    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}
- (NSString *)hmacsha1WithKey:(NSString *)secret{
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    memset(cHMAC, 0, CC_SHA1_DIGEST_LENGTH);

    CCHmac(kCCHmacAlgSHA1, secret.UTF8String, strlen(secret.UTF8String), self.UTF8String, strlen(self.UTF8String), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];

    NSMutableString *hmacsha1 = [[NSMutableString alloc] init];
    for (int i = 0; i < HMACData.length; ++i){
        [hmacsha1 appendFormat:@"%02x", buffer[i]];
    }
    return hmacsha1;
}

- (NSString *)URLEncodedString {
    return (NSString *)CFBridgingRelease(
            CFURLCreateStringByAddingPercentEscapes(
                    kCFAllocatorDefault,
                    (__bridge CFStringRef)self,
                    CFSTR("!$&'()*+,-./:;=?@_~%#[]"),
                    NULL,
                    kCFStringEncodingUTF8));

}
- (NSString *)URLDecodedString {
    return [[self stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end
