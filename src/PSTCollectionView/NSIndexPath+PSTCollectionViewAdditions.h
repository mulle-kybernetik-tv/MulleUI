//
//  NSIndexPath+PSTCollectionViewAdditions.h
//  PSTCollectionView
//
//  Copyright (c) 2013 Peter Steinberger. All rights reserved.
//

#import "NSIndexPath.h"


@interface NSIndexPath (PSTCollectionViewAdditions)

// NSInteger as defined by 
// https://developer.apple.com/documentation/foundation/nsindexpath/1526053-indexpathforitem?language=objc
+ (NSIndexPath *) indexPathForItem:(NSInteger) item 
                         inSection:(NSInteger) section;
- (NSInteger) item;
- (NSInteger) section;
- (NSInteger) row;

@end

