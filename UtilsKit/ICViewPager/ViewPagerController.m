//
//  ViewPagerController.m
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import "ViewPagerController.h"

#define kDefaultTabHeight 74.0f // Default tab height
#define kDefaultTabOffset 56.0 // Offset of the second and further tabs' from left
#define kDefaultTabWidth 120.f
#define kDefaultTabMargin 20.f

#define kDefaultTabLocation 1.0 // 1.0: Top, 0.0: Bottom

#define kDefaultStartFromSecondTab 0.0 // 1.0: YES, 0.0: NO

#define kDefaultCenterCurrentTab 0.0 // 1.0: YES, 0.0: NO

#define kPageViewTag 34

#define kDefaultIndicatorColor [UIColor colorWithRed:16.0/255.0 green:133.0/255.0 blue:245.0/255.0 alpha:0.75]
#define kDefaultTabsViewBackgroundColor [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:0.75]
#define kDefaultContentViewBackgroundColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.f]

#define kDefaultIndicatorWidth 1.5f
// TabView for tabs, that provides un/selected state indicators
@class TabView;

@protocol TabViewDelegate<NSObject>

- (void)tabView:(TabView *)tabView didSelected:(BOOL)selected;
- (void)tabViewClicked:(TabView *)tabView;

@end

@interface TabView : UIView
@property (nonatomic) BOOL selected;

@property (copy) UIFont *font;
@property (copy) UIFont *highlightFont;

@property(nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) id<TabViewDelegate> delegate;
@end

@implementation TabView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        [self addSubview:_titleLabel];

    }
    return self;
}
- (void)setSelected:(BOOL)selected {
    _selected = selected;
    _titleLabel.highlighted = selected;

    _titleLabel.font = selected?_highlightFont:_font;

    if ([_delegate respondsToSelector:@selector(tabView:didSelected:)]){
        [_delegate tabView:self didSelected:selected];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if([_delegate respondsToSelector:@selector(tabViewClicked:)]){
        [_delegate tabViewClicked:self];
    }
}
@end


// ViewPagerController
@interface ViewPagerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, TabViewDelegate>

@property UIPageViewController *pageViewController;
@property (assign) id<UIScrollViewDelegate> origPageScrollViewDelegate;

@property(nonatomic, strong)  UIScrollView *tabsView;
@property(nonatomic, strong)  UIView *indicator;
@property(nonatomic, strong)  UIView *separator;
@property(nonatomic, strong)  UIView *contentView;

@property(nonatomic, strong)  NSMutableArray *tabs;
@property(nonatomic, strong)  NSMutableArray *contents;

@property NSUInteger tabCount;
@property (getter = isAnimatingToTab, assign) BOOL animatingToTab;


@end

@implementation ViewPagerController{
    BOOL isReloading;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultSettings];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self defaultSettings];
    }
    return self;
}

#pragma mark - View life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
       self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self layoutTabView];
    [self updateIndicatorLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (IBAction)handleTapGesture:(id)sender {
//
//    self.animatingToTab = YES;
//
//    curActiveIndex = self.activeTabIndex;
//
//    // Get the desired page's index
//    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)sender;
//    TabView *tabView = (TabView*)tapGestureRecognizer.view;
//    NSUInteger index = [_tabs indexOfObject:tabView];
//
//    [self scrollToIndex:index];
//
//}

- (void)scrollToIndex :(NSUInteger)index{

    if (index >= _tabs.count){
        return;
    }
    // Get the desired viewController
    UIViewController *viewController = [self viewControllerAtIndex:index];

    // __weak pageViewController to be used in blocks to prevent retaining strong reference to self
    __weak UIPageViewController *weakPageViewController = self.pageViewController;
    __weak ViewPagerController  *weakSelf = self;

    //  NSLog(@"%@",weakPageViewController.view);

    if (index < self.activeTabIndex) {

            [self.pageViewController setViewControllers:@[viewController]
                                              direction:UIPageViewControllerNavigationDirectionReverse
                                               animated:YES
                                             completion:^(BOOL completed) {
                                                 weakSelf.animatingToTab = NO;
                                                 
                                                 // Set the current page again to obtain synchronisation between tabs and content
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [weakPageViewController setViewControllers:@[viewController]
                                                                                      direction:UIPageViewControllerNavigationDirectionReverse
                                                                                       animated:NO
                                                                                     completion:nil];
                                                 });
                                             }];

        
        
      

        
         } else if (index > self.activeTabIndex) {
        [self.pageViewController setViewControllers:@[viewController]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:^(BOOL completed) {
                                             weakSelf.animatingToTab = NO;

                                             // Set the current page again to obtain synchronisation between tabs and content
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakPageViewController setViewControllers:@[viewController]
                                                                                  direction:UIPageViewControllerNavigationDirectionForward
                                                                                   animated:NO
                                                                                 completion:nil];
                                             });
                                         }];
    }

