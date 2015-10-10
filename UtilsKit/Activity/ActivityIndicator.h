//
//  ActivityIndicator.h
//  com_wuyao_platform
//
//  Created by L.T.ZERO on 14-9-19.
//  Copyright (c) 2014年 51pk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityIndicator : NSObject

+ (void)show;
+ (void)show:(NSString*)message;
+ (void)dismiss;

@end
