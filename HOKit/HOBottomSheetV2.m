//
//  HOBottomSheet.m
//  HOKit
//
//  Created by HoChan on 2019/2/5.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import "HOBottomSheetV2.h"
#import <pop/POP.h>
#import "UIScrollView+EnableSimultaneously.h"

@interface HOBottomSheetV2()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat translationY;
@property (nonatomic, assign) CGFloat startTranslationY;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, strong) NSArray *data;

@property (nonatomic, assign) BOOL top;


@end

@implementation HOBottomSheetV2

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _data = @[@"The NSObject class lies at the root of (almost) all classes we build and use as part of Cocoa programming. What does it actually do, though, and how does it do it? Today, I'm going to rebuild NSObject from scratch, as suggested by friend of the blog and occasional guest author Gwynne Raskind.",
                  @"Friday Q&A 2015-09-04: Let's Build dispatch_queue at 2015-09-04 13:22",
                  @"Swift's classes tend to be straightforward for most people new to the language to understand. They work pretty much like classes in any other language. Whether you've come from Objective-C or Java or Ruby, you've worked with something similar. Swift's structs are another matter. They look sort of like classes, but they're value types, and they don't do inheritance, and there's this copy-on-write thing I keep hearing about? Where do they live, anyway, and how do they work? Today, I'm going to take a close look at just how structs get stored and manipulated in memory.",
                  @"使用某种特定的字体系列（Geneva）完全取决于用户机器上该字体系列是否可用；这个属性没有指示任何字体下载。因此，强烈推荐使用一个通用字体系列名作为后路。",
                  @"font-family 可以把多个字体名称作为一个“回退”系统来保存。如果浏览器不支持第一个字体，则会尝试下一个。也就是说，font-family 属性的值是用于某个元素的字体族名称或/及类族名称的一个优先表。浏览器会使用它可识别的第一个值。",
                  @"A compressor can be used to reduce sibilance ('ess' sounds) in vocals by feeding the compressor with an EQ set to the relevant frequencies, so that only those frequencies activate the compressor. If unchecked, sibilance could cause distortion even if sound levels are not very high. This usage is called de-essing.",
                  @"Pop is an extensible animation engine for iOS, tvOS, and OS X. In addition to basic static animations, it supports spring and decay dynamic animations, making it useful for building realistic, physics-based interactions. The API allows quick integration with existing Objective-C or Swift codebases and enables the animation of any property on any object. It's a mature and well-tested framework that drives all the animations and transitions in Paper.",
                  @"The NSObject class lies at the root of (almost) all classes we build and use as part of Cocoa programming. What does it actually do, though, and how does it do it? Today, I'm going to rebuild NSObject from scratch, as suggested by friend of the blog and occasional guest author Gwynne Raskind.",
                  @"Friday Q&A 2015-09-04: Let's Build dispatch_queue at 2015-09-04 13:22",
                  @"Swift's classes tend to be straightforward for most people new to the language to understand. They work pretty much like classes in any other language. Whether you've come from Objective-C or Java or Ruby, you've worked with something similar. Swift's structs are another matter. They look sort of like classes, but they're value types, and they don't do inheritance, and there's this copy-on-write thing I keep hearing about? Where do they live, anyway, and how do they work? Today, I'm going to take a close look at just how structs get stored and manipulated in memory.",
                  @"使用某种特定的字体系列（Geneva）完全取决于用户机器上该字体系列是否可用；这个属性没有指示任何字体下载。因此，强烈推荐使用一个通用字体系列名作为后路。",
                  @"font-family 可以把多个字体名称作为一个“回退”系统来保存。如果浏览器不支持第一个字体，则会尝试下一个。也就是说，font-family 属性的值是用于某个元素的字体族名称或/及类族名称的一个优先表。浏览器会使用它可识别的第一个值。",
                  @"A compressor can be used to reduce sibilance ('ess' sounds) in vocals by feeding the compressor with an EQ set to the relevant frequencies, so that only those frequencies activate the compressor. If unchecked, sibilance could cause distortion even if sound levels are not very high. This usage is called de-essing.",
                  @"Pop is an extensible animation engine for iOS, tvOS, and OS X. In addition to basic static animations, it supports spring and decay dynamic animations, making it useful for building realistic, physics-based interactions. The API allows quick integration with existing Objective-C or Swift codebases and enables the animation of any property on any object. It's a mature and well-tested framework that drives all the animations and transitions in Paper."];
        
        _contentHeight = self.bounds.size.height - UIApplication.sharedApplication.statusBarFrame.size.height;

        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        [self titleLabel];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class]) {
        CGPoint location = [gestureRecognizer locationInView:self.tableView];
        if (location.y < 0) {
            return YES;
        }
        return NO;
    }
    return YES;
}

