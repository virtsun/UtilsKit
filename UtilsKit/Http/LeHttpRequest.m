//
//  HttpRequest.m
//
//  Created by L.T.ZERO on 14-3-5.
//  Copyright (c) 2014年 sunlantao. All rights reserved.
//
//
#import "LeHttpRequest.h"

//#import "JSON.h"

@implementation HttpResultObjc

+ (id)objectWith:(int)code reason:(NSString *)reason  objc:(id)objc{

    HttpResultObjc *retObjc = [[HttpResultObjc alloc] init];

    retObjc.code = code;
    retObjc.reason = reason;
    retObjc.object = [objc copy];

    return retObjc;
}

@end

@implementation LeHttpRequest{
    NSMutableData *_responseData;
    NSURLConnection *_connection;

    CGFloat _progress;
    int64_t _expectLength;

}

@synthesize params;

- (id)init{

    if (self = [super init]) {
        _timesOfRetry = 0;
        _maxTimesOfRetry = 3;
        _bodyType = HTTP_BODY_TYPE_KEYVALUE;
        params = [[NSMutableDictionary alloc] init];
    }

    return self;
}

+ (LeHttpRequest *)requestWithURL:(NSString *)url method:(HttpRequestMethod)method{
    LeHttpRequest *request = [[LeHttpRequest alloc] init];
    request.url = url;
    request.method = method;

    return request;
}


- (NSURLRequest *)makeURLRequest{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:10.0f];

    NSString *strParam = [[NSString alloc] init];

    NSString *method = nil;

    switch (self.method){
        case HTTP_POST:
            method = @"POST";
            break;
        case HTTP_PUT:
            method = @"PUT";
            break;
        case HTTP_DELETE:
            method = @"DELETE";
            break;
        case HTTP_GET:
            method = @"GET";
            break;
        default:
            method = @"GET";
            break;
    }
    [request setHTTPMethod:method];

    if (self.method == HTTP_GET) {

        if(params.count>0){

            for (id key in [params allKeys]) {

                strParam = [strParam stringByAppendingFormat:@"%@=%@", key, params[key]];
                if (key != [[params allKeys] lastObject]) {
                    strParam = [strParam stringByAppendingString:@"&"];
                }
            }
            self.url = [self.url stringByAppendingFormat:@"?%@",strParam];
        }
        if (_body)
            [request setHTTPBody:[_body dataUsingEncoding:NSUTF8StringEncoding]];

        // [request setURL:[NSURL URLWithString:self.url]];
    }else{

        if (_bodyType == HTTP_BODY_TYPE_KEYVALUE){
            //  strParam = [strParam stringByAppendingString:@"{"];
            for (id key in [params allKeys]) {
                strParam = [strParam stringByAppendingFormat:@"%@=%@", key, params[key]];
                if (key != [[params allKeys] lastObject]) {
                    strParam = [strParam stringByAppendingString:@"&"];
                }
            }
            //  strParam = [strParam stringByAppendingString:@"}"];

            [request setHTTPBody:[strParam dataUsingEncoding:NSUTF8StringEncoding]];

        }else{
            strParam = [strParam stringByAppendingString:@"{"];
            for (id key in [params allKeys]) {
                if ([params[key] isKindOfClass:[NSString class]]) {
                    strParam = [strParam stringByAppendingFormat:@"\"%@\":\"%@\"", key, params[key]];
                }else{
                    strParam = [strParam stringByAppendingFormat:@"\"%@\":%@", key, params[key]];
                }
                if (key != [[params allKeys] lastObject]) {
                    strParam = [strParam stringByAppendingString:@","];
                }
            }
            strParam = [strParam stringByAppendingString:@"}"];
            [request setHTTPBody:[strParam dataUsingEncoding:NSUTF8StringEncoding]];

        //    [request setHTTPBody:[[strParam JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];

        }


        [request setHTTPMethod:method];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)strParam.length] forHTTPHeaderField:@"Context-Length"];

    }

   // self.url = [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:[self.url URLEncodedString]]];

    for (id key in _header){
        [request setValue:_header[key] forHTTPHeaderField:key];
    }
    return request;
}



- (void)addParameter:(id)value forKey:(id)key{
    [params setValue:value forKey:key];
}

#define SR_POST_BOUNDARY @"------WebKitFormBoundaryuwYcfA2AIgxqIxA0"

- (void)postData:(NSData *)data  complete:(void (^)(BOOL))block
{
    NSMutableData *postData = [NSMutableData new];
    [postData appendData: [SR_POST_BOUNDARY dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:data];
    [postData appendData: [SR_POST_BOUNDARY dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:10.0f];
//    [data base64Encoding];
    
    [request setURL:[NSURL URLWithString:self.url]];
    
    [request setHTTPMethod:@"POST"];


    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;boundary=%@",SR_POST_BOUNDARY];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    //   NSLog(@"URL:%@", self.url);
    //   NSLog(@"%@ -> Params:%@",self, strParam);
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError){
            NSLog(@"%@", connectionError.localizedDescription);
            return;
        }
        
        if (block){
            block(connectionError == nil);
        }
    }];
}

#pragma mark --
#pragma mark -- 启动Request

- (void)cancel{
    [_connection cancel];
}

- (NSData *)StartSyncRequest:(NSError **)error{
    return [NSURLConnection sendSynchronousRequest:[self makeURLRequest] returningResponse:nil error:error];
}

#ifdef SYNC_HTTP
- (void)startAsyncRequest{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        NSError *error;
        NSData *data = [self StartSyncRequest:&error];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        if (data) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestFinished:request:)]) {
                [self.delegate requestFinished:[data copy] request:self];
            }else{
                if (self.block) {
                    self.block([HttpResultObjc objectWith:HTTP_REQUEST_SUCCESS reason:@"请求成功" objc:data]);
                }
            }
        }else{
            if (++self.timesOfRetry < self.maxTimesOfRetry) {
                [self startAsyncRequest];
                return;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestFail:request:)]) {
                [self.delegate requestFail:[error copy] request:self];
            }else{
                if (self.block) {
                    self.block([HttpResultObjc objectWith:HTTP_REQUEST_FAILED reason:error.localizedDescription objc:nil]);
                }
            }
        }
    });

}
#else
- (void)startAsyncRequest {
    _connection = [NSURLConnection connectionWithRequest:[self makeURLRequest] delegate:self];
  //  [_connection start];
}



#pragma mark --
#pragma mark -- NSConnection Delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [connection cancel];

    if (++self.timesOfRetry < self.maxTimesOfRetry) {
        [self startAsyncRequest];
        return;
    }

    if (self.block) {
        self.block([HttpResultObjc objectWith:HTTP_REQUEST_FAILED reason:error.localizedDescription objc:nil]);
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestFail:request:)]) {
            [self.delegate requestFail:error request:self];
        }
    }

}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _responseData = [[NSMutableData alloc] init];
    _expectLength = response.expectedContentLength;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{

    if (_responseData) {
        if (self.block) {
            self.block([HttpResultObjc objectWith:HTTP_REQUEST_SUCCESS reason:@"请求成功" objc:_responseData]);
        }else{
            if ([self.delegate respondsToSelector:@selector(requestFinished:request:)]) {
                [self.delegate requestFinished:[_responseData copy] request:self];
            }
        }
    }
}
- (void)connection:(__unused NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_responseData appendData:data];

    if ([_delegate respondsToSelector:@selector(request:received:)]){
        [_delegate request:self received:(_responseData.length/(1.f*_expectLength))];
    }
}

#endif

@end

