//
//  PSTGridLayoutSection.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTGridLayoutSection.h"
#import "PSTGridLayoutItem.h"
#import "PSTGridLayoutRow.h"
#import "PSTGridLayoutInfo.h"
#import "NSString+CGGeometry.h"


static inline CGFloat  MAX( CGFloat a, CGFloat b)
{
   return( a < b ? b : a);
}


@implementation PSTGridLayoutSection

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)init {
    if ((self = [super init])) {
        _items = [NSMutableArray new];
        _rows  = [NSMutableArray new];
    }
    return self;
}

- (NSString * )description {
    return [NSString stringWithFormat:@"<%@: %p itemCount:%ld frame:%@ rows:%@>", NSStringFromClass([self class]), self, (long)[self itemsCount], NSStringFromCGRect([self frame]), [self rows]];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)invalidate {
    _isValid = NO;
    [(NSMutableArray *) _rows removeAllObjects];
}

- (void)computeLayout {
    if (!_isValid) {
        NSAssert([[self rows] count] == 0, @"No rows shall be at this point.");

        // iterate over all items, turning them into rows.
        CGSize sectionSize = CGSizeZero;
        NSInteger rowIndex = 0;
        NSInteger itemIndex = 0;
        NSInteger itemsByRowCount = 0;
        CGFloat dimensionLeft = 0;
        PSTGridLayoutRow *row = nil;
        // get dimension and compensate for section margin
        CGFloat headerFooterDimension = [[self layoutInfo] dimension];
        CGFloat dimension = headerFooterDimension;

        if ([[self layoutInfo] horizontal]) {
            dimension -= [self sectionMargins].top + [self sectionMargins].bottom;
            [self setHeaderFrame:CGRectMake(sectionSize.width, 0, [self headerDimension], headerFooterDimension)];
            sectionSize.width += [self headerDimension] + [self sectionMargins].left;
        }else {
            dimension -= [self sectionMargins].left + [self sectionMargins].right;
            [self setHeaderFrame:CGRectMake(0, sectionSize.height, headerFooterDimension, [self headerDimension])];
            sectionSize.height += [self headerDimension] + [self sectionMargins].top;
        }

        CGFloat spacing = [[self layoutInfo] horizontal] ? [self verticalInterstice] : [self horizontalInterstice];

        do {
            BOOL finishCycle = itemIndex >= [self itemsCount];
            // TODO: fast path could even remove row creation and just calculate on the fly
            PSTGridLayoutItem *item = nil;
            if (!finishCycle) item = [self fixedItemSize] ? nil : [[self items] objectAtIndex:(NSUInteger)itemIndex];

            CGSize itemSize = [self fixedItemSize] ? [self itemSize] : [item itemFrame].size;
            CGFloat itemDimension = [[self layoutInfo] horizontal] ? itemSize.height : itemSize.width;
            // first item of each row does not add spacing
            if (itemsByRowCount > 0) itemDimension += spacing;
            if (dimensionLeft < itemDimension || finishCycle) {
                // finish current row
                if (row) {
                    // compensate last row
                    [self setItemsByRowCount:fmax(itemsByRowCount, [self itemsByRowCount])];
                    [row setItemCount:[self itemsByRowCount]]; // (nat) TODO CHECK!!

                    // if current row is done but there are still items left, increase the incomplete row counter
                    if (!finishCycle) [self setIndexOfIncompleteRow:rowIndex];

                    [row layoutRow];

                    if ([[self layoutInfo] horizontal]) {
                        [row setRowFrame:CGRectMake(sectionSize.width, [self sectionMargins].top, [row rowSize].width, [row rowSize].height)];
                        sectionSize.height = MAX([row rowSize].height, sectionSize.height);
                        sectionSize.width += [row rowSize].width + (finishCycle ? 0 : [self horizontalInterstice]);
                    }else {
                        [row setRowFrame:CGRectMake([self sectionMargins].left, sectionSize.height, [row rowSize].width, [row rowSize].height)];
                        sectionSize.height += [row rowSize].height + (finishCycle ? 0 : [self verticalInterstice]);
                        sectionSize.width = MAX([row rowSize].width, sectionSize.width);
                    }
                }
                // add new rows until the section is fully laid out
                if (!finishCycle) {
                    // create new row
                    [row setComplete:YES]; // finish up current row
                    row = [self addRow];
                    [row setFixedItemSize:[self fixedItemSize]];
                    [row setIndex:rowIndex];
                    [self setIndexOfIncompleteRow:rowIndex];
                    rowIndex++;
                    // convert an item from previous row to current, remove spacing for first item
                    if (itemsByRowCount > 0) itemDimension -= spacing;
                    dimensionLeft = dimension - itemDimension;
                    itemsByRowCount = 0;
                }
            }else {
                dimensionLeft -= itemDimension;
            }

            // add item on slow path
            if (item) [row addItem:item];

            itemIndex++;
            itemsByRowCount++;
        } while (itemIndex <= [self itemsCount]); // cycle once more to finish last row

        if ([[self layoutInfo] horizontal]) {
            sectionSize.width += [self sectionMargins].right;
            [self setFooterFrame:CGRectMake(sectionSize.width, 0, [self footerDimension], headerFooterDimension)];
            sectionSize.width += [self footerDimension];
        }else {
            sectionSize.height += [self sectionMargins].bottom;
            [self setFooterFrame:CGRectMake(0, sectionSize.height, headerFooterDimension, [self footerDimension])];
            sectionSize.height += [self footerDimension];
        }

        _frame = CGRectMake(0, 0, sectionSize.width, sectionSize.height);
        _isValid = YES;
    }
}

