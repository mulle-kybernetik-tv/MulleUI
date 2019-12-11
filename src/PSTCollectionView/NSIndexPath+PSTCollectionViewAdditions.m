//
//  NSIndexPath+PSTCollectionViewAdditions.m
//  PSTCollectionView
//
//  Copyright (c) 2013 Peter Steinberger. All rights reserved.
//

#import "NSIndexPath+PSTCollectionViewAdditions.h"

@implementation NSIndexPath (PSTCollectionViewAdditions)

// Simple NSIndexPath addition to allow using "item" instead of "row".
+ (NSIndexPath *) indexPathForItem:(NSInteger) item 
                         inSection:(NSInteger) section 
{
   NSUInteger   indexes[ 2];

   indexes[ 0] = (NSUInteger) section;
   indexes[ 1] = (NSUInteger) item;

   return( [NSIndexPath indexPathWithIndexes:indexes
                                      length:2]);;
}

- (NSInteger) item 
{
   return( (NSInteger) [self indexAtPosition:1]);
}

- (NSInteger) section
{
   return( (NSInteger) [self indexAtPosition:0]);
}

- (NSInteger) row
{
   return( (NSInteger) [self indexAtPosition:1]);
}


@end
