//
//  ViewPagerController.h
//  ICViewPager
//
//  Created by Ilter Cengiz on 28/08/2013.
//  Copyright (c) 2013 Ilter Cengiz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ViewPagerOption) {
    ViewPagerOptionTabHeight,
    ViewPagerOptionTabOffset,
    ViewPagerOptionTabWidth,
    ViewPagerOptionIndicatorWidth,
    ViewPagerOptionTabLocation,
    ViewPagerOptionStartIndex,
    ViewPagerOptionCenterCurrentTab
};

typedef NS_ENUM(NSUInteger, ViewPagerComponent) {
    ViewPagerIndicator,
    ViewPagerTabTextColor,
    ViewPagerTabHighlightTextColor,
    ViewPagerTabFont,
    ViewPagerTabHighlightFont,
    ViewPagerTabsView,
    ViewPagerContent
};

@protocol ViewPagerDataSource;
@protocol ViewPagerDelegate;

@interface ViewPagerController : UIViewController

@property (nonatomic ,weak, setter=setDataSource:) id<ViewPagerDataSource> dataSource;
@property (nonatomic, weak, setter=setDelegate:) id<ViewPagerDelegate> delegate;

#pragma mark ViewPagerOptions
// Tab bar's height, defaults to 49.0
@property CGFloat tabHeight;
// Tab bar's offset from left, defaults to 56.0
@property CGFloat tabOffset;
// Tab margin, defaults to 10.0
@property CGFloat tabMargin;
// Any tab item's width, defaults to 128.0. To-do: make this dynamic
@property (nonatomic, assign, getter=tabWidth) CGFloat tabWidth;

// 1.0: Top, 0.0: Bottom, changes tab bar's location in the screen
// Defaults to Top
@property CGFloat tabLocation;

// 1.0: YES, 0.0: NO, defines if view should appear with the second or the first tab
// Defaults to NO
@property CGFloat startFromSecondTab;

// 1.0: YES, 0.0: NO, defines if tabs should be centered, with the given tabWidth
// Defaults to NO
@property CGFloat centerCurrentTab;

@property (nonatomic) NSUInteger activeTabIndex;

@property CGFloat indicatorWidth;

#pragma mark Colors
// Colors for several parts
@property(copy) UIColor *indicatorColor;
@property(copy) UIColor *tabTextColor;
@property(copy) UIColor *tabHighlightTextColor;
@property(copy) UIColor *tabsViewBackgroundColor;
@property(copy) UIColor *contentViewBackgroundColor;

@property(copy) UIFont *tabFont;
@property(copy) UIFont *tabHighlightFont;

@property BOOL supportSpread;   //数据较少无法填充满整行时有效

#pragma mark Methods
// Reload all tabs and contents
- (void)reloadData;

- (void)scrollToIndex :(NSUInteger)index;

@end

#pragma mark dataSource
@protocol ViewPagerDataSource <NSObject>

@optional
// Asks dataSource how many tabs will be
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager;
// Asks dataSource to give a view to display as a tab item
// It is suggested to return a view with a clearColor background
// So that un/selected states can be clearly seen
- (NSString*)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index;

@optional
// The content for any tab. Return a view controller and ViewPager will use its view to show as content
- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index;
- (UIView *)viewPager:(ViewPagerController *)viewPager contentViewForTabAtIndex:(NSUInteger)index;

- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value;
/*
 * Use this method to customize the look and feel.
 * viewPager will ask its delegate for colors for its components.
 * And if they are provided, it will use them, otherwise it will use default colors.
 * Also not that, colors for tab and content views will change the tabView's and contentView's background
 * (you should provide these views with a clearColor to see the colors),
 * and indicator will change its own color.
 */
- (id)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(id)color;

@end

#pragma mark delegate
@protocol ViewPagerDelegate <NSObject>

@optional
// delegate object must implement this method if wants to be informed when a tab changes
- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index;
// Every time - reloadData called, ViewPager will ask its delegate for option values
// So you don't have to set options from ViewPager itself

@end
