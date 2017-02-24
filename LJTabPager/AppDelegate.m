//
//  AppDelegate.m
//  LJTabPager
//
//  Created by 李剑 on 17/2/22.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import "AppDelegate.h"
#import "LJTabPagerVC.h"
#import "TableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch. 
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    LJTabPagerVC *pagerVC = [[LJTabPagerVC alloc] init];
    TableViewController *controller1 = [[TableViewController alloc] init];
    controller1.title = @"个性推荐";
    TableViewController *controller2 = [[TableViewController alloc] init];
    controller2.title = @"歌单";
    TableViewController *controller3 = [[TableViewController alloc] init];
    controller3.title = @"主播电台";
    TableViewController *controller4 = [[TableViewController alloc] init];
    controller4.title = @"排行榜";
    TableViewController *controller5 = [[TableViewController alloc] init];
    controller5.title = @"用户";
    TableViewController *controller6 = [[TableViewController alloc] init];
    controller6.title = @"歌手";
    TableViewController *controller7 = [[TableViewController alloc] init];
    controller7.title = @"专辑";
    TableViewController *controller8 = [[TableViewController alloc] init];
    controller8.title = @"单曲";
    pagerVC.viewControllers = @[controller1, controller2, controller3, controller4, controller5, controller6, controller7, controller8];
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:pagerVC];
    rootVC.edgesForExtendedLayout = UIRectEdgeNone;
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
