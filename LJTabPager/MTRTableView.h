//
//  MTRTableView.h
//  LJTabPager
//
//  Created by 李剑 on 2017/9/10.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTRRecycleProtocols.h"

@interface MTRTableView : UITableView
@property (nonatomic, weak) id<MTRTableViewRecycleDelegate> mtrRecycleDelegate;
@property (nonatomic, weak) id<MTRTableViewRecycleDataSource> mtrRecycleDataSource;
@property (nonatomic, readonly) BOOL mtrCallingLayoutSubviews;
@end
