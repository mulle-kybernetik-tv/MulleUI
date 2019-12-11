//
//  PSTCollectionViewItemKey.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewItemKey.h"

NSString * const PSTCollectionElementKindCell = @"UICollectionElementKindCell";

@implementation PSTCollectionViewItemKey

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Static

+ (id)collectionItemKeyForCellWithIndexPath:(NSIndexPath *)indexPath {
    PSTCollectionViewItemKey *key = [[[self class] new] autorelease];
    [key setIndexPath:indexPath];
    [key setType:PSTCollectionViewItemTypeCell];
    [key setIdentifier:PSTCollectionElementKindCell];
    return key;
}

+ (id)collectionItemKeyForLayoutAttributes:(PSTCollectionViewLayoutAttributes *)layoutAttributes {
    PSTCollectionViewItemKey *key = [[[self class] new] autorelease];
    [key setIndexPath:[layoutAttributes indexPath]];
    PSTCollectionViewItemType const itemType = [layoutAttributes representedElementCategory];
    [key setType:itemType];
    [key setIdentifier:[layoutAttributes representedElementKind]];
    return key;
}

NSString * PSTCollectionViewItemTypeToString(PSTCollectionViewItemType type) {
    switch (type) {
        case PSTCollectionViewItemTypeCell: return @"Cell";
        case PSTCollectionViewItemTypeDecorationView: return @"Decoration";
        case PSTCollectionViewItemTypeSupplementaryView: return @"Supplementary";
        default: return @"<INVALID>";
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (NSString * )description {
    return [NSString stringWithFormat:@"<%@: %p Type = %@ Identifier=%@ IndexPath = %@>", NSStringFromClass([self class]),
                                      self, PSTCollectionViewItemTypeToString([self type]), _identifier, [self indexPath]];
}

- (NSUInteger)hash {
    return (([_indexPath hash] + _type) * 31) + [_identifier hash];
}

- (BOOL)isEqual:(id)other {
    if ([other isKindOfClass:[self class]]) {
        PSTCollectionViewItemKey *otherKeyItem = (PSTCollectionViewItemKey *)other;
        // identifier might be nil?
        if (_type == [otherKeyItem type] && [_indexPath isEqual:[otherKeyItem indexPath]] && ([_identifier isEqualToString:[otherKeyItem identifier]] || _identifier == [otherKeyItem identifier])) {
            return YES;
        }
    }
    return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    PSTCollectionViewItemKey *itemKey = [[[self class] new] autorelease];
    [itemKey setIndexPath:[self indexPath]];
    [itemKey setType:[self type]];
    [itemKey setIdentifier:[self identifier]];
    return itemKey;
}

@end
