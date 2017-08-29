//
//  LJTabPagerVC.h
//  LJTabPager
//
//  Created by 李剑 on 17/2/22.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LJTabPagerVCDelegate <NSObject>

@optional
- (void)hasBeenSelectedAndShown:(NSNumber *)firstShown;

@end

@protocol LJTabPagerVCsSource <NSObject>

- (NSInteger)numberOfViewControllers;
- (NSArray *)titles;
- (UIViewController *)viewControllerAtIndex:(NSInteger)index;

@end

@interface LJTabPagerVC : UIViewController

@property (nonatomic) UIColor *selectedLineColor;
@property (nonatomic) UIColor *selectedTabItemColor;
@property (nonatomic) UIColor *tabBarBKColor;
@property (nonatomic, readonly) NSInteger selectedIndex;

@property (nonatomic, weak) id<LJTabPagerVCsSource> vcsSource;

+ (CGFloat)pagerTabBarHeight;
/// 重新加载视图控制器。若exceptSelected为NO，此方法会把所有已加载的视图控制器移除，重新加载且只加载当前显示的视图控制器；若exceptSelected为YES，则把除当前选中以外的视图控制器移除。改变vcsSource数据源或者应用占用内存过大时收到memory warning时，可调用此方法。
- (void)reloadVCsExceptSelected:(BOOL)exceptSelected;

@end
