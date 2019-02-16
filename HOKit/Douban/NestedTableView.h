//
//  NestedTableView.h
//  HOKit
//
//  Created by HoChan on 2019/2/16.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NestedTableView : UITableView

+ (NestedTableView *)findCurrentNestedScrollViewInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
