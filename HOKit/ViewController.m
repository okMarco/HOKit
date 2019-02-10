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

@interface ViewController ()
@property (nonatomic, strong) HOBottomSheetV1 *bottomSheetV1;
@property (nonatomic, strong) HOBottomSheetV2 *bottomSheetV2;
@property (nonatomic, strong) UIButton *bottomSheetButton;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self bottomSheetButton];
}

- (HOBottomSheetV1 *)bottomSheetV1 {
    if (!_bottomSheetV1) {
        _bottomSheetV1 = [[HOBottomSheetV1 alloc] init];
    }
    return _bottomSheetV1;
}

- (HOBottomSheetV2 *)bottomSheetV2 {
    if (!_bottomSheetV2) {
        _bottomSheetV2 = [[HOBottomSheetV2 alloc] init];
    }
    return _bottomSheetV2;
}

- (UIButton *)bottomSheetButton {
    if (!_bottomSheetButton) {
        _bottomSheetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomSheetButton.backgroundColor = [UIColor orangeColor];
        [_bottomSheetButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_bottomSheetButton setTitle:@"弹起" forState:UIControlStateNormal];
        _bottomSheetButton.frame = CGRectMake(0, 0, self.view.bounds.size.width / 2.0, 50);
        _bottomSheetButton.center = self.view.center;
        [_bottomSheetButton addTarget:self action:@selector(bottomSheetBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_bottomSheetButton];
    }
    return _bottomSheetButton;
}


- (void)bottomSheetBtnTapped {
    if (self.bottomSheetV2.hidden) {
        [self.bottomSheetV2 show];
    }
}

@end
