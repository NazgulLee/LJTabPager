//
//  LJPagerTabBar.h
//  LJTabPager
//
//  Created by 李剑 on 17/2/22.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCROLL_ORIENTATION) {
    SCROLL_ORIENTATION_RIGHT,
    SCROLL_ORIENTATION_LEFT,
    SCROLL_ORIENTATION_NONE
};

@protocol LJPagerTabBarDelegate <NSObject>

@required
- (void)showViewAtIndex:(NSInteger)index;
- (NSInteger)pagerVCInitialSelectedIndex;
@end

@interface LJPagerTabBar : UIScrollView

@property (nonatomic) NSArray *titles;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) UIColor *selectedLineColor;
@property (nonatomic) UIColor *selectedTabItemColor;
@property (nonatomic) UIColor *unSelectedColor;
@property (nonatomic) CGFloat pagerContentOffsetX;
@property (nonatomic) SCROLL_ORIENTATION scrollOrientation;

@property (nonatomic, weak) id<LJPagerTabBarDelegate> pagerTabBarDelegate;

- (instancetype)initWithTitles:(NSArray *)titles frame: (CGRect)frame;
/// 下面的scrollView刚开始滑动时，记录tabBar的contentOffset作为初始值，当前选中的tabItem后面第二个tabItem加spacing／2的位置减去屏幕宽度作为向右滑结束时tabBar至少要有的contentOffset值，当前选中的tabItem前面第二个tabItem减spacing/2的位置作为向左滑结束时tabBar至多有的contentOffset值，这样保证向右滑动结束时在选中的tabItem的右边还能看到其他tabItem，或者向左滑动结束时在在选中的tabItem的左边还能看到其他tabItem
- (void)recordInitialAndDestX;
/// 下面的scrollView停止滑动时，检查当前选中的tabItem是否在屏幕中，若不在，则把它拉回屏幕中
- (void)checkSelectedTabItemVisible;


@end
