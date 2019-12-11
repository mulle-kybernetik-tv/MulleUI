//
//  PSTCollectionViewItemKey.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewCommon.h"
#import "PSTCollectionViewLayout.h"

extern NSString * const PSTCollectionElementKindCell;
extern NSString * const PSTCollectionElementKindDecorationView;
@class PSTCollectionViewLayoutAttributes;

NSString * PSTCollectionViewItemTypeToString(PSTCollectionViewItemType type); // debug helper

// Used in NSDictionaries
@interface PSTCollectionViewItemKey : NSObject <NSCopying>

+ (id)collectionItemKeyForLayoutAttributes:(PSTCollectionViewLayoutAttributes *)layoutAttributes;

+ (id)collectionItemKeyForCellWithIndexPath:(NSIndexPath *)indexPath;

@property ( assign) PSTCollectionViewItemType type;
@property ( retain) NSIndexPath *indexPath;
@property ( retain) NSString * identifier;

@end
