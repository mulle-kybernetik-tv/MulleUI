//
//  PSTCollectionViewData.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewCommon.h"

#import "CGGeometry.h"


@class PSTCollectionView, PSTCollectionViewLayout, PSTCollectionViewLayoutAttributes;

// https://github.com/steipete/iOS6-Runtime-Headers/blob/master/UICollectionViewData.h
@interface PSTCollectionViewData : NSObject
{
    CGRect _validLayoutRect;

    NSInteger _numItems;
    NSInteger _numSections;
    NSInteger *_sectionItemCounts;
//    id __retain* _globalItems; ///< _globalItems appears to be cached layoutAttributes. But adding that work in opens a can of worms, so deferring until later.

/*
 // At this point, I've no idea how _screenPageDict is structured. Looks like some optimization for layoutAttributesForElementsInRect.
 And why UICGPointKey? Isn't that doable with NSValue?

 "<UICGPointKey: 0x11432d40>" = "<NSMutableIndexSet: 0x11432c60>[number of indexes: 9 (in 1 ranges), indexes: (0-8)]";
 "<UICGPointKey: 0xb94bf60>" = "<NSMutableIndexSet: 0x18dea7e0>[number of indexes: 11 (in 2 ranges), indexes: (6-15 17)]";

 (lldb) p (CGPoint)[[[[[collectionView valueForKey:@"_collectionViewData"] valueForKey:@"_screenPageDict"] allKeys] objectAtIndex:0] point]
 (CGPoint) $11 = (x=15, y=159)
 (lldb) p (CGPoint)[[[[[collectionView valueForKey:@"_collectionViewData"] valueForKey:@"_screenPageDict"] allKeys] objectAtIndex:1] point]
 (CGPoint) $12 = (x=15, y=1128)

 // https://github.com/steipete/iOS6-Runtime-Headers/blob/master/UICGPointKey.h

 NSMutableDictionary * _screenPageDict;
 */

    // @steipete

    CGSize _contentSize;
    struct {
        unsigned int contentSizeIsValid:1;
        unsigned int itemCountsAreValid:1;
        unsigned int layoutIsPrepared:1;
    }_collectionViewDataFlags;
}

@property ( assign) PSTCollectionView *collectionView;
@property ( assign) PSTCollectionViewLayout *layout;
@property ( retain) NSArray * cachedLayoutAttributes;

// Designated initializer.
- (id)initWithCollectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout *)layout;

// Ensure data is valid. may fetches items from dataSource and layout.
- (void)validateLayoutInRect:(CGRect)rect;

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath;

/*
 - (CGRect)rectForSupplementaryElementOfKind:(id)arg1 atIndexPath:(id)arg2;
 - (CGRect)rectForDecorationElementOfKind:(id)arg1 atIndexPath:(id)arg2;
 - (CGRect)rectForGlobalItemIndex:(int)arg1;
*/

// No fucking idea (yet)
- (NSUInteger)globalIndexForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForItemAtGlobalIndex:(NSInteger)index;

// Fetch layout attributes
- (NSArray * )layoutAttributesForElementsInRect:(CGRect)rect;

/*
- (PSTCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (PSTCollectionViewLayoutAttributes *)layoutAttributesForElementsInSection:(NSInteger)section;
- (PSTCollectionViewLayoutAttributes *)layoutAttributesForGlobalItemIndex:(NSInteger)index;
- (PSTCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(id)arg1 atIndexPath:(NSIndexPath *)indexPath;
- (PSTCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(id)arg1 atIndexPath:(NSIndexPath *)indexPath;
 - (id)existingSupplementaryLayoutAttributesInSection:(int)arg1;
*/

// Make data to re-evaluate dataSources.
- (void)invalidate;

// Access cached item data
- (NSInteger)numberOfItemsBeforeSection:(NSInteger)section;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (NSInteger)numberOfItems;

- (NSInteger)numberOfSections;

// Total size of the content.
- (CGRect)collectionViewContentRect;

@property (readonly) BOOL layoutIsPrepared;

/*
 - (void)_setLayoutAttributes:(id)arg1 atGlobalItemIndex:(int)arg2;
 - (void)_setupMutableIndexPath:(id*)arg1 forGlobalItemIndex:(int)arg2;
 - (id)_screenPageForPoint:(struct CGPoint { float x1; float x2; })arg1;
 - (void)_validateContentSize;
 - (void)_validateItemCounts;
 - (void)_updateItemCounts;
 - (void)_loadEverything;
 - (void)_prepareToLoadData;
 - (void)invalidate:(BOOL)arg1;
 */

@end
