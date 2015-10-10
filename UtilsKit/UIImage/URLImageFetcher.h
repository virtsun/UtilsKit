//
//  URLImageFetcher.h
//  URLImageFetcher
//
//  Created by  maple on 6/27/13.
//  Copyright (c) 2013 maple. All rights reserved.
//

#import <UIKit/UIKit.h>

#define  __URLImageAutoSaveSupported__

@interface URLImageFetcher : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) NSString *path;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, assign) BOOL checkMimeType;
@property (nonatomic, copy) void (^block)();

- (id)initWithURL:(NSString*)imageURL;
- (id)initWithURL:(NSString*)imageURL httpImage:(BOOL)isHttpImage;

+ (NSString *)translateHttpURLToPath:(NSString *)URL;

@end