//    // Set activeTabIndex
//    TabView *tabView = _tabs[index];
//    tabView.from = _tabs[self.activeTabIndex];
    self.activeTabIndex = index;
}

#pragma mark - 
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // Re-align tabs if needed
    self.activeTabIndex = self.activeTabIndex;
}

#pragma mark - Setter/Getter

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    [self setActiveTabIndex:currentIndex];
    [_pageViewController setViewControllers:@[[self viewControllerAtIndex:currentIndex]]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];

}
- (void)setActiveTabIndex:(NSUInteger)activeTabIndex {

    if (activeTabIndex  >= [self.dataSource numberOfTabsForViewPager:self] )
        return;
    
    TabView *activeTabView;
    
    // Set to-be-inactive tab unselected
    activeTabView = [self tabViewAtIndex:self.activeTabIndex];
    activeTabView.selected = NO;
    
    // Set to-be-active tab selected
    activeTabView = [self tabViewAtIndex:activeTabIndex];
    activeTabView.selected = YES;
    
    // Set current activeTabIndex
    _activeTabIndex = activeTabIndex;
    
    // Inform delegate about the change
    if ([self.delegate respondsToSelector:@selector(viewPager:didChangeTabToIndex:)]) {
        [self.delegate viewPager:self didChangeTabToIndex:self.activeTabIndex];
    }
    
    // Bring tab to active position
    // Position the tab in center if centerCurrentTab option provided as YES
    
    UIView *tabView = [self tabViewAtIndex:self.activeTabIndex];
    CGRect frame = tabView.frame;
    
    if (self.centerCurrentTab) {
        
        frame.origin.x += (frame.size.width / 2);
        frame.origin.x -= _tabsView.frame.size.width / 2;
        frame.size.width = _tabsView.frame.size.width;
        
        if (frame.origin.x < 0) {
            frame.origin.x = 0;
        }
        
        if ((frame.origin.x + frame.size.width) > _tabsView.contentSize.width) {
            frame.origin.x = (_tabsView.contentSize.width - _tabsView.frame.size.width);
        }
    } else {
        
        frame.origin.x -= self.tabOffset;
        frame.size.width = self.tabsView.frame.size.width;
    }
    
    [_tabsView scrollRectToVisible:frame animated:YES];

}
#pragma mark -- tabViewDelegate

- (void)updateIndicatorLocation{
    TabView *tabView = [self tabViewAtIndex:self.activeTabIndex];
    _indicator.bounds = CGRectMake(0, 0, CGRectGetWidth(tabView.bounds), CGRectGetHeight(_indicator.frame));
    _indicator.center = CGPointMake(CGRectGetMidX(tabView.frame), _indicator.center.y);
}
- (void)tabView:(TabView *)tabView didSelected:(BOOL)selected {

    if(selected && !isReloading){
        if(isReloading){
            _indicator.bounds = CGRectMake(0, 0, CGRectGetWidth(tabView.bounds), CGRectGetHeight(_indicator.frame));
            _indicator.center = CGPointMake(CGRectGetMidX(tabView.frame), _indicator.center.y);

            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.fromValue = @0;
            animation.toValue = @1;
            animation.duration = .3f;
            animation.removedOnCompletion = YES;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [_indicator.layer addAnimation:animation forKey:animation.keyPath];

        }else{
            [UIView animateWithDuration:.2f animations:^{
                _indicator.bounds = CGRectMake(0, 0, CGRectGetWidth(tabView.bounds), CGRectGetHeight(_indicator.frame));
                _indicator.center = CGPointMake(CGRectGetMidX(tabView.frame), _indicator.center.y);
            } completion:^(BOOL isFinished){
                _indicator.center = CGPointMake(CGRectGetMidX(tabView.frame), _indicator.center.y);
            }];
        }

    }

}

