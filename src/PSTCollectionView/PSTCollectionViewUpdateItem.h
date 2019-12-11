//
//  PSTCollectionViewUpdateItem.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//  Contributed by Sergey Gavrilyuk.
//

#import "import.h"

@class NSIndexPath;

enum 
{
    PSTCollectionUpdateActionInsert,
    PSTCollectionUpdateActionDelete,
    PSTCollectionUpdateActionReload,
    PSTCollectionUpdateActionMove,
    PSTCollectionUpdateActionNone
};

typedef NSInteger   PSTCollectionUpdateAction;

@interface PSTCollectionViewUpdateItem : NSObject
{
   NSIndexPath                *_initialIndexPath;
   NSIndexPath                *_finalIndexPath;
   PSTCollectionUpdateAction  _updateAction;
   id _gap;
}

@property( readonly, assign) PSTCollectionUpdateAction updateAction;

- (NSIndexPath *) indexPathBeforeUpdate; // nil for PSTCollectionUpdateActionInsert
- (NSIndexPath *) indexPathAfterUpdate;  // nil for PSTCollectionUpdateActionDelete


- (id)initWithInitialIndexPath:(NSIndexPath *)arg1
        finalIndexPath:(NSIndexPath *)arg2
        updateAction:(PSTCollectionUpdateAction)arg3;

- (id)initWithAction:(PSTCollectionUpdateAction)arg1
        forIndexPath:(NSIndexPath *)indexPath;

- (id)initWithOldIndexPath:(NSIndexPath *)arg1 newIndexPath:(NSIndexPath *)arg2;

- (PSTCollectionUpdateAction)updateAction;

- (NSComparisonResult)compareIndexPaths:(PSTCollectionViewUpdateItem *)otherItem;

- (NSComparisonResult)inverseCompareIndexPaths:(PSTCollectionViewUpdateItem *)otherItem;

@end
