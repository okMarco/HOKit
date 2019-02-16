//
//  ViewController.m
//  HOKit
//
//  Created by HoChan on 2019/2/5.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import "ViewController.h"
#import "HOBottomSheetV1.h"
#import "HOBottomSheetV2.h"
#import "DoubanViewController.h"
#import "InsVideoViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *samples;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _samples = @[@"豆瓣", @"ins-video"];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 80;
    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _samples.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    cell.textLabel.text = _samples[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *viewController;
    switch (indexPath.row) {
        case 0: {
            viewController = [[DoubanViewController alloc] init];
            break;
        }
        case 1: {
            viewController = [[InsVideoViewController alloc] init];
            break;
        }
        default:
            break;
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
