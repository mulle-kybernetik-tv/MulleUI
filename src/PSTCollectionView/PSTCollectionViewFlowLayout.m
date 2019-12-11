//
//  PSTCollectionViewFlowLayout.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewFlowLayout.h"
#import "PSTCollectionView.h"
#import "PSTGridLayoutItem.h"
#import "PSTGridLayoutInfo.h"
#import "PSTGridLayoutRow.h"
#import "PSTGridLayoutSection.h"
#import "NSIndexPath+PSTCollectionViewAdditions.h"
#import "NSValue+CGGeometry.h"
#import <objc/runtime.h>


static inline CGFloat  MAX( CGFloat a, CGFloat b)
{
   return( a < b ? b : a);
}


NSString * const PSTCollectionElementKindSectionHeader = @"UICollectionElementKindSectionHeader";
NSString * const PSTCollectionElementKindSectionFooter = @"UICollectionElementKindSectionFooter";

// this is not exposed in UICollectionViewFlowLayout
NSString * const PSTFlowLayoutCommonRowHorizontalAlignmentKey = @"UIFlowLayoutCommonRowHorizontalAlignmentKey";
NSString * const PSTFlowLayoutLastRowHorizontalAlignmentKey = @"UIFlowLayoutLastRowHorizontalAlignmentKey";
NSString * const PSTFlowLayoutRowVerticalAlignmentKey = @"UIFlowLayoutRowVerticalAlignmentKey";

@implementation PSTCollectionViewFlowLayout
///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (void)commonInit {
    _itemSize = CGSizeMake(50.f, 50.f);
    _minimumLineSpacing = 10.f;
    _minimumInteritemSpacing = 10.f;
    _sectionInset = UIEdgeInsetsZero;
    _scrollDirection = PSTCollectionViewScrollDirectionVertical;
    _headerReferenceSize = CGSizeZero;
    _footerReferenceSize = CGSizeZero;
}

