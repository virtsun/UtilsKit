//
//  Sharer.m
//  CFShareCircle
//
//  Created by Camden on 1/15/13.
//  Copyright (c) 2013 Camden. All rights reserved.
//

#import "CFSharer.h"

@implementation CFSharer

@synthesize name = _name;
@synthesize image = _image;

- (id)initWithName:(NSString *)name imageName:(NSString *)imageName {
    self = [super init];
    if (self) {
        _name = name;
        _image = [UIImage imageNamed:imageName];
    }
    return self;    
}
+ (id)sharerWithName:(NSString *)name imageName:(NSString *)imageName{
    return [[CFSharer alloc] initWithName:name imageName:imageName];
}
+ (CFSharer *)mail {
    return [[CFSharer alloc] initWithName:@"mail" imageName:@"images.bundle/mail.png"];
}

+ (CFSharer *)photoLibrary {
    return [[CFSharer alloc] initWithName:@"photo" imageName:@"images.bundle/photo_library.png"];
}

+ (CFSharer *)dropbox {
    return [[CFSharer alloc] initWithName:@"dropbox" imageName:@"images.bundle/dropbox.png"];
}

+ (CFSharer *)evernote {
    return [[CFSharer alloc] initWithName:@"evernote" imageName:@"images.bundle/evernote.png"];
}

+ (CFSharer *)facebook {
    return [[CFSharer alloc] initWithName:@"facebook" imageName:@"images.bundle/facebook.png"];
}

+ (CFSharer *)googleDrive {
    return [[CFSharer alloc] initWithName:@"googleDrive" imageName:@"images.bundle/google_drive.png"];
}

+ (CFSharer *)pinterest {
    return [[CFSharer alloc] initWithName:@"pinterest" imageName:@"images.bundle/pinterest.png"];
}

+ (CFSharer *)twitter {
    return [[CFSharer alloc] initWithName:@"twitter" imageName:@"images.bundle/twitter.png"];
}

@end
