//
//  NestedTableView.m
//  HOKit
//
//  Created by HoChan on 2019/2/16.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import "NestedTableView.h"

@implementation NestedTableView

+ (NestedTableView *)findCurrentNestedScrollViewInView:(UIView *)view {
    NSArray *nestedScrollViews = [self findAllNestedScrollViewsInView:view];
    for (UIView *view in nestedScrollViews) {
        CGRect convertRect = [view.superview convertRect:view.frame toView:nil];
        if (convertRect.origin.x >= 0 && CGRectGetMaxX(convertRect) <= UIScreen.mainScreen.bounds.size.width) {
            return (NestedTableView *)view;
        }
    }
    return nil;
}

+ (NSArray *)findAllNestedScrollViewsInView:(UIView *)view {
    NSMutableArray *nestedScrollViews = [[NSMutableArray alloc] init];
    if ([view isKindOfClass:NestedTableView.class]) {
        [nestedScrollViews addObject:view];
    }else {
        for (UIView *subView in view.subviews) {
            [nestedScrollViews addObjectsFromArray:[self findAllNestedScrollViewsInView:subView]];
        }
    }
    return nestedScrollViews.copy;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
