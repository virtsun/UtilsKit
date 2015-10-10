//
//  SimilarTopBar.h
//  Emitter
//
//  Created by sunlantao on 15/7/16.
//  Copyright (c) 2015年 sunlantao. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
* use for set ’attributes‘
*for example:
*   [SimilarTopBar appearance].attributes = @{
*       kSimilarBackgroundColor : UIColorFromRGB(kColorTitleBar),
*       kSimilarTittleColor : UIColorFromRGB(0xffffff),
*       kSimilarTittleFont : NSHFont_Regular(kFontMiddle)
*        };
*/
#define kSimilarTittleColor     @"kSimilarTittleColor"
#define kSimilarTittleFont      @"kSimilarTittleFont"
#define kSimilarBackgroundColor @"kSimilarBackgroundColor"

@interface SimilarTopBar : UIView

@property(nonatomic, copy) NSString *title;

@property(nonatomic, strong) NSArray *leftItems;
@property(nonatomic, strong) NSArray *rightItems;

@property(nonatomic) UIEdgeInsets insets; //default is {22, 16, 0, 16}
@property(nonatomic) CGFloat itemMargin;  //default is 10

@property(nonatomic, strong) NSDictionary *attributes;

+ (instancetype) topBar;

@end