- (void)tabViewClicked:(TabView *)tabView {
    self.animatingToTab = YES;

    curActiveIndex = self.activeTabIndex;
    NSUInteger index = [_tabs indexOfObject:tabView];

    [self scrollToIndex:index];
}

#pragma mark --
- (void)defaultSettings {
    
    // Default settings
    _tabHeight = kDefaultTabHeight;
    _tabOffset = kDefaultTabOffset;
    _tabWidth = kDefaultTabWidth;
    _tabMargin = kDefaultTabMargin;
    
    _tabLocation = kDefaultTabLocation;
    
    _startFromSecondTab = kDefaultStartFromSecondTab;
    
    _centerCurrentTab = kDefaultCenterCurrentTab;

    _tabTextColor = UIColorFromRGB(0x000000);
    _tabHighlightTextColor = UIColorFromRGB(0x00ff00);

    _tabFont = _tabHighlightFont = [UIFont systemFontOfSize:16];

    // Default colors
    _indicatorColor = kDefaultIndicatorColor;
    _tabsViewBackgroundColor = kDefaultTabsViewBackgroundColor;
    _contentViewBackgroundColor = kDefaultContentViewBackgroundColor;
    
    // pageViewController
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    
    //Setup some forwarding events to hijack the scrollview
    self.origPageScrollViewDelegate = ((UIScrollView*) _pageViewController.view.subviews[0]).delegate;
    [((UIScrollView*) _pageViewController.view.subviews[0]) setDelegate:self];
    
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    
    self.animatingToTab = NO;
}
-(CGFloat)tabWidth {
    CGFloat w = [self.dataSource viewPager:self valueForOption:ViewPagerOptionTabWidth withDefault:kDefaultTabWidth];
    return w?w: kDefaultTabWidth;
}

