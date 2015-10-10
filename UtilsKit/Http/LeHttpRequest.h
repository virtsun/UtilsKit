//
//  HttpRequest.h
//
//  Created by L.T.ZERO on 14-3-5.
//  Copyright (c) 2014年 sunlantao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYNC_HTT

typedef NS_ENUM(NSInteger, HttpRequestMethod) {
    HTTP_GET = 0,
    HTTP_POST,
    HTTP_PUT,
    HTTP_DELETE
} ;

typedef NS_ENUM(NSInteger, HttpRequestBodyType){
    HTTP_BODY_TYPE_JSON,
    HTTP_BODY_TYPE_KEYVALUE
} ;

typedef NS_ENUM(NSInteger, HttpResult){
    HTTP_REQUEST_SUCCESS = 0,
    HTTP_REQUEST_FAILED,
    HTTP_REQUEST_ERR
};

@interface HttpResultObjc : NSObject

@property (assign) int code;
@property (copy)   NSString *reason;

@property (copy)   id object;

+ (id)objectWith:(int)code reason:(NSString *)reason objc:(id)objc;

@end

typedef void (^request_complete_block)(HttpResultObjc *);

@class LeHttpRequest;
@protocol HttpRequestDelegate <NSObject>

- (void)requestFinished:(NSData*)data request:(LeHttpRequest*)request;
- (void)requestFail:(NSError *)error request:(LeHttpRequest*)request;

@optional
- (void)request:(LeHttpRequest *)request received:(float)progress;

@end

@interface LeHttpRequest : NSObject{
    NSMutableDictionary *params;
}

@property(nonatomic, weak) id<HttpRequestDelegate> delegate;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, assign) HttpRequestMethod method;
@property(nonatomic, assign) int type;
//@property(nonatomic, strong) id  objc;
@property(nonatomic, assign) int timesOfRetry;
@property(nonatomic, assign) int maxTimesOfRetry;
@property(nonatomic, assign) HttpRequestBodyType bodyType;
@property(nonatomic, copy)   request_complete_block block;
@property(nonatomic, strong) NSDictionary *header;
@property(nonatomic, strong) NSMutableDictionary *params;

@property (nonatomic, copy) NSString *body;

+ (LeHttpRequest *)requestWithURL:(NSString *)url method:(HttpRequestMethod)method;
- (void)addParameter:(id)value forKey:(id)key;

- (NSURLRequest *)makeURLRequest;

- (void)postData:(NSData *)data  complete:(void (^)(BOOL))block;

- (void)startAsyncRequest;
- (NSData *)StartSyncRequest:(NSError **)error;
- (void)cancel;
@end