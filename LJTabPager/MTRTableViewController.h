//
//  MTRTableViewController.h
//  LJTabPager
//
//  Created by 李剑 on 2017/9/8.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTRTableView.h"

@interface MTRTableViewController : UIViewController
@property (nonatomic, weak) id<MTRTabPagerReuseDelegate> reuseDelegate;
@end
