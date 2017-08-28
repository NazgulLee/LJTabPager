//
//  VcsSource.m
//  LJTabPager
//
//  Created by 李剑 on 2017/8/23.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import "VcsSource.h"
#import "TableViewController.h"

@implementation VcsSource
- (NSInteger)numberOfViewControllers {
    return 8;
}

- (NSArray *)titles {
    //@[@"个性推荐", @"歌单", @"主播电台", @"排行榜", @"用户", @"歌手", @"专辑", @"单曲"];
    NSArray *array = @[@"个性推荐", @"歌单", @"主播电台", @"排行榜", @"用户", @"歌手", @"专辑", @"单曲"];
    return array;
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    TableViewController *controller = [[TableViewController alloc] init];
    switch (index) {
        case 0:
            controller.title = @"个性推荐";
            break;
        case 1:
            controller.title = @"歌单";
            break;
        case 2:
            controller.title = @"主播电台";
            break;
        case 3:
            controller.title = @"排行榜";
            break;
        case 4:
            controller.title = @"用户";
            break;
        case 5:
            controller.title = @"歌手";
            break;
        case 6:
            controller.title = @"专辑";
            break;
        case 7:
            controller.title = @"单曲";
            break;
        default:
            break;
    }
    return controller;
}


@end
