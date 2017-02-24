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
//在viewController切换点记录tabBar的contentOffset及当前选中tabItem后面第二个tabItem加spacing／2的位置
- (void)recordInitialAndDestX;

- (void)checkSelectedTabItemVisible;


@end
