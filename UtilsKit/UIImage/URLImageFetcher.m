//
//  URLImageFetcher.m
//  URLImageFetcher
//
//  Created by  maple on 6/27/13.
//  Copyright (c) 2013 maple. All rights reserved.
//

#import "URLImageFetcher.h"
#import <ImageIO/ImageIO.h>

@interface URLImageFetcher () {
    NSURLRequest    *_request;
    NSURLConnection *_conn;
    
    CGImageSourceRef _incrementallyImgSource;
    
    NSMutableData   *_receivedData;
    long long       _expectedLength;
    bool            _isLoadFinished;
    UIImage         *_image;
    NSString        *_path;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *thumbImage;

@end

@implementation URLImageFetcher

@synthesize imageURL = _imageURL;
@synthesize image    = _image;
@synthesize thumbImage = _thumbImage;

@synthesize path = _path;

- (id)initWithURL:(NSString*)imageURL httpImage:(BOOL)isHttpImage{
    if (self = [super init]) {
        
        if (isHttpImage){
#ifdef __URLImageAutoSaveSupported__
            
            _path = [URLImageFetcher translateHttpURLToPath:imageURL];
            
            //    NSLog(@"%@", _path);
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:_path]){
                _image = [UIImage imageWithContentsOfFile:_path];
                if (_imageView)
                    _imageView.image = _image;
                _isLoadFinished = YES;
            }else{
#endif
                _incrementallyImgSource = CGImageSourceCreateIncremental(NULL);
                _receivedData = [[NSMutableData alloc] init];
                _isLoadFinished = NO;
                _checkMimeType = YES;
                
                _imageURL = [NSURL URLWithString:imageURL];
                _request = [[NSURLRequest alloc] initWithURL:_imageURL];
                _conn    = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
                
#ifdef __URLImageAutoSaveSupported__
            }
#endif
        } else {
            _image = [UIImage imageWithContentsOfFile:imageURL];
            _isLoadFinished = YES;
        }

    }
    
    return self;
}

- (id)initWithURL:(NSString *)imageURL{
    
    return [self initWithURL:imageURL httpImage:[imageURL isHttpURL]];
}

+ (NSString *)translateHttpURLToPath:(NSString *)imageURL{
    NSString *name = [imageURL MD5String];
    NSString *extension = imageURL.pathExtension?imageURL.pathExtension:@"unkown";

    return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", name, extension]];
}
- (void)setBlock:(void (^)())block {
    _block = [block copy];

    if (_isLoadFinished && _block){
        _block();
    }
}

- (void)setImageView:(UIImageView *)imageView {
    _imageView = imageView;

    if (_block) _block();

    if (_isLoadFinished){

        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = _image;
        });

    }
}

- (void)dealloc
{
    _request = nil;
    _conn = nil;
    _receivedData = nil;
    _image = nil;
    _thumbImage = nil;

    if (_incrementallyImgSource)
        CFRelease(_incrementallyImgSource);

}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _expectedLength = response.expectedContentLength;
  //  NSLog(@"expected Length: %lld", _expectedLeght);

    if (_checkMimeType){
        NSString *mimeType = response.MIMEType;
        //  NSLog(@"MIME TYPE %@", mimeType);

        NSArray *arr = [mimeType componentsSeparatedByString:@"/"];
        if (arr.count < 1 || ![[arr firstObject] isEqual:@"image"]) {
            NSLog(@"not a image url");
            [connection cancel];
            _conn = nil;
        }
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection %@ error, error info: %@", connection, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
 //   NSLog(@"Connection Loading Finished!!!");
    
    // if download image data not complete, create final image
    if (!_isLoadFinished) {
        CGImageSourceUpdateData(_incrementallyImgSource, (__bridge CFDataRef) _receivedData, _isLoadFinished);
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_incrementallyImgSource, 0, NULL);
        self.image = [UIImage imageWithCGImage:imageRef];

        CGImageRelease(imageRef);
    }else{
#ifdef __URLImageAutoSaveSupported__
         [self.image writeToFile:_path atomically:YES];
#endif

        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = self.image;
        });
    }

    if (self.block){
        _block();
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
    
    _isLoadFinished = false;
    if (_expectedLength == _receivedData.length) {
        _isLoadFinished = true;
    }
    
    CGImageSourceUpdateData(_incrementallyImgSource, (__bridge CFDataRef) _receivedData, _isLoadFinished);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_incrementallyImgSource, 0, NULL);
    self.image = [UIImage imageWithCGImage:imageRef];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = self.image;
    });

    CGImageRelease(imageRef);
}

@end
