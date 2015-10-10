//
// Created by sunlantao on 15/6/2.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import "UUIDMaker.h"


@implementation UUIDMaker {

}

+ (NSString *)UUIDString
{
    CFUUIDRef    uuidObj = CFUUIDCreate(nil);//create a new UUID

    //get the string representation of the UUID

    NSString    *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);

    CFRelease(uuidObj);

    return uuidString ;

}
@end