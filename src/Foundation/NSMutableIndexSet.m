#import "NSMutableIndexSet.h"

#import "import-private.h"


@implementation NSIndexSet( NSMutableCopying)

- (instancetype) mutableCopy
 {
    return( [[NSMutableIndexSet alloc] initWithIndexSet:self]);
}

@end

@implementation NSMutableIndexSet

- (void) addIndexesInRange:(NSRange) range
{
   _mulle__rangeset_insert( &_set, range, MulleObjCInstanceGetAllocator( self));
}


- (void) removeIndexesInRange:(NSRange) range
{
   _mulle__rangeset_remove( &_set, range, MulleObjCInstanceGetAllocator( self));
}


- (void) addIndex:(NSUInteger)index
{
   _mulle__rangeset_insert( &_set, NSMakeRange( index, 1), MulleObjCInstanceGetAllocator( self));
}


- (void) addIndexes:(NSIndexSet *) other
{
   _mulle__rangeset_insert_rangeset( &_set, &other->_set, MulleObjCInstanceGetAllocator( self));
}


- (void) removeIndex:(NSUInteger) index
{
   _mulle__rangeset_remove( &_set, NSMakeRange( index, 1), MulleObjCInstanceGetAllocator( self));
}


- (void) removeIndexes:(NSIndexSet*) other
{
   _mulle__rangeset_remove_rangeset( &_set, &other->_set, MulleObjCInstanceGetAllocator( self));
}


- (void) shiftIndexesStartingAtIndex:(NSUInteger) index
                                  by:(NSInteger) delta
{
   _mulle__rangeset_shift( &_set, index, delta, MulleObjCInstanceGetAllocator( self));
}


- (void) removeAllIndexes
{
   _mulle__rangeset_reset( &_set , MulleObjCInstanceGetAllocator( self));
}

- (id) copy
 {
    return( [[NSIndexSet alloc] initWithIndexSet:self]);
}

@end
