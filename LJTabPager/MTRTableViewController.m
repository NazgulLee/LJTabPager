//
//  MTRTableViewController.m
//  LJTabPager
//
//  Created by 李剑 on 2017/9/8.
//  Copyright © 2017年 mutouren. All rights reserved.
//

#import "MTRTableViewController.h"
#import "MTRTabPagerViewController.h"
#import "MTRProtocols.h"

@interface MTRTableViewController () <UITableViewDelegate, UITableViewDataSource, MTRRecycleControllerProtocol>
@property (nonatomic) MTRTableView *tableView;
@end

@implementation MTRTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.frame;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[MTRTabPagerViewController sharedInstance] mtrDequeReusableCellForTableView:tableView WithIdentifier:@"cell"];
    //cell.textLabel.text = self.title;
    return cell;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (MTRTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MTRTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)setReuseDelegate:(id<MTRTabPagerReuseDelegate>)reuseDelegate {
    _reuseDelegate = reuseDelegate;
    self.tableView.reuseDelegate = reuseDelegate;
}

#pragma mark - MTRRecycleProtocol
- (NSArray *)mtrParticipateRecycleViews {
    return @[self.tableView];
}

@end
