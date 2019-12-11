//
//  PSTCollectionViewData.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewData.h"
#import "PSTCollectionView.h"
#import "NSIndexPath.h"
#import "NSIndexPath+PSTCollectionViewAdditions.h"

@implementation PSTCollectionViewData

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithCollectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout *)layout {
    if ((self = [super init])) {
        _collectionView = collectionView;
        _layout = layout;
    }
    return self;
}

- (void)dealloc {
    free(_sectionItemCounts);
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p numItems:%ld numSections:%ld>", NSStringFromClass([self class]), self, (long)[self numberOfItems], (long) [self numberOfSections]];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)invalidate {
    _collectionViewDataFlags.itemCountsAreValid = NO;
    _collectionViewDataFlags.layoutIsPrepared = NO;
    _validLayoutRect = CGRectNull;  // don't set CGRectZero in case of _contentSize=CGSizeZero
}

- (CGRect)collectionViewContentRect {
    return (CGRect){.size=_contentSize};
}

- (void)validateLayoutInRect:(CGRect)rect {
    NSMutableArray                     *attributes;
    PSTCollectionViewLayoutAttributes  *attr;

    [self validateItemCounts];
    [self prepareToLoadData];

    // TODO: check if we need to fetch data from layout
    if (!CGRectEqualToRect(_validLayoutRect, rect)) {
        _validLayoutRect = rect;
        // we only want cell layoutAttributes & supplementaryView layoutAttributes
        attributes = [NSMutableArray array];
        for( attr in [[self layout] layoutAttributesForElementsInRect:rect])
        {
           if( [attr isKindOfClass:[PSTCollectionViewLayoutAttributes class]] &&
                    ([attr isCell] ||
                            [attr isSupplementaryView] ||
                            [attr isDecorationView]))
           {
               [attributes addObject:attr];
           }
        }
        [self setCachedLayoutAttributes:attributes];
    }
}

- (NSInteger)numberOfItems {
    [self validateItemCounts];
    return _numItems;
}

- (NSInteger)numberOfItemsBeforeSection:(NSInteger)section {
    [self validateItemCounts];

    assert(section < _numSections);

    NSInteger returnCount = 0;
    for (int i = 0; i < section; i++) {
        returnCount += _sectionItemCounts[i];
    }

    return returnCount;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    [self validateItemCounts];
    if (section >= _numSections || section < 0) {
        // In case of inconsistency returns the 'less harmful' amount of items. Throwing an exception here potentially
        // causes exceptions when data is consistent. Deleting sections is one of the parts sensitive to this.
        // All checks via assertions are done on CollectionView animation methods, specially 'endAnimations'.
        return 0;
        //@throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Section %d out of range: 0...%d", section, _numSections] userInfo:nil];
    }

    NSInteger numberOfItemsInSection = 0;
    if (_sectionItemCounts) {
        numberOfItemsInSection = _sectionItemCounts[section];
    }
    return numberOfItemsInSection;
}

- (NSInteger)numberOfSections {
    [self validateItemCounts];
    return _numSections;
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectZero;
}

- (NSIndexPath *)indexPathForItemAtGlobalIndex:(NSInteger)index {
    [self validateItemCounts];

    assert(index < _numItems);

    NSInteger section = 0;
    NSInteger countItems = 0;
    for (section = 0; section < _numSections; section++) {
        NSInteger countIncludingThisSection = countItems + _sectionItemCounts[section];
        if (countIncludingThisSection > index) break;
        countItems = countIncludingThisSection;
    }

    NSInteger item = index - countItems;

    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (NSUInteger)globalIndexForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger offset = [self numberOfItemsBeforeSection:[indexPath section]] + [indexPath item];
    return (NSUInteger)offset;
}

- (BOOL)layoutIsPrepared {
    return _collectionViewDataFlags.layoutIsPrepared;
}

- (void)setLayoutIsPrepared:(BOOL)layoutIsPrepared {
    _collectionViewDataFlags.layoutIsPrepared = (unsigned int)layoutIsPrepared;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetch Layout Attributes

- (NSArray * )layoutAttributesForElementsInRect:(CGRect)rect {
    [self validateLayoutInRect:rect];
    return [self cachedLayoutAttributes];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

// ensure item count is valid and loaded
- (void)validateItemCounts {
    if (!_collectionViewDataFlags.itemCountsAreValid) {
        [self updateItemCounts];
    }
}

// query dataSource for new data
- (void)updateItemCounts {
    // query how many sections there will be
    _numSections = 1;
    if ([[[self collectionView] dataSource] respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        _numSections = [[[self collectionView] dataSource] numberOfSectionsInCollectionView:[self collectionView]];
    }
    if (_numSections <= 0) { // early bail-out
        _numItems = 0;
        free(_sectionItemCounts);
        _sectionItemCounts = 0;
        _collectionViewDataFlags.itemCountsAreValid = YES;
        return;
    }
    // allocate space
    if (!_sectionItemCounts) {
        _sectionItemCounts = malloc((size_t)_numSections * sizeof(NSInteger));
    }else {
        _sectionItemCounts = realloc(_sectionItemCounts, (size_t)_numSections * sizeof(NSInteger));
    }

    // query cells per section
    _numItems = 0;
    for (NSInteger i = 0; i < _numSections; i++) {
        NSInteger cellCount = [[[self collectionView] dataSource] collectionView:[self collectionView] numberOfItemsInSection:i];
        _sectionItemCounts[i] = cellCount;
        _numItems += cellCount;
    }

    _collectionViewDataFlags.itemCountsAreValid = YES;
}

- (void)prepareToLoadData {
    if (![self layoutIsPrepared]) {
        [[self layout] prepareLayout];
        _contentSize = [[self layout] collectionViewContentSize];
        _layoutIsPrepared = YES;
    }
}

@end