- (void)layoutTabView{
    _tabsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), _tabs.count>1?self.tabHeight:0);
    _separator.frame = CGRectMake(0, CGRectGetMinY(_tabsView.frame ) + CGRectGetHeight(_tabsView.frame) - 1, CGRectGetWidth(_tabsView.frame), 1);

    CGFloat contentSizeWidth = 0;
    for (int i = 0; i < _tabCount; i++) {

        UIView *tabView = [self tabViewAtIndex:i];

        CGRect frame = tabView.frame;
        frame.origin.x = contentSizeWidth;
        // frame.size.width = self.tabWidth;
        frame.size.height = _tabHeight - 1;
        tabView.frame = frame;

        [_tabsView insertSubview:tabView atIndex:0];

        contentSizeWidth += tabView.frame.size.width;
    }

    _tabsView.contentSize = CGSizeMake(contentSizeWidth, CGRectGetHeight(_tabsView.frame));

    if (contentSizeWidth < CGRectGetWidth(self.view.bounds) && _supportSpread){

        CGFloat spreadMargin = (CGRectGetWidth(_tabsView.bounds) - contentSizeWidth)/(_tabCount + 1);

        for (int i = 0; i < _tabCount; i++) {
            UIView *tabView = [self tabViewAtIndex:i];
            tabView.frame = CGRectOffset(tabView.frame, spreadMargin * (i+1), 0);
        }
        _tabsView.contentSize = CGSizeMake(CGRectGetWidth(_tabsView.bounds), CGRectGetHeight(_tabsView.bounds));
    }

    _contentView.frame = CGRectMake(0,
            CGRectGetHeight(_tabsView.frame),
            CGRectGetWidth(self.view.bounds),
            CGRectGetHeight(self.view.bounds) - CGRectGetHeight(_tabsView.frame));
}
- (void)reloadData {

    isReloading = YES;
    // Get settings if provided
    if ([self.dataSource respondsToSelector:@selector(viewPager:valueForOption:withDefault:)]) {
        _tabHeight = [self.dataSource viewPager:self valueForOption:ViewPagerOptionTabHeight withDefault:kDefaultTabHeight];
        _tabOffset = [self.dataSource viewPager:self valueForOption:ViewPagerOptionTabOffset withDefault:kDefaultTabOffset];
        _tabWidth = [self.dataSource viewPager:self valueForOption:ViewPagerOptionTabWidth withDefault:kDefaultTabWidth];
        
        _tabLocation = [self.dataSource viewPager:self valueForOption:ViewPagerOptionTabLocation withDefault:kDefaultTabLocation];
        
        _startFromSecondTab = [self.dataSource viewPager:self valueForOption:ViewPagerOptionStartIndex withDefault:kDefaultStartFromSecondTab];
        
        _centerCurrentTab = [self.dataSource viewPager:self valueForOption:ViewPagerOptionCenterCurrentTab withDefault:kDefaultCenterCurrentTab];
        _indicatorWidth = [self.dataSource viewPager:self valueForOption:ViewPagerOptionIndicatorWidth withDefault:3];
    }
    
    // Get colors if provided
    if ([self.dataSource respondsToSelector:@selector(viewPager:colorForComponent:withDefault:)]) {
        _indicatorColor = [self.dataSource viewPager:self colorForComponent:ViewPagerIndicator withDefault:self.indicatorColor];
        _tabTextColor = [self.dataSource viewPager:self colorForComponent:ViewPagerTabTextColor withDefault:_tabTextColor];
        _tabHighlightTextColor = [self.dataSource viewPager:self colorForComponent:ViewPagerTabHighlightTextColor withDefault:_tabHighlightTextColor];
        _tabHighlightFont = [self.dataSource viewPager:self colorForComponent:ViewPagerTabHighlightFont withDefault:_tabHighlightFont];
        _tabFont = [self.dataSource viewPager:self colorForComponent:ViewPagerTabFont withDefault:_tabFont];

        _tabsViewBackgroundColor = [self.dataSource viewPager:self colorForComponent:ViewPagerTabsView withDefault:kDefaultTabsViewBackgroundColor];
        _contentViewBackgroundColor = [self.dataSource viewPager:self colorForComponent:ViewPagerContent withDefault:kDefaultContentViewBackgroundColor];
    }
    
    // Empty tabs and contents
    [_tabs removeAllObjects];
    [_contents removeAllObjects];

    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    _tabCount = [self.dataSource numberOfTabsForViewPager:self];
    
    // Populate arrays with [NSNull null];
    _tabs = [NSMutableArray arrayWithCapacity:_tabCount];
    for (int i = 0; i < _tabCount; i++) {
        [_tabs addObject:[NSNull null]];
    }
    
    _contents = [NSMutableArray arrayWithCapacity:_tabCount];
    for (int i = 0; i < _tabCount; i++) {
        [_contents addObject:[NSNull null]];
    }
    
    // Add tabsView
    _tabsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, _tabs.count>1?self.tabHeight:0)];
    _tabsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tabsView.backgroundColor = self.tabsViewBackgroundColor;
    _tabsView.showsHorizontalScrollIndicator = NO;
    _tabsView.showsVerticalScrollIndicator = NO;

    [self.view insertSubview:_tabsView atIndex:0];

    _indicator = [[UIView alloc] init];
    _indicator.frame = CGRectMake(0, CGRectGetHeight(_tabsView.frame) - _indicatorWidth, 40, _indicatorWidth);
    _indicator.backgroundColor = self.indicatorColor;
    [_tabsView addSubview:_indicator];

    _separator = [[UIView alloc] init];
    _separator.frame = CGRectMake(0, CGRectGetMinY(_tabsView.frame ) + CGRectGetHeight(_tabsView.frame) - 1, CGRectGetWidth(_tabsView.frame), 1);
    _separator.backgroundColor = UIColorFromRGB(0xf2f2f2);
    [self.view insertSubview:_separator aboveSubview:_tabsView];
    
    // Add tab views to _tabsView
    [self layoutTabView];

    // Add contentView
    _contentView = [self.view viewWithTag:kPageViewTag];
    
    if (!_contentView) {
        _contentView = _pageViewController.view;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _contentView.backgroundColor = self.contentViewBackgroundColor;
        _contentView.bounds = self.view.bounds;
        
     
        _contentView.tag = kPageViewTag;
        
        [self.view insertSubview:_contentView atIndex:0];
    }
    
    // Set first viewController
    UIViewController *viewController;
    
    if (self.startFromSecondTab) {
        viewController = [self viewControllerAtIndex:1];
    } else {
        viewController = [self viewControllerAtIndex:0];
    }
    
    if (viewController == nil) {
        viewController = [[UIViewController alloc] init];
        viewController.view = [[UIView alloc] init];
    }
    
    [_pageViewController setViewControllers:@[viewController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    
    // Set activeTabIndex
    self.activeTabIndex = (NSUInteger)self.startFromSecondTab;

    isReloading = NO;
}

- (TabView *)tabViewAtIndex:(NSUInteger)index {
    
    if (index >= _tabCount || _tabs.count == 0) {
        return nil;
    }
    
    if ([_tabs[index] isEqual:[NSNull null]]) {

        // Get view from dataSource
        NSString *title = [self.dataSource viewPager:self viewForTabAtIndex:index];
        CGSize size = [title boundingRectWithSize:CGSizeMake(_tabWidth, _tabHeight)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:_tabFont}
                                               context:nil].size;

        // Create TabView and subview the content
        TabView *tabView = [[TabView alloc] initWithFrame:CGRectMake(0, 0, size.width + _tabMargin, self.tabHeight)];
        tabView.backgroundColor = _tabsViewBackgroundColor;
        tabView.titleLabel.text = title;
        tabView.font = tabView.titleLabel.font = _tabFont;
        tabView.highlightFont = _tabHighlightFont;
        tabView.titleLabel.textColor = _tabTextColor;
        tabView.titleLabel.highlightedTextColor = _tabHighlightTextColor;

        tabView.delegate = self;

        // Replace the null object with tabView
        _tabs[index] = tabView;
    }
    
    return _tabs[index];
}
- (NSUInteger)indexForTabView:(UIView *)tabView {
    
    return [_tabs indexOfObject:tabView];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    if (index >= _tabCount) {
        return nil;
    }
    
    if ([_contents[index] isEqual:[NSNull null]]) {
        
        UIViewController *viewController;
        
        if ([self.dataSource respondsToSelector:@selector(viewPager:contentViewControllerForTabAtIndex:)]) {
            viewController = [self.dataSource viewPager:self contentViewControllerForTabAtIndex:index];
        } else if ([self.dataSource respondsToSelector:@selector(viewPager:contentViewForTabAtIndex:)]) {
            
            UIView *view = [self.dataSource viewPager:self contentViewForTabAtIndex:index];
            
            // Adjust view's bounds to match the pageView's bounds
            UIView *pageView = [self.view viewWithTag:kPageViewTag];
            view.frame = pageView.bounds;
            
            viewController = [UIViewController new];
            viewController.view = view;
        } else {
            viewController = [[UIViewController alloc] init];
            viewController.view = [[UIView alloc] init];
        }
        
        _contents[index] = viewController;
    }
    
    return _contents[index];
}
- (NSUInteger)indexForViewController:(UIViewController *)viewController {
    
    return [_contents indexOfObject:viewController];
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexForViewController:viewController];
    index++;
    return [self viewControllerAtIndex:index];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexForViewController:viewController];
    index--;
    return [self viewControllerAtIndex:index];
}

