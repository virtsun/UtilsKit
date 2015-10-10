//
//  ActivityIndicator.m
//  com_wuyao_platform
//
//  Created by L.T.ZERO on 14-9-19.
//  Copyright (c) 2014年 51pk. All rights reserved.
//

#import "ActivityIndicator.h"
#import "CircleActivityIndicatorView.h"

#define SCREEN_WIDTH  MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define SCREEN_HEIGHT  MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)

@interface ActivityIndicator(){
    UIWindow *window;
    
    UIView  *background;

    CircleActivityIndicatorView  *loadingView;
    UILabel      *textLabel;

}

@property(nonatomic, copy) NSString *message;

+ (instancetype)shared;

@end

@implementation ActivityIndicator

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)shared{
    static ActivityIndicator *indicator = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        indicator = [[ActivityIndicator alloc] init];
    });
    
    return indicator;
}

- (id)init{
    
    if (self = [super init]){
        
        id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
        //---------------------------------------------------------------------------------------------------------------------------------------------
        if ([delegate respondsToSelector:@selector(window)])
            window = [delegate performSelector:@selector(window)];
        else window = [[UIApplication sharedApplication] keyWindow];
    }
    
    return self;
}

- (CGFloat)rotatedAngle{
    CGFloat rotate = 0.0f;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (orient == UIInterfaceOrientationPortrait)			rotate = 0.0;
    if (orient == UIInterfaceOrientationPortraitUpsideDown)	rotate = M_PI;
    if (orient == UIInterfaceOrientationLandscapeLeft)		rotate = - M_PI_2;
    if (orient == UIInterfaceOrientationLandscapeRight)		rotate = + M_PI_2;
    //---------------------------------------------------------------------------------------
    return rotate;
}

- (void)create{
    
    if (background == nil){
        background = [[UIView alloc] init];
        UIImage *image = [[UIImage screenshot] imageByApplyingTintEffectWithColor:[UIColor clearColor] radius:10];
        [background.layer setContents:(id)image.CGImage];
    }
    if (background.superview == nil){
        [window addSubview:background];
    }

    if (loadingView == nil) {
        loadingView = [[CircleActivityIndicatorView alloc] init];
        loadingView.frame = CGRectMake(0, 0, 20, 20);

        loadingView.numOfDots = 6;
        loadingView.radiusOfDots = 2;
        loadingView.duration = 1.f;
       // loadingView.supportRunAfter = YES;

        loadingView.colors = @[
                UIColorFromRGB(0xed1e20),
                UIColorFromRGB(0x6c24c6),
                UIColorFromRGB(0x1ab1eb),
                UIColorFromRGB(0x8ad127),
                UIColorFromRGB(0xffd800),
                UIColorFromRGB(0xff8a00)];

    }
    
    if (loadingView.superview == nil) {
        [background addSubview:loadingView];
    }

    [loadingView performSelector:@selector(startAnimating) withObject:nil afterDelay:.1f];

    if (_message != nil){
        if (textLabel == nil){
            textLabel = [[UILabel alloc] init];
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.numberOfLines = 3;
            textLabel.font = [UIFont systemFontOfSize:16];
            textLabel.text = _message;
            textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6f];
          //  textLabel.transform = CGAffineTransformMakeRotation([self rotatedAngle]);
        }
        
        if (textLabel.superview == nil){
            [background addSubview:textLabel];
        }

    }
}

- (void)resize{

    loadingView.frame = CGRectMake(0, 0, 20, 20);
    
    CGSize size = [_message constrained:CGSizeMake(240, 60) font:textLabel.font];

    textLabel.frame = CGRectMake(0, 0, size.width, size.height);
 
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            background.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
            loadingView.center = CGPointMake(SCREEN_HEIGHT/2, SCREEN_WIDTH/2 - size.height/2);
            textLabel.center = CGPointMake(loadingView.center.x, CGRectGetMaxY(loadingView.frame) + size.height + 10);

        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            background.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            loadingView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - size.height/2);
            textLabel.center = CGPointMake(SCREEN_WIDTH/2, CGRectGetMaxY(loadingView.frame) + size.height + 10);

        }
            break;
        default:
            break;
    }

}
+ (void)show{
    [[self class] show:nil];
}
+ (void)show:(NSString*)message{
    dispatch_async(dispatch_get_main_queue(), ^{

    [[self shared] setMessage:message];
    
    [[self shared] create];
   // [[self shared] hudOrient];
    [[self shared] resize];
    });

}

- (void)hide{
    if (textLabel.superview ) {
        [textLabel removeFromSuperview];
        textLabel = nil;
    }
    if (loadingView.superview) {
        [loadingView removeFromSuperview];
        loadingView = nil;
    }

    if (background.superview){
        [background removeFromSuperview];
        background = nil;
    }
}

+ (void)dismiss{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1*NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
        [[self shared] hide];
    });
}

@end
