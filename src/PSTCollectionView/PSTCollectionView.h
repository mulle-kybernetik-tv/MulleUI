//
//  PSTCollectionView.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewLayout.h"
#import "PSTCollectionViewFlowLayout.h"
#import "PSTCollectionViewCell.h"
#import "PSTCollectionViewController.h"
#import "PSTCollectionViewUpdateItem.h"

@class PSTCollectionViewController;
@class PSTCollectionViewData;
@class UITouch;
@class NSIndexSet;


typedef NS_OPTIONS(NSUInteger, PSTCollectionViewScrollPosition) {
    PSTCollectionViewScrollPositionNone                 = 0,

    // The vertical positions are mutually exclusive to each other, but are bitwise or-able with the horizontal scroll positions.
    // Combining positions from the same grouping (horizontal or vertical) will result in an NSInvalidArgumentException.
    PSTCollectionViewScrollPositionTop                  = 1 << 0,
    PSTCollectionViewScrollPositionCenteredVertically   = 1 << 1,
    PSTCollectionViewScrollPositionBottom               = 1 << 2,

    // Likewise, the horizontal positions are mutually exclusive to each other.
    PSTCollectionViewScrollPositionLeft                 = 1 << 3,
    PSTCollectionViewScrollPositionCenteredHorizontally = 1 << 4,
    PSTCollectionViewScrollPositionRight                = 1 << 5
};

typedef NS_ENUM(NSUInteger, PSTCollectionElementCategory) {
    PSTCollectionElementCategoryCell,
    PSTCollectionElementCategorySupplementaryView,
    PSTCollectionElementCategoryDecorationView
};

// Define the `PSTCollectionViewDisableForwardToUICollectionViewSentinel` to disable the automatic forwarding to UICollectionView on iOS 6+. (Copy below line into your AppDelegate.m)
//@interface PSTCollectionViewDisableForwardToUICollectionViewSentinel : NSObject @end @implementation PSTCollectionViewDisableForwardToUICollectionViewSentinel @end

// API-compatible replacement for UICollectionView.
// Works on iOS 4.3 upwards (including iOS 6).
@interface PSTCollectionView : UIScrollView <UIScrollViewDelegate>
{
    // ivar layout needs to EQUAL to UICollectionView.
    PSTCollectionViewLayout           *_layout;
    id<PSTCollectionViewDataSource>   _dataSource;
    UIView                            *_backgroundView;
    NSMutableSet                      *_indexPathsForSelectedItems;
    NSMutableDictionary               *_cellReuseQueues;
    NSMutableDictionary               *_supplementaryViewReuseQueues;
    NSMutableDictionary               *_decorationViewReuseQueues;
    NSMutableSet                      *_indexPathsForHighlightedItems;
    int                               _reloadingSuspendedCount;
    PSTCollectionReusableView         *_firstResponderView;
    UIView                            *_newContentView;
    int                               _firstResponderViewType;
    NSString *                     _firstResponderViewKind;
    NSIndexPath                       *_firstResponderIndexPath;
    NSMutableDictionary               *_visibleViewsDict;
    NSIndexPath                       *_pendingSelectionIndexPath;
    NSMutableSet                      * _pendingDeselectionIndexPaths;
    PSTCollectionViewData             *_collectionViewData;
    id                                _update;
    CGRect                            _visibleBoundRects;
    CGRect                            _preRotationBounds;
    CGPoint                           _rotationBoundsOffset;
    int                               _rotationAnimationCount;
    int                               _updateCount;
    NSMutableArray                    *_insertItems;
    NSMutableArray                    *_deleteItems;
    NSMutableArray                    *_reloadItems;
    NSMutableArray                    *_moveItems;
    NSMutableArray                    *_originalInsertItems;
    NSMutableArray                    *_originalDeleteItems;
    UITouch                           *_currentTouch;

    IMP                               _updateCompletionHandler;

    NSMutableDictionary               *_cellClassDict;
    NSMutableDictionary               *_cellNibDict;
    NSMutableDictionary               *_supplementaryViewClassDict;
    NSMutableDictionary               *_supplementaryViewNibDict;
    NSMutableDictionary               *_cellNibExternalObjectsTables;
    NSMutableDictionary               *_supplementaryViewNibExternalObjectsTables;
    struct {
        unsigned int delegateShouldHighlightItemAtIndexPath : 1;
        unsigned int delegateDidHighlightItemAtIndexPath : 1;
        unsigned int delegateDidUnhighlightItemAtIndexPath : 1;
        unsigned int delegateShouldSelectItemAtIndexPath : 1;
        unsigned int delegateShouldDeselectItemAtIndexPath : 1;
        unsigned int delegateDidSelectItemAtIndexPath : 1;
        unsigned int delegateDidDeselectItemAtIndexPath : 1;
        unsigned int delegateSupportsMenus : 1;
        unsigned int delegateDidEndDisplayingCell : 1;
        unsigned int delegateDidEndDisplayingSupplementaryView : 1;
        unsigned int dataSourceNumberOfSections : 1;
        unsigned int dataSourceViewForSupplementaryElement : 1;
        unsigned int reloadSkippedDuringSuspension : 1;
        unsigned int scheduledUpdateVisibleCells : 1;
        unsigned int scheduledUpdateVisibleCellLayoutAttributes : 1;
        unsigned int allowsSelection : 1;
        unsigned int allowsMultipleSelection : 1;
        unsigned int updating : 1;
        unsigned int fadeCellsForBoundsChange : 1;
        unsigned int updatingLayout : 1;
        unsigned int needsReload : 1;
        unsigned int reloading : 1;
        unsigned int skipLayoutDuringSnapshotting : 1;
        unsigned int layoutInvalidatedSinceLastCellUpdate : 1;
        unsigned int doneFirstLayout : 1;
    } _collectionViewFlags;
    CGPoint                          _lastLayoutOffset;
}

