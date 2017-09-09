//
//  MTRTabPagerViewController.h
//  MTRTabPager
//
//  Created by 李剑 on 17/2/22.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTRTabPagerViewController.h"
#import "MTRTableView.h"

@protocol MTRTabPagerVCDelegate <NSObject>

@optional
- (void)hasBeenSelectedAndShown:(NSNumber *)firstShown;

@end

@protocol MTRTabPagerVCsSource <NSObject>

- (NSInteger)numberOfViewControllers;
- (NSArray *)titles;
- (UIViewController *)viewControllerAtIndex:(NSInteger)index;

@end

@interface MTRTabPagerViewController : UIViewController <MTRTabPagerReuseDelegate>

@property (nonatomic) UIColor *selectedLineColor;
@property (nonatomic) UIColor *selectedTabItemColor;
@property (nonatomic) UIColor *tabBarBKColor;
@property (nonatomic, readonly) NSInteger selectedIndex;

@property (nonatomic, weak) id<MTRTabPagerVCsSource> vcsSource;

+ (CGFloat)pagerTabBarHeight;
+ (instancetype)sharedInstance;
/// 重新加载视图控制器。若exceptSelected为NO，此方法会把所有已加载的视图控制器移除，重新加载且只加载当前显示的视图控制器；若exceptSelected为YES，则把除当前选中以外的视图控制器移除。改变vcsSource数据源或者应用占用内存过大时收到memory warning时，可调用此方法。
- (void)reloadVCsExceptSelected:(BOOL)exceptSelected;

/// 若复用池中有可用cell，则取出返回，若无，创建一个返回
- (UITableViewCell *)mtrDequeReusableCellForTableView:(MTRTableView *)tableView WithIdentifier:(NSString *)identifier;
/// 提前为要复用的cell类注册，cellClass为nil表示解除注册，相同的reuseIdentifier后注册的会覆盖先注册的
- (void)mtrRegisterClass:(nonnull Class)cellClass forCellReuseIdentifier:(nonnull NSString *)identifier;
@end


