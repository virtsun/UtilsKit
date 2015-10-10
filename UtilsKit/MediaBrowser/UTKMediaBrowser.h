//
// Created by l.t.zero on 15/8/27.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UTKMediaBrowser;

typedef NS_ENUM(NSUInteger , UTKMediaType){
    kUTKMediaTypePic = 0x01<<1,
    kUTKMediaTypeMov = 0x01<<2,
    kUTKMediaTypeTimelapse = 0x01<<3
};

@interface UTKMediaItemObject : NSObject<NSCopying>

@property (copy) NSString *title;
@property UTKMediaType type;
@property (copy) NSString *url;

+ (instancetype)objectWithTitle:(NSString *)title type:(UTKMediaType)type url:(NSString *)url;

@end

//UTKMediaItemView
@interface UTKMediaItemView : UIView

@property (nonatomic, strong) UTKMediaItemObject *itemObject;
@property (nonatomic) BOOL highlighted;
@property (nonatomic) BOOL editable;

- (id)initWithItem:(UTKMediaItemObject *)object;

- (BOOL)tapGesture:(NSUInteger)tapCount;
- (BOOL)pinchGesture:(CGFloat)scale state:(UIGestureRecognizerState)state;
- (CGPoint)panGesture:(CGPoint)offset state:(UIGestureRecognizerState)sta;


@end

@interface UTKMediaPicItemView : UTKMediaItemView

@end

//browser部分
@protocol UTKMediaBrowserDataSource<NSObject>

- (NSUInteger)numberItemOfMediaBrowser;
- (UIView *)browser: (UTKMediaBrowser *)browser itemViewAtIndex:(NSUInteger)index;

@end

@interface UTKMediaBrowser : UIView

@property (nonatomic, weak) id<UTKMediaBrowserDataSource> dataSource;
@property (nonatomic, readonly) NSUInteger numberItemOfBrowser;
@property (nonatomic) NSUInteger currentItem;
@property (nonatomic, weak) UTKMediaItemView *currentItemView;

- (void)reload;

@end