@property ( retain) PSTCollectionViewData *collectionViewData;
@property ( retain, readonly) PSTCollectionViewExt *extVars;
@property ( readonly) id currentUpdate;
@property ( readonly) NSDictionary * visibleViewsDict;
@property ( assign) CGRect visibleBoundRects;

@property ( assign) IBOutlet id<PSTCollectionViewDelegate> delegate;
@property ( assign) IBOutlet id<PSTCollectionViewDataSource> dataSource;
@property ( retain) UIView *backgroundView; // will be automatically resized to track the size of the collection view and placed behind all cells and supplementary views.

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(PSTCollectionViewLayout *)layout; // the designated initializer

// For each reuse identifier that the collection view will use, register either a class or a nib from which to instantiate a cell.
// If a nib is registered, it must contain exactly 1 top level object which is a PSTCollectionViewCell.
// If a class is registered, it will be instantiated via alloc/initWithFrame:
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString * )identifier;

- (void)registerClass:(Class)viewClass forSupplementaryViewOfKind:(NSString * )elementKind withReuseIdentifier:(NSString * )identifier;

//- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString * )identifier;

// TODO: implement!
//- (void)registerNib:(UINib *)nib forSupplementaryViewOfKind:(NSString * )kind withReuseIdentifier:(NSString * )identifier;

- (id)dequeueReusableCellWithReuseIdentifier:(NSString * )identifier forIndexPath:(NSIndexPath *)indexPath;

- (id)dequeueReusableSupplementaryViewOfKind:(NSString * )elementKind withReuseIdentifier:(NSString * )identifier forIndexPath:(NSIndexPath *)indexPath;

// These properties control whether items can be selected, and if so, whether multiple items can be simultaneously selected.
@property (nonatomic) BOOL allowsSelection; // default is YES
@property (nonatomic) BOOL allowsMultipleSelection; // default is NO

- (NSArray * )indexPathsForSelectedItems; // returns nil or an array of selected index paths
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(PSTCollectionViewScrollPosition)scrollPosition;

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (void)reloadData; // discard the dataSource and delegate data and requery as necessary

- (void)setCollectionViewLayout:(PSTCollectionViewLayout *)layout animated:(BOOL)animated; // transition from one layout to another

- (PSTCollectionViewLayout *) collectionViewLayout;
- (void) setCollectionViewLayout:(PSTCollectionViewLayout *) layout;

// Information about the current state of the collection view.

- (NSInteger)numberOfSections;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString * )kind atIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;

- (NSIndexPath *)indexPathForCell:(PSTCollectionViewCell *)cell;

- (PSTCollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray * )visibleCells;

- (NSArray * )indexPathsForVisibleItems;

// Interacting with the collection view.

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(PSTCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

// These methods allow dynamic modification of the current set of items in the collection view
- (void)insertSections:(NSIndexSet *)sections;
- (void)deleteSections:(NSIndexSet *)sections;
- (void)reloadSections:(NSIndexSet *)sections;
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;
- (void)insertItemsAtIndexPaths:(NSArray * )indexPaths;
- (void)deleteItemsAtIndexPaths:(NSArray * )indexPaths;
- (void)reloadItemsAtIndexPaths:(NSArray * )indexPaths;
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

@end

// To dynamically switch between PSTCollectionView and UICollectionView, use the PSUICollectionView* classes.
#define PSUICollectionView PSUICollectionView_
#define PSUICollectionViewCell PSUICollectionViewCell_
#define PSUICollectionReusableView PSUICollectionReusableView_
#define PSUICollectionViewDelegate PSTCollectionViewDelegate
#define PSUICollectionViewDataSource PSTCollectionViewDataSource
#define PSUICollectionViewLayout PSUICollectionViewLayout_
#define PSUICollectionViewFlowLayout PSUICollectionViewFlowLayout_
#define PSUICollectionViewDelegateFlowLayout PSTCollectionViewDelegateFlowLayout
#define PSUICollectionViewLayoutAttributes PSUICollectionViewLayoutAttributes_
#define PSUICollectionViewController PSUICollectionViewController_

@interface PSUICollectionView_ : PSTCollectionView @end
@interface PSUICollectionViewCell_ : PSTCollectionViewCell @end
@interface PSUICollectionReusableView_ : PSTCollectionReusableView @end
@interface PSUICollectionViewLayout_ : PSTCollectionViewLayout @end
@interface PSUICollectionViewFlowLayout_ : PSTCollectionViewFlowLayout @end
@protocol PSUICollectionViewDelegateFlowLayout_ <PSTCollectionViewDelegateFlowLayout> @end
@interface PSUICollectionViewLayoutAttributes_ : PSTCollectionViewLayoutAttributes @end
@interface PSUICollectionViewController_ : PSTCollectionViewController <PSUICollectionViewDelegate, PSUICollectionViewDataSource> @end
