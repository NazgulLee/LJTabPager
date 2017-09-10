//
//  UITableViewCell+MTRRecycle.h
//  LJTabPager
//
//  Created by 李剑 on 2017/9/10.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTRTableView.h"

@interface UITableViewCell (MTRRecycle)
@property (nonatomic, weak) MTRTableView *mtrTableView;
@property (nonatomic, copy) NSString *mtrReuseIdentifier;
@end
