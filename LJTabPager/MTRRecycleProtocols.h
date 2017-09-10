//
//  MTRRecycleProtocols.h
//  LJTabPager
//
//  Created by 李剑 on 2017/9/10.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#ifndef MTRRecycleProtocols_h
#define MTRRecycleProtocols_h

#import <UIKit/UIKit.h>

@class MTRTableView;
@protocol MTRTableViewRecycleDelegate <NSObject>

- (void)mtrRecycleReusabelCells:(NSArray *_Nullable)cells;

@end

@protocol MTRTableViewRecycleDataSource <NSObject>

- (nullable UITableViewCell *)mtrDequeReusableCellForTableView:(nonnull MTRTableView *)tableView withReuseIdentifier:(nonnull NSString *)identifier;

- (void)mtrRegisterClass:(nullable Class)cellClass forCellReuseIdentifier:(nonnull NSString *)identifier;
@end

@protocol MTRViewControllerRecycleProtocol <NSObject>

- (nullable NSArray *)mtrParticipatingContainerViews;

@end

#endif /* MTRRecycleProtocols_h */
