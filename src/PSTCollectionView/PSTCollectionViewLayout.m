//
//  PSTCollectionViewLayout.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionView.h"
#import "PSTCollectionViewItemKey.h"
#import "PSTCollectionViewData.h"
#import "NSIndexPath+PSTCollectionViewAdditions.h"
#import "UIView+Yoga.h"
#import "NSString+CGGeometry.h"
#import "NSMutableIndexSet.h"
#import "NSIndexPath.h"
#import "NSIndexSet.h"
#import <objc/runtime.h>

@interface PSTCollectionView (Private)
- (id)currentUpdate;
- (NSDictionary * )visibleViewsDict;
- (PSTCollectionViewData *)collectionViewData;
- (CGRect)visibleBoundRects; // visibleBounds is flagged as private API (wtf)
@end

@interface PSTCollectionReusableView ( Private)
- (void)setIndexPath:(NSIndexPath *)indexPath;
@end

@interface PSTCollectionViewUpdateItem ( Private)
- (BOOL)isSectionOperation;
- (NSIndexPath *)indexPath;
@end


@implementation PSTCollectionViewLayoutAttributes

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Static

+ (instancetype)layoutAttributesForCellWithIndexPath:(NSIndexPath *)indexPath {
    PSTCollectionViewLayoutAttributes *attributes = [[self new] autorelease];
    [attributes setElementKind:PSTCollectionElementKindCell];
    [attributes setElementCategory:PSTCollectionViewItemTypeCell];
    [attributes setIndexPath:indexPath];
    return attributes;
}

+ (instancetype)layoutAttributesForSupplementaryViewOfKind:(NSString * )elementKind withIndexPath:(NSIndexPath *)indexPath {
    PSTCollectionViewLayoutAttributes *attributes = [[self new] autorelease];
    [attributes setElementCategory:PSTCollectionViewItemTypeSupplementaryView];
    [attributes setElementKind:elementKind];
    [attributes setIndexPath:indexPath];
    return attributes;
}

+ (instancetype)layoutAttributesForDecorationViewOfKind:(NSString * )elementKind withIndexPath:(NSIndexPath *)indexPath {
    PSTCollectionViewLayoutAttributes *attributes = [[self new] autorelease];
    [attributes setElementCategory:PSTCollectionViewItemTypeDecorationView];
    [attributes setElementKind:elementKind];
    [attributes setIndexPath:indexPath];
    return attributes;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)init {
    if ((self = [super init])) {
        _alpha = 1.f;
//        _transform3D = CATransform3DIdentity;
    }
    return self;
}

- (NSUInteger)hash {
    return ([_elementKind hash] * 31) + [_indexPath hash];
}

- (BOOL)isEqual:(id)other {
    if ([other isKindOfClass:[self class]]) {
        PSTCollectionViewLayoutAttributes *otherLayoutAttributes = (PSTCollectionViewLayoutAttributes *)other;
        if (_elementCategory == [otherLayoutAttributes elementCategory] && [_elementKind isEqual:[otherLayoutAttributes elementKind]] && [_indexPath isEqual:[otherLayoutAttributes indexPath]]) {
            return YES;
        }
    }
    return NO;
}