- (void)show {
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    self.hidden = NO;
    [self makeKeyAndVisible];
    [UIView animateWithDuration:0.25 animations:^{
        if (self.tableView.contentSize.height < self.tableView.bounds.size.height) {
            self.translationY = self.tableView.contentSize.height;
        }else {
            self.translationY = self.contentHeight / 3.0;
        }
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }];
}

- (void)hide {
    [self pop_removeAllAnimations];
    [UIView animateWithDuration:0.25 animations:^{
        self.translationY = 0;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self resignKeyWindow];
        self.hidden = YES;
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 50)];
        _titleLabel.text = @"标题";
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.layer.cornerRadius = 15;
        [_titleLabel.layer setMasksToBounds:YES];
        
        UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height + 35, _titleLabel.bounds.size.width, 15)];
        maskView.backgroundColor = [UIColor whiteColor];
        [self addSubview:maskView];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), self.bounds.size.width, _contentHeight - self.titleLabel.frame.size.height)];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //_tableView.scrollEnabled = NO;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.estimatedRowHeight = 50;
        _tableView.estimatedSectionHeaderHeight = 50;
        _tableView.sectionHeaderHeight = 50;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.tableFooterView = [UIView new];
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        cell.textLabel.numberOfLines = 0;
    }
    cell.textLabel.text = _data[indexPath.row];
    return cell;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self pop_removeAllAnimations];
            self.startTranslationY = _translationY;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGFloat tmpTranslationY = _startTranslationY - [panGesture translationInView:self.tableView].y;
            if (self.tableView.contentSize.height < self.tableView.bounds.size.height && tmpTranslationY > self.tableView.contentSize.height) {
                self.translationY = self.tableView.contentSize.height + (tmpTranslationY - self.tableView.contentSize.height) / 2.0;
            }else {
                self.translationY = tmpTranslationY;
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGPoint velocity = [panGesture velocityInView:self.tableView];
            if (self.tableView.contentSize.height <= self.tableView.bounds.size.height) {
                if (self.bounds.origin.y > self.tableView.contentSize.height) {
                    [self bounceToTranslationY:self.tableView.contentSize.height velocity:0];
                }else {
                    [self hide];
                }
            }else {
                if (self.bounds.origin.y < _contentHeight) {
                    [self calculateBounce:velocity.y];
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void)calculateBounce:(CGFloat)velocity {
    if (self.bounds.origin.y < _contentHeight && self.bounds.origin.y > _contentHeight * 3.0 / 4.0) {
        if (velocity > 100) {
            [self bounceToTranslationY:_contentHeight / 3.0 velocity:0];
        }else {
            [self bounceToTranslationY:_contentHeight velocity:0];
        }
    }else if (self.bounds.origin.y <= _contentHeight* 3.0 / 4.0 && self.bounds.origin.y > _contentHeight / 3.0) {
        if (-velocity > 100) {
            [self bounceToTranslationY:_contentHeight velocity:0];
        }else {
            [self bounceToTranslationY:_contentHeight / 3.0 velocity:0];
        }
    }else if (self.bounds.origin.y <= _contentHeight / 3.0) {
        [self hide];
    }
}


- (void)setTranslationY:(CGFloat)translationY {
    if (translationY >= _contentHeight) {
        translationY = _contentHeight;
    }
    _translationY = translationY;
    CGRect contentBounds = self.bounds;
    
    if (_top) {
        contentBounds.origin.y = _contentHeight;
        if (self.tableView.contentOffset.y <= 0) {
            self.top = NO;
        }
    }else {
        contentBounds.origin.y = _translationY;
        if (_translationY >= _contentHeight) {
            self.top = YES;
        }else {
            self.tableView.contentOffset = CGPointZero;
        }
    }
    self.bounds = contentBounds;
}

- (void)bounceToTranslationY:(CGFloat)translationY velocity:(CGFloat)velocity {
    POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithCustomPropertyReadBlock:^(id obj, CGFloat *values) {
        values[0] = [obj translationY];
    } writeBlock:^(id obj, const CGFloat *values) {
        [obj setTranslationY:values[0]];
    }];
    springAnimation.velocity = [NSNumber numberWithFloat:velocity];
    springAnimation.toValue = [NSNumber numberWithFloat:translationY];
    springAnimation.springBounciness = 0.0;
    springAnimation.springSpeed = 3.0;
    [self pop_addAnimation:springAnimation forKey:@"bounce"];
    [self pop_removeAnimationForKey:@"decelerate"];
}

@end
