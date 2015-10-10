//
//  HttpsRequest.h
//
//  Created by L.T.ZERO on 14-3-5.
//  Copyright (c) 2014年 sunlantao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LeHttpRequest.h"

@interface LeHttpsRequest : LeHttpRequest{
}
+ (LeHttpsRequest *)requestWithURL:(NSString *)url method:(HttpRequestMethod)method;

@end