- (id)init {
    if ((self = [super init])) {
        [self commonInit];

        // set default values for row alignment.
        _rowAlignmentsOptions = @{
                PSTFlowLayoutCommonRowHorizontalAlignmentKey : @(PSTFlowLayoutHorizontalAlignmentJustify),
                PSTFlowLayoutLastRowHorizontalAlignmentKey : @(PSTFlowLayoutHorizontalAlignmentJustify),
                // TODO: those values are some enum. find out what that is.
                PSTFlowLayoutRowVerticalAlignmentKey : @(1),
        };
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewLayout

- (NSArray * )layoutAttributesForElementsInRect:(CGRect)rect {
    // Apple calls _layoutAttributesForItemsInRect
    if (!_data) [self prepareLayout];

    NSMutableArray * layoutAttributesArray = [NSMutableArray array];
    for (PSTGridLayoutSection *section in [_data sections]) {
        if (CGRectIntersectsRect([section frame], rect)) {

            // if we have fixed size, calculate item frames only once.
            // this also uses the default PSTFlowLayoutCommonRowHorizontalAlignmentKey alignment
            // for the last row. (we want this effect!)
            NSMutableDictionary * rectCache = _rectCache;
            NSUInteger sectionIndex = [[_data sections] indexOfObjectIdenticalTo:section];

            CGRect normalizedHeaderFrame = [section headerFrame];
            normalizedHeaderFrame.origin.x += [section frame].origin.x;
            normalizedHeaderFrame.origin.y += [section frame].origin.y;
            if (!CGRectIsEmpty(normalizedHeaderFrame) && CGRectIntersectsRect(normalizedHeaderFrame, rect)) {
                PSTCollectionViewLayoutAttributes *layoutAttributes = [[[self class] layoutAttributesClass] layoutAttributesForSupplementaryViewOfKind:PSTCollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:(NSInteger)sectionIndex]];
                [layoutAttributes setFrame:normalizedHeaderFrame];
                [layoutAttributesArray addObject:layoutAttributes];
            }

            NSArray * itemRects = [rectCache objectForKey:@(sectionIndex)];
            if (!itemRects && [section fixedItemSize] && [[section rows] count]) {
                itemRects = [[[section rows] objectAtIndex:0] itemRects];
                if (itemRects) [rectCache setObject:itemRects
                                             forKey:@(sectionIndex)];
            }
            
            for (PSTGridLayoutRow *row in [section rows]) {
                CGRect normalizedRowFrame = [row rowFrame];
                
                normalizedRowFrame.origin.x += [section frame].origin.x;
                normalizedRowFrame.origin.y += [section frame].origin.y;
                
                if (CGRectIntersectsRect(normalizedRowFrame, rect)) {
                    // TODO be more fine-grained for items

                    for (NSInteger itemIndex = 0; itemIndex < [row itemCount]; itemIndex++) {
                        PSTCollectionViewLayoutAttributes *layoutAttributes;
                        NSUInteger sectionItemIndex;
                        CGRect itemFrame;
                        if ([row fixedItemSize]) {
                            itemFrame = [[itemRects objectAtIndex:(NSUInteger)itemIndex] CGRectValue];
                            sectionItemIndex = (NSUInteger)([row index] * [section itemsByRowCount] + itemIndex);
                        }else {
                            PSTGridLayoutItem *item = [[row items] objectAtIndex:(NSUInteger)itemIndex];
                            sectionItemIndex = [[section items] indexOfObjectIdenticalTo:item];
                            itemFrame = [item itemFrame];
                        }

                        CGRect normalisedItemFrame = CGRectMake(normalizedRowFrame.origin.x + itemFrame.origin.x, normalizedRowFrame.origin.y + itemFrame.origin.y, itemFrame.size.width, itemFrame.size.height);
                        
                        if (CGRectIntersectsRect(normalisedItemFrame, rect)) {
                            layoutAttributes = [[[self class] layoutAttributesClass] layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:(NSInteger)sectionItemIndex inSection:(NSInteger)sectionIndex]];
                            [layoutAttributes setFrame:normalisedItemFrame];
                            [layoutAttributesArray addObject:layoutAttributes];
                        }
                    }
                }
            }

            CGRect normalizedFooterFrame = [section footerFrame];
            normalizedFooterFrame.origin.x += [section frame].origin.x;
            normalizedFooterFrame.origin.y += [section frame].origin.y;
            if (!CGRectIsEmpty(normalizedFooterFrame) && CGRectIntersectsRect(normalizedFooterFrame, rect)) {
                PSTCollectionViewLayoutAttributes *layoutAttributes = [[[self class] layoutAttributesClass] layoutAttributesForSupplementaryViewOfKind:PSTCollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:(NSInteger)sectionIndex]];
                [layoutAttributes setFrame:normalizedFooterFrame];
                [layoutAttributesArray addObject:layoutAttributes];
            }
        }
    }
    return layoutAttributesArray;
}

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_data) [self prepareLayout];

    PSTGridLayoutSection *section = [[_data sections] objectAtIndex:(NSUInteger)[indexPath section]];
    PSTGridLayoutRow *row = nil;
    CGRect itemFrame = CGRectZero;

    if ([section fixedItemSize] && [section itemsByRowCount] > 0 && [indexPath item] / [section itemsByRowCount] < (NSInteger) [[section rows] count]) {
        row = [[section rows] objectAtIndex:(NSUInteger)([indexPath item] / [section itemsByRowCount])];
        NSUInteger itemIndex = (NSUInteger)([indexPath item] % [section itemsByRowCount]);
        NSArray * itemRects = [row itemRects];
        itemFrame = [[itemRects objectAtIndex:itemIndex] CGRectValue];
    }else if ([indexPath item] < (NSInteger)[[section items] count]) {
        PSTGridLayoutItem *item = [[section items] objectAtIndex:(NSUInteger)[indexPath item]];
        row       = [item rowObject];
        itemFrame = [item itemFrame];
    }

    PSTCollectionViewLayoutAttributes *layoutAttributes = [[[self class] layoutAttributesClass] layoutAttributesForCellWithIndexPath:indexPath];

    // calculate item rect
    CGRect normalizedRowFrame = [row rowFrame];
    normalizedRowFrame.origin.x += [section frame].origin.x;
    normalizedRowFrame.origin.y += [section frame].origin.y;
    [layoutAttributes setFrame:CGRectMake(normalizedRowFrame.origin.x + itemFrame.origin.x, normalizedRowFrame.origin.y + itemFrame.origin.y, itemFrame.size.width, itemFrame.size.height)];

    return layoutAttributes;
}

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString * )kind atIndexPath:(NSIndexPath *)indexPath {
    if (!_data) [self prepareLayout];

    NSUInteger sectionIndex = (NSUInteger)[indexPath section];
    PSTCollectionViewLayoutAttributes *layoutAttributes = nil;

    if (sectionIndex < [[_data sections] count]) {
        PSTGridLayoutSection *section = [[_data sections] objectAtIndex:sectionIndex];

        CGRect normalizedFrame = CGRectZero;
        if ([kind isEqualToString:PSTCollectionElementKindSectionHeader]) {
            normalizedFrame = [section headerFrame];
        }
        else if ([kind isEqualToString:PSTCollectionElementKindSectionFooter]) {
            normalizedFrame = [section footerFrame];
        }

        if (!CGRectIsEmpty(normalizedFrame)) {
            normalizedFrame.origin.x += [section frame].origin.x;
            normalizedFrame.origin.y += [section frame].origin.y;

            layoutAttributes = [[[self class] layoutAttributesClass] layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:[NSIndexPath indexPathForItem:0 inSection:(NSInteger)sectionIndex]]; 
            [layoutAttributes setFrame:normalizedFrame];
        }
    }
    return layoutAttributes;
}

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewWithReuseIdentifier:(NSString * )identifier atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGSize)collectionViewContentSize {
    if (!_data) [self prepareLayout];

    return [_data contentSize];
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(sectionInset, _sectionInset)) {
        _sectionInset = sectionInset;
        [self invalidateLayout];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Invalidating the Layout

- (void)invalidateLayout {
    [super invalidateLayout];
    [_rectCache autorelease];
    _rectCache = nil;
    _data = nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    // we need to recalculate on width changes
    if ((_visibleBounds.size.width != newBounds.size.width && [self scrollDirection] == PSTCollectionViewScrollDirectionVertical) || (_visibleBounds.size.height != newBounds.size.height && [self scrollDirection] == PSTCollectionViewScrollDirectionHorizontal)) {
        _visibleBounds = [[self collectionView] bounds];
        return YES;
    }
    return NO;
}

// return a point at which to rest after scrolling - for layouts that want snap-to-point scrolling behavior
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    return proposedContentOffset;
}

