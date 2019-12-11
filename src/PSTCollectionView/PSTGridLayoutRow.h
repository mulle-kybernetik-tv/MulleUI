//
//  PSTGridLayoutRow.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "import.h"

@class PSTGridLayoutSection, PSTGridLayoutItem;

@interface PSTGridLayoutRow : NSObject
{
    NSMutableArray * _items;
    BOOL _isValid;
    int _verticalAlignement;
    int _horizontalAlignement;
}

@property ( assign) PSTGridLayoutSection *section;
@property ( retain) NSArray * items;
@property ( assign) CGSize rowSize;
@property ( assign) CGRect rowFrame;
@property ( assign) NSInteger index;
@property ( assign) BOOL complete;
@property ( assign) BOOL fixedItemSize;

// @steipete addition for row-fastPath
@property ( assign) NSInteger itemCount;

//- (PSTGridLayoutRow *)copyFromSection:(PSTGridLayoutSection *)section; // ???

// Add new item to items array.
- (void)addItem:(PSTGridLayoutItem *)item;

// Layout current row (if invalid)
- (void)layoutRow;

// @steipete: Helper to save code in PSTCollectionViewFlowLayout.
// Returns the item rects when fixedItemSize is enabled.
- (NSArray * )itemRects;

//  Set current row frame invalid.
- (void)invalidate;

// Copy a snapshot of the current row data
- (PSTGridLayoutRow *)snapshot;

@end
