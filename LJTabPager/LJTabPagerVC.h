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
- (void)hasBeenSelectedAndShown;

@end

@interface LJTabPagerVC : UIViewController

@property (nonatomic) NSArray *viewControllers;
@property (nonatomic) UIColor *tintColor;

@end