- (void)prepareLayout {
    // custom ivars
    [_rectCache autorelease];
    _rectCache = [NSMutableDictionary new];

    _data = [PSTGridLayoutInfo new]; // clear old layout data
    [_data setHorizontal:[self scrollDirection] == PSTCollectionViewScrollDirectionHorizontal];
    _visibleBounds = [[self collectionView] bounds];
    CGSize collectionViewSize = _visibleBounds.size;
    [_data setDimension:[_data horizontal] ? collectionViewSize.height : collectionViewSize.width];
    [_data setRowAlignmentOptions:_rowAlignmentsOptions];
    [self fetchItemsInfo];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)fetchItemsInfo {
    [self getSizingInfos];
    [self updateItemsLayout];
}

// get size of all items (if delegate is implemented)
- (void)getSizingInfos {
    assert( [[_data sections] count] == 0); //, @"Grid layout is already populated?");

    id<PSTCollectionViewDelegateFlowLayout> flowDataSource = (id<PSTCollectionViewDelegateFlowLayout>)[[self collectionView] delegate];

    BOOL implementsSizeDelegate = [flowDataSource respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)];
    BOOL implementsHeaderReferenceDelegate = [flowDataSource respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)];
    BOOL implementsFooterReferenceDelegate = [flowDataSource respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)];

    NSInteger numberOfSections = [[self collectionView] numberOfSections];
    for (NSInteger section = 0; section < numberOfSections; section++) {
        PSTGridLayoutSection *layoutSection = [_data addSection];
        [layoutSection setVerticalInterstice:[_data horizontal] ? [self minimumInteritemSpacing] : [self minimumLineSpacing]];
        [layoutSection setHorizontalInterstice:![_data horizontal] ? [self minimumInteritemSpacing] : [self minimumLineSpacing]];

        if ([flowDataSource respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            [layoutSection setSectionMargins:[flowDataSource collectionView:[self collectionView] layout:self insetForSectionAtIndex:section]];
        }else {
            [layoutSection setSectionMargins:[self sectionInset]];
        }

        if ([flowDataSource respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
            CGFloat minimumLineSpacing = [flowDataSource collectionView:[self collectionView] layout:self minimumLineSpacingForSectionAtIndex:section];
            if ([_data horizontal]) {
                [layoutSection setHorizontalInterstice:minimumLineSpacing];
            }else {
                [layoutSection setVerticalInterstice:minimumLineSpacing];
            }
        }

        if ([flowDataSource respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
            CGFloat minimumInterimSpacing = [flowDataSource collectionView:[self collectionView] layout:self minimumInteritemSpacingForSectionAtIndex:section];
            if ([_data horizontal]) {
                [layoutSection setHorizontalInterstice:minimumInterimSpacing];
            }else {
                [layoutSection setVerticalInterstice:minimumInterimSpacing];
            }               
        }

        CGSize headerReferenceSize;
        if (implementsHeaderReferenceDelegate) {
            headerReferenceSize = [flowDataSource collectionView:[self collectionView] layout:self referenceSizeForHeaderInSection:section];
        }else {
            headerReferenceSize = [self headerReferenceSize];
        }
        [layoutSection setHeaderDimension:[_data horizontal] ? headerReferenceSize.width : headerReferenceSize.height];

        CGSize footerReferenceSize;
        if (implementsFooterReferenceDelegate) {
            footerReferenceSize = [flowDataSource collectionView:[self collectionView] layout:self referenceSizeForFooterInSection:section];
        }else {
            footerReferenceSize = [self footerReferenceSize];
        }
        [layoutSection setFooterDimension:[_data horizontal] ? footerReferenceSize.width : footerReferenceSize.height];

        NSInteger numberOfItems = [[self collectionView] numberOfItemsInSection:section];

        // if delegate implements size delegate, query it for all items
        if (implementsSizeDelegate) {
            for (NSInteger item = 0; item < numberOfItems; item++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:(NSInteger)section];
                CGSize itemSize = implementsSizeDelegate ? [flowDataSource collectionView:[self collectionView] layout:self sizeForItemAtIndexPath:indexPath] : [self itemSize];

                PSTGridLayoutItem *layoutItem = [layoutSection addItem];
                [layoutItem setItemFrame:(CGRect){.size=itemSize}];
            }
            // if not, go the fast path
        }else {
            [layoutSection setFixedItemSize:YES];
            [layoutSection setItemSize:[self itemSize]];
            [layoutSection setItemsCount:numberOfItems];
        }
    }
}

- (void)updateItemsLayout {
    CGSize contentSize = CGSizeZero;
    for (PSTGridLayoutSection *section in [_data sections]) {
        [section computeLayout];

        // update section offset to make frame absolute (section only calculates relative)
        CGRect sectionFrame = [section frame];
        if ([_data horizontal]) {
            sectionFrame.origin.x += contentSize.width;
            contentSize.width += [section frame].size.width + [section frame].origin.x;
            contentSize.height = MAX(contentSize.height, sectionFrame.size.height + [section frame].origin.y + [section sectionMargins].top + [section sectionMargins].bottom);
        }else {
            sectionFrame.origin.y += contentSize.height;
            contentSize.height += sectionFrame.size.height + [section frame].origin.y;
            contentSize.width = MAX(contentSize.width, sectionFrame.size.width + [section frame].origin.x + [section sectionMargins].left + [section sectionMargins].right);
        }
        [section setFrame:sectionFrame];
    }
    [_data setContentSize:contentSize];
}

@end
