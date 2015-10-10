//
// Created by sunlantao on 15/4/1.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import "NSString+Ext.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@implementation NSString(Ext)

- (CGSize)constrained:(CGSize)constrainedSize font:(UIFont *)font{

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font.copy, NSParagraphStyleAttributeName:paragraphStyle.copy};

    CGSize size = [self sizeWithAttributes:attributes];

    return CGSizeMake(MIN(constrainedSize.width, size.width), MIN(size.height, constrainedSize.height));
}

- (void)enumerateCharactorUseInBlock:(void (^)(NSRange, NSString *, BOOL))block{

    NSParameterAssert(block != nil);

    NSRange range;
    for(NSUInteger i=0; i< self.length; i+= range.length){
        range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *subString = [self substringWithRange:range];

        block(range, subString, i + range.length >= self.length);

    }

}


- (NSString*)transfromToChineseSpell{

    NSMutableString *ms=[[NSMutableString alloc] initWithString:self];

    if(CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)){
        if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)){
            [ms replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ms.length)];
            return ms;
        }
    }

    return nil;
}

- (BOOL)isHttpURL{
    NSString *regularStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
   // NSRegularExpression *expression = NSRegularExpression re
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularStr];

    return [predicate evaluateWithObject:self];
}


@end