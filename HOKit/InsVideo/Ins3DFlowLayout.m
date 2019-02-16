//
//  Ins3DFlowLayout.m
//  HOKit
//
//  Created by HoChan on 2019/2/16.
//  Copyright © 2019 Okhoochan. All rights reserved.
//

#import "Ins3DFlowLayout.h"

@implementation Ins3DLayoutAttributes

- (id)copyWithZone:(NSZone *)zone {
    Ins3DLayoutAttributes *copy = [super copyWithZone:zone];
    copy.angle = self.angle;
    return copy;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:Ins3DLayoutAttributes.class]) {
        return NO;
    }
    
    Ins3DLayoutAttributes *otherObject = object;
    if (otherObject.angle != self.angle) {
        return NO;
    }
    return [super isEqual:object];
}

@end

@implementation Ins3DFlowLayout

+ (Class)layoutAttributesClass {
    return Ins3DLayoutAttributes.class;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *layoutAttributesArray = [super layoutAttributesForElementsInRect:rect];
    for (Ins3DLayoutAttributes *layoutAttributes in layoutAttributesArray) {
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            layoutAttributes.angle = [self calculateAngleForLayoutAttributes:layoutAttributes];
        }
    }
    return layoutAttributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    Ins3DLayoutAttributes *layoutAttributes = (Ins3DLayoutAttributes *)[super layoutAttributesForItemAtIndexPath:indexPath];
    return layoutAttributes;
}

- (CGFloat)calculateAngleForLayoutAttributes:(Ins3DLayoutAttributes *)layoutAttributes {
    return M_PI_2 * (self.collectionView.bounds.origin.x - layoutAttributes.indexPath.row * layoutAttributes.size.width) / self.collectionView.bounds.size.width;
}

@end
