//
//  UIScrollView+EnableSimultaneously.m
//  HOKit
//
//  Created by HoChan on 2019/2/6.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import "UIScrollView+EnableSimultaneously.h"

@implementation UIScrollView (EnableSimultaneously)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