- (void)recomputeFromIndex:(NSInteger)index {
    // TODO: use index.
    [self invalidate];
    [self computeLayout];
}

- (PSTGridLayoutItem *)addItem {
    PSTGridLayoutItem *item = [PSTGridLayoutItem new];
    [item setSection:self];
    [(NSMutableArray *) _items addObject:item];
    return item;
}

- (PSTGridLayoutRow *)addRow {
    PSTGridLayoutRow *row = [PSTGridLayoutRow new];
    [row setSection:self];
    [(NSMutableArray *) _rows addObject:row];
    return row;
}

- (PSTGridLayoutSection *)snapshot {
    PSTGridLayoutSection *snapshotSection = [[PSTGridLayoutSection new] autorelease];
    [snapshotSection setItems:[[[self items] copy] autorelease]];
    [snapshotSection setRows:[[[self items] copy] autorelease]];
    [snapshotSection setVerticalInterstice:[self verticalInterstice]];
    [snapshotSection setHorizontalInterstice:[self horizontalInterstice]];
    [snapshotSection setSectionMargins:[self sectionMargins]];
    [snapshotSection setFrame:[self frame]];
    [snapshotSection setHeaderFrame:[self headerFrame]];
    [snapshotSection setFooterFrame:[self footerFrame]];
    [snapshotSection setHeaderDimension:[self headerDimension]];
    [snapshotSection setFooterDimension:[self footerDimension]];
    [snapshotSection setLayoutInfo:[self layoutInfo]];
    [snapshotSection setRowAlignmentOptions:[self rowAlignmentOptions]];
    [snapshotSection setFixedItemSize:[self fixedItemSize]];
    [snapshotSection setItemSize:[self itemSize]];
    [snapshotSection setItemsCount:[self itemsCount]];
    [snapshotSection setOtherMargin:[self otherMargin]];
    [snapshotSection setBeginMargin:[self beginMargin]];
    [snapshotSection setEndMargin:[self endMargin]];
    [snapshotSection setActualGap:[self actualGap]];
    [snapshotSection setLastRowBeginMargin:[self lastRowBeginMargin]];
    [snapshotSection setLastRowEndMargin:[self lastRowEndMargin]];
    [snapshotSection setLastRowActualGap:[self lastRowActualGap]];
    [snapshotSection setLastRowIncomplete:[self lastRowIncomplete]];
    [snapshotSection setItemsByRowCount:[self itemsByRowCount]];
    [snapshotSection setIndexOfIncompleteRow:[self indexOfIncompleteRow]];
    return snapshotSection;
}

- (NSInteger)itemsCount {
    return [self fixedItemSize] ? _itemsCount : (NSInteger) [[self items] count];
}

@end
