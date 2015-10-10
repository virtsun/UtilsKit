//
//  NSString+MD5.h
//  lib51PKUserCenter
//
//  Created by L.T.ZERO on 14-4-24.
//  Copyright (c) 2014年 51pk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Secret)

- (NSString *)MD5String;
- (NSString *)hmacsha1WithKey:(NSString *)secret;
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

@end
