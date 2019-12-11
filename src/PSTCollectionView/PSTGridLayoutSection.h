//
//  PSTGridLayoutSection.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "import.h"

#import "CGGeometry.h"
#import "UIEdgeInsets.h"


@class PSTGridLayoutInfo, PSTGridLayoutRow, PSTGridLayoutItem;

@interface PSTGridLayoutSection : NSObject
{
    NSArray * _items;
    NSArray * _rows;
    BOOL _isValid;
}
@property ( retain) NSArray * items;
@property ( retain) NSArray * rows;
@property ( assign) CGFloat otherMargin;
@property ( assign) CGFloat beginMargin;
@property ( assign) CGFloat endMargin;
@property ( assign) CGFloat actualGap;
@property ( assign) CGFloat lastRowBeginMargin;
@property ( assign) CGFloat lastRowEndMargin;
@property ( assign) CGFloat lastRowActualGap;
@property ( assign) BOOL lastRowIncomplete;
@property ( assign) NSInteger itemsByRowCount;
@property ( assign) NSInteger indexOfIncompleteRow;

// fast path for equal-size items
@property ( assign) BOOL fixedItemSize;
@property ( assign) CGSize itemSize;
// depending on fixedItemSize, this either is a _ivar or queries items.
@property ( assign) NSInteger itemsCount;

@property ( assign) CGFloat verticalInterstice;
@property ( assign) CGFloat horizontalInterstice;
@property ( assign) UIEdgeInsets sectionMargins;

@property ( assign) CGRect frame;
@property ( assign) CGRect headerFrame;
@property ( assign) CGRect footerFrame;
@property ( assign) CGFloat headerDimension;
@property ( assign) CGFloat footerDimension;
@property ( assign) PSTGridLayoutInfo *layoutInfo;
@property ( retain) NSDictionary * rowAlignmentOptions;


//- (PSTGridLayoutSection *)copyFromLayoutInfo:(PSTGridLayoutInfo *)layoutInfo;

// Faster variant of invalidate/compute
- (void)recomputeFromIndex:(NSInteger)index;

// Invalidate layout. Destroys rows.
- (void)invalidate;

// Compute layout. Creates rows.
- (void)computeLayout;

- (PSTGridLayoutItem *)addItem;

- (PSTGridLayoutRow *)addRow;

// Copy snapshot of current object
- (PSTGridLayoutSection *)snapshot;

@end
