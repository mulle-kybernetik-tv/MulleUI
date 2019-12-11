//
//  PSTCollectionViewCell.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewCommon.h"

@class PSTCollectionViewLayout, PSTCollectionView, PSTCollectionViewLayoutAttributes;

// Used by PSTCollectionView for external variables.
// (We need to keep the total class size equal to the UICollectionView variant)
// TODO: (nat) move theses to PSTCollectionView
@interface PSTCollectionViewExt : NSObject

@property ( assign) id<PSTCollectionViewDelegate> collectionViewDelegate;
@property ( retain) PSTCollectionViewLayout *nibLayout;
@property ( retain) NSDictionary * nibCellsExternalObjects;
@property ( retain) NSDictionary * supplementaryViewsExternalObjects;
@property ( retain) NSIndexPath *touchingIndexPath;
@property ( retain) NSIndexPath *currentIndexPath;

@end


@interface PSTCollectionReusableView : UIView
{ 
    PSTCollectionViewLayoutAttributes *_layoutAttributes;
    NSString * _reuseIdentifier;
    PSTCollectionView *_collectionView;
    struct {
        unsigned int inUpdateAnimation : 1;
    }_reusableViewFlags;
}
@property ( copy) NSString * reuseIdentifier;
@property ( assign) PSTCollectionView *collectionView;
@property ( retain) PSTCollectionViewLayoutAttributes *layoutAttributes;

// Override in subclasses. Called before instance is returned to the reuse queue.
- (void)prepareForReuse;

// Apply layout attributes on cell.
- (void)applyLayoutAttributes:(PSTCollectionViewLayoutAttributes *)layoutAttributes;
- (void)willTransitionFromLayout:(PSTCollectionViewLayout *)oldLayout toLayout:(PSTCollectionViewLayout *)newLayout;
- (void)didTransitionFromLayout:(PSTCollectionViewLayout *)oldLayout toLayout:(PSTCollectionViewLayout *)newLayout;

- (NSComparisonResult) compare:(id) other;

@end

@interface PSTCollectionReusableView (Internal)
@property ( assign) PSTCollectionView *collectionView;
@property ( copy) NSString * reuseIdentifier;
@property ( retain, readonly) PSTCollectionViewLayoutAttributes *layoutAttributes;
@end


@interface PSTCollectionViewCell : PSTCollectionReusableView
{
    UIView *_contentView;
    UIView *_backgroundView;
    UIView *_selectedBackgroundView;
//    UILongPressGestureRecognizer *_menuGesture;
    id _selectionSegueTemplate;
    id _highlightingSupport;
    struct {
        unsigned int selected : 1;
        unsigned int highlighted : 1;
        unsigned int showingMenu : 1;
        unsigned int clearSelectionWhenMenuDisappears : 1;
        unsigned int waitingForSelectionAnimationHalfwayPoint : 1;
    }_collectionCellFlags;
    BOOL _selected;
    BOOL _highlighted;
}

@property ( readonly) UIView *contentView; // add custom subviews to the cell's contentView

// Cells become highlighted when the user touches them.
// The selected state is toggled when the user lifts up from a highlighted cell.
// Override these methods to provide custom UI for a selected or highlighted state.
// The collection view may call the setters inside an animation block.
@property ( getter=isSelected) BOOL selected;
@property ( getter=isHighlighted) BOOL highlighted;

// The background view is a subview behind all other views.
// If selectedBackgroundView is different than backgroundView, it will be placed above the background view and animated in on selection.
@property ( retain) UIView *backgroundView;
@property ( retain) UIView *selectedBackgroundView;

@end