#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
//    NSLog(@"willTransitionToViewController: %i", [self indexForViewController:[pendingViewControllers objectAtIndex:0]]);
}
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    UIViewController *viewController = self.pageViewController.viewControllers[0];
    self.activeTabIndex = [self indexForViewController:viewController];
}

#pragma mark - UIScrollViewDelegate, Responding to Scrolling and Dragging
static CGFloat offsetX;
NSUInteger curActiveIndex;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.origPageScrollViewDelegate scrollViewDidScroll:scrollView];
    }
    
    if (![self isAnimatingToTab]) {
        UIView *tabView = [self tabViewAtIndex:self.activeTabIndex];
        
        // Get the related tab view position
        CGRect frame = tabView.frame;
        
        CGFloat movedRatio = (scrollView.contentOffset.x / scrollView.frame.size.width) - 1;
        frame.origin.x += movedRatio * frame.size.width;
        
        if (self.centerCurrentTab) {
            
            frame.origin.x += (frame.size.width / 2);
            frame.origin.x -= _tabsView.frame.size.width / 2;
            frame.size.width = _tabsView.frame.size.width;
            
            if (frame.origin.x < 0) {
                frame.origin.x = 0;
            }
            
            if ((frame.origin.x + frame.size.width) > _tabsView.contentSize.width) {
                frame.origin.x = (_tabsView.contentSize.width - _tabsView.frame.size.width);
            }
        } else {
            
            frame.origin.x -= self.tabOffset;
            frame.size.width = self.tabsView.frame.size.width;
        }
        
        [_tabsView scrollRectToVisible:frame animated:NO];

        if (curActiveIndex == self.activeTabIndex)
        {
            CGFloat offset = scrollView.contentOffset.x - offsetX;

            CGFloat rate = offset/ CGRectGetWidth(self.view.bounds);
            NSInteger nextIndex = rate>0? MIN(self.activeTabIndex+1, self.tabCount-1): MAX(0, self.activeTabIndex-1);
            UIView *nextView = [self tabViewAtIndex:(NSUInteger) MAX(nextIndex, 0)];

            int reversed = 1;
            if (nextView == tabView){
                if (rate>0){
                    nextView = [self tabViewAtIndex:self.activeTabIndex - 1];
                }else{
                    nextView = [self tabViewAtIndex:1];
                }
                reversed = -1;
            }

            CGFloat x = (CGFloat) (reversed * (nextView.center.x - tabView.center.x)* fabs(rate));

            _indicator.center = CGPointMake(_indicator.center.x + x, _indicator.center.y);
            offsetX = scrollView.contentOffset.x;
        }

    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.origPageScrollViewDelegate scrollViewWillBeginDragging:scrollView];
    }

    offsetX = scrollView.contentOffset.x;
    curActiveIndex = self.activeTabIndex;
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.origPageScrollViewDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.origPageScrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }

}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.origPageScrollViewDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return NO;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.origPageScrollViewDelegate scrollViewDidScrollToTop:scrollView];
    }
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.origPageScrollViewDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.origPageScrollViewDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark - UIScrollViewDelegate, Managing Zooming
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.origPageScrollViewDelegate viewForZoomingInScrollView:scrollView];
    }
    
    return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.origPageScrollViewDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.origPageScrollViewDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.origPageScrollViewDelegate scrollViewDidZoom:scrollView];
    }
}

#pragma mark - UIScrollViewDelegate, Responding to Scrolling Animations
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.origPageScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.origPageScrollViewDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (void)setDataSource:(id<ViewPagerDataSource>)dataSource{
    _dataSource = dataSource;
    [self reloadData];
}
- (void)setDelegate:(id <ViewPagerDelegate>)delegate {
    _delegate = delegate;

}
@end