- (NSString * )description {
    return [NSString stringWithFormat:@"<%@: %p frame:%@ indexPath:%@ elementKind:%@>", NSStringFromClass([self class]), self, NSStringFromCGRect([self frame]), [self indexPath], [self elementKind]];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (PSTCollectionViewItemType)representedElementCategory {
    return _elementCategory;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (NSString * )representedElementKind {
    return [self elementKind];
}

- (BOOL)isDecorationView {
    return [self representedElementCategory] == PSTCollectionViewItemTypeDecorationView;
}

- (BOOL)isSupplementaryView {
    return [self representedElementCategory] == PSTCollectionViewItemTypeSupplementaryView;
}

- (BOOL)isCell {
    return [self representedElementCategory] == PSTCollectionViewItemTypeCell;
}

- (void) updateFrame {
    _frame = (CGRect){{_center.x - _size.width / 2, _center.y - _size.height / 2}, _size};
}

- (void)setSize:(CGSize)size {
    _size = size;
    [self updateFrame];
}

- (void)setCenter:(CGPoint)center {
    _center = center;
    [self updateFrame];
}

- (void)setFrame:(CGRect)frame {
    _frame = frame;
    _size = _frame.size;
    _center = (CGPoint){CGRectGetMidX(_frame), CGRectGetMidY(_frame)};
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    PSTCollectionViewLayoutAttributes *layoutAttributes = [[[self class] new] autorelease];
    [layoutAttributes setIndexPath:[self indexPath]];
    [layoutAttributes setElementKind:[self elementKind]];
    [layoutAttributes setElementCategory:[self elementCategory]];
    [layoutAttributes setFrame:[self frame]];
    [layoutAttributes setCenter:[self center]];
    [layoutAttributes setSize:[self size]];
//    layoutAttributes.transform3D = self.transform3D;
    [layoutAttributes setAlpha:[self alpha]];
    [layoutAttributes setZIndex:[self zIndex]];
    [layoutAttributes setHidden:[self isHidden]];
    return layoutAttributes;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollection/UICollection interoperability

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        NSString * selString = NSStringFromSelector(selector);
        if ([selString hasPrefix:@"_"]) {
            SEL cleanedSelector = NSSelectorFromString([selString substringFromIndex:1]);
            signature = [super methodSignatureForSelector:cleanedSelector];
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString * selString = NSStringFromSelector([invocation selector]);
    if ([selString hasPrefix:@"_"]) {
        SEL cleanedSelector = NSSelectorFromString([selString substringFromIndex:1]);
        if ([self respondsToSelector:cleanedSelector]) {
            [invocation setSelector:cleanedSelector];
            [invocation invokeWithTarget:self];
        }
    }else {
        [super forwardInvocation:invocation];
    }
}

@end



@implementation PSTCollectionViewLayout
///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)init {
    if ((self = [super init])) {
        _decorationViewClassDict = [NSMutableDictionary new];
        _decorationViewNibDict = [NSMutableDictionary new];
        _decorationViewExternalObjectsTables = [NSMutableDictionary new];
        _initialAnimationLayoutAttributesDict = [NSMutableDictionary new];
        _finalAnimationLayoutAttributesDict = [NSMutableDictionary new];
        _insertedSectionsSet = [NSMutableIndexSet new];
        _deletedSectionsSet = [NSMutableIndexSet new];
    }
    return self;
}

// - (void)awakeFromNib {
//     [super awakeFromNib];
// }

- (void)setCollectionView:(PSTCollectionView *)collectionView {
    if (collectionView != _collectionView) {
        _collectionView = collectionView;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Invalidating the Layout

- (void)invalidateLayout {
    [[_collectionView collectionViewData] invalidate];
    [_collectionView setNeedsLayout];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    // not sure about his..
    if (([[self collectionView] bounds].size.width != newBounds.size.width) || ([[self collectionView] bounds].size.height != newBounds.size.height)) {
        return YES;
    }
    return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Providing Layout Attributes

+ (Class)layoutAttributesClass {
    return [PSTCollectionViewLayoutAttributes class];
}

- (void)prepareLayout {
}

- (NSArray * )layoutAttributesForElementsInRect:(CGRect)rect {
    return nil;
}

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString * )kind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString * )kind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

// return a point at which to rest after scrolling - for layouts that want snap-to-point scrolling behavior
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    return proposedContentOffset;
}

- (CGSize)collectionViewContentSize {
    return CGSizeZero;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Responding to Collection View Updates

- (void)prepareForCollectionViewUpdates:(NSArray * )updateItems {
    NSDictionary * update = [_collectionView currentUpdate];

    for (PSTCollectionReusableView *view in [_collectionView visibleViewsDict]) {
        PSTCollectionViewLayoutAttributes *attr = [[[view layoutAttributes] copy] autorelease];
        if (attr) {
            if ([attr isCell]) {
                NSUInteger index = [[update objectForKey:@"oldModel"] globalIndexForItemAtIndexPath:[attr indexPath]];
                if (index != NSNotFound) {
                    [attr setIndexPath:[attr indexPath]];
                }
            }
            [_initialAnimationLayoutAttributesDict setObject:attr 
                                                     forKey:[PSTCollectionViewItemKey collectionItemKeyForLayoutAttributes:attr]];
        }
    }

    PSTCollectionViewData *collectionViewData = [_collectionView collectionViewData];

    CGRect bounds = [_collectionView visibleBoundRects];

    for (PSTCollectionViewLayoutAttributes *attr in [collectionViewData layoutAttributesForElementsInRect:bounds]) {
        if ([attr isCell]) {
            NSInteger index = (NSInteger)[collectionViewData globalIndexForItemAtIndexPath:[attr indexPath]];

            index = [[[update objectForKey:@"newToOldIndexMap"] objectAtIndex:(NSUInteger)index] integerValue];
            if (index != NSNotFound) {
                PSTCollectionViewLayoutAttributes *finalAttrs = [attr copy];
                [finalAttrs setIndexPath:[[update objectForKey:@"oldModel"] indexPathForItemAtGlobalIndex:index]];
                [finalAttrs setAlpha:0];
                [_finalAnimationLayoutAttributesDict setObject:finalAttrs
                                                       forKey:[PSTCollectionViewItemKey collectionItemKeyForLayoutAttributes:finalAttrs]];;
            }
        }
    }

    for (PSTCollectionViewUpdateItem *updateItem in updateItems) {
        PSTCollectionUpdateAction action = [updateItem updateAction];

        if ([updateItem isSectionOperation]) {
            if (action == PSTCollectionUpdateActionReload) {
                [_deletedSectionsSet addIndex:(NSUInteger)[[updateItem indexPathBeforeUpdate] section]];
                [_insertedSectionsSet addIndex:(NSUInteger)[[updateItem indexPathAfterUpdate] section]];
            }
            else {
                NSMutableIndexSet *indexSet = action == PSTCollectionUpdateActionInsert ? _insertedSectionsSet : _deletedSectionsSet;
                [indexSet addIndex:(NSUInteger)[[updateItem indexPath] section]];
            }
        }
        else {
            if (action == PSTCollectionUpdateActionDelete) {
                PSTCollectionViewItemKey *key = [PSTCollectionViewItemKey collectionItemKeyForCellWithIndexPath:
                        [updateItem indexPathBeforeUpdate]];

                PSTCollectionViewLayoutAttributes *attrs = [[[_finalAnimationLayoutAttributesDict objectForKey:key] copy] autorelease];

                if (attrs) {
                    [attrs setAlpha:0];
                    [_finalAnimationLayoutAttributesDict setObject:attrs forKey:key];
                }
            }
            else if (action == PSTCollectionUpdateActionReload || action == PSTCollectionUpdateActionInsert) {
                PSTCollectionViewItemKey *key = [PSTCollectionViewItemKey collectionItemKeyForCellWithIndexPath:
                        [updateItem indexPathAfterUpdate]];
                PSTCollectionViewLayoutAttributes *attrs = [[[_initialAnimationLayoutAttributesDict objectForKey:key] copy] autorelease];

                if (attrs) {
                    [attrs setAlpha:0];
                    [_initialAnimationLayoutAttributesDict setObject:attrs forKey:key];
                }
            }
        }
    }
}

- (PSTCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    PSTCollectionViewLayoutAttributes *attrs = [_initialAnimationLayoutAttributesDict objectForKey:[PSTCollectionViewItemKey collectionItemKeyForCellWithIndexPath:itemIndexPath]];

    if ([_insertedSectionsSet containsIndex:(NSUInteger)[itemIndexPath section]]) {
        attrs = [attrs copy];
        [attrs setAlpha:0];
    }
    return attrs;
}

- (PSTCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    PSTCollectionViewLayoutAttributes *attrs = [_finalAnimationLayoutAttributesDict objectForKey:[PSTCollectionViewItemKey collectionItemKeyForCellWithIndexPath:itemIndexPath]];

    if ([_deletedSectionsSet containsIndex:(NSUInteger)[itemIndexPath section]]) {
        attrs = [attrs copy];
        [attrs setAlpha:0];
    }
    return attrs;

}

- (PSTCollectionViewLayoutAttributes *)initialLayoutAttributesForInsertedSupplementaryElementOfKind:(NSString * )elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    PSTCollectionViewLayoutAttributes *attrs = [_initialAnimationLayoutAttributesDict objectForKey:[PSTCollectionViewItemKey collectionItemKeyForCellWithIndexPath:elementIndexPath]];

    if ([_insertedSectionsSet containsIndex:(NSUInteger)[elementIndexPath section]]) {
        attrs = [attrs copy];
        [attrs setAlpha:0];
    }
    return attrs;

}

- (PSTCollectionViewLayoutAttributes *)finalLayoutAttributesForDeletedSupplementaryElementOfKind:(NSString * )elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    return nil;
}

- (void)finalizeCollectionViewUpdates {
    [_initialAnimationLayoutAttributesDict removeAllObjects];
    [_finalAnimationLayoutAttributesDict removeAllObjects];
    [_deletedSectionsSet removeAllIndexes];
    [_insertedSectionsSet removeAllIndexes];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Registering Decoration Views

- (void)registerClass:(Class)viewClass forDecorationViewOfKind:(NSString * )kind {
    [_decorationViewClassDict setObject:viewClass forKey:kind];
}

// - (void)registerNib:(UINib *)nib forDecorationViewOfKind:(NSString * )kind {
//     [_decorationViewNibDict setObject:nib forKey:kind];
// }

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)setCollectionViewBoundsSize:(CGSize)size {
    _collectionViewBoundsSize = size;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollection/UICollection interoperability

#ifdef kPSUIInteroperabilityEnabled
#import <objc/runtime.h>
#import <objc/message.h>
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *sig = [super methodSignatureForSelector:selector];
    if(!sig) {
        NSString * selString = NSStringFromSelector(selector);
        if ([selString hasPrefix:@"_"]) {
            SEL cleanedSelector = NSSelectorFromString([selString substringFromIndex:1]);
            sig = [super methodSignatureForSelector:cleanedSelector];
        }
    }
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)inv {
    NSString * selString = NSStringFromSelector([inv selector]);
    if ([selString hasPrefix:@"_"]) {
        SEL cleanedSelector = NSSelectorFromString([selString substringFromIndex:1]);
        if ([self respondsToSelector:cleanedSelector]) {
            // dynamically add method for faster resolving
            Method newMethod = class_getInstanceMethod([self class], [inv selector]);
            IMP underscoreIMP = imp_implementationWithBlock(^(id _self) {
                return objc_msgSend(_self, cleanedSelector);
            });
            class_addMethod([self class], [inv selector], underscoreIMP, method_getTypeEncoding(newMethod));
            // invoke now
            inv.selector = cleanedSelector;
            [inv invokeWithTarget:self];
        }
    }else {
        [super forwardInvocation:inv];
    }
}
#endif

@end
