//
//  HttpsRequest.m
//
//  Created by L.T.ZERO on 14-3-5.
//  Copyright (c) 2014年 sunlantao. All rights reserved.
//

#import "LeHttpsRequest.h"

@interface LeHttpsRequest()<NSURLConnectionDelegate>
@end

@implementation LeHttpsRequest

//- (void)dealloc{
//    NSLog(@"%s", __FUNCTION__);
//}

- (void)startAsyncRequest {
    [ [NSURLConnection connectionWithRequest:[self makeURLRequest] delegate:self] start];
}

+ (LeHttpsRequest *)requestWithURL:(NSString *)url method:(HttpRequestMethod)method{
    LeHttpsRequest *request = [[LeHttpsRequest alloc] init];
    request.url = url;
    request.method = method;

    return request;
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {

    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {

    NSURLCredential* credential;
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        //服务器证书认证
        credential= [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    }
    else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
        //客户端证书认证
        //TODO:设置客户端证书认证
        credential = nil;
    }

    if (credential != nil) {
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    } else {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

@end
