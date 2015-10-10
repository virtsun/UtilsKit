//
//  UIImage+ThumbnailImage.h
//  lib51PK_IOS
//
//  Created by L.T.ZERO on 14-4-2.
//  Copyright (c) 2014年 iava. All rights reserved.
//

#import <uikit/UIKit.h>

/*略缩图*/
@interface UIImage(ThumbnailImage)

/*不保持原高宽比*/
- (UIImage *)thumbnailWithSize:(CGSize)size;

/*保持原高宽比*/
- (UIImage *)thumbnailWithImageWithoutScale:(CGSize)size;


- (void)writeToFile:(NSString *)path atomically:(BOOL)atomically;

@end
