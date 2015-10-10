

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *kCircleActivityAnimationActive;


@interface CircleActivityIndicatorView : UIView

@property (nonatomic, copy) NSArray *colors;

@property(nonatomic) NSUInteger numOfDots;
@property(nonatomic) CGFloat radiusOfDots;

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) BOOL supportRunAfter;

@property (nonatomic) CGFloat progress;

@property (nonatomic) BOOL locked;

-(id)initWithFrame:(CGRect)frame;

-(void)startAnimating;
-(void)stopAnimating;

- (void)stopRotate;
- (void)startRotate;

@end
