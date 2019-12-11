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
   _mulle_rangeset_insert( &_set, range, MulleObjCObjectGetAllocator( self));
}


- (void) removeIndexesInRange:(NSRange) range
{
   _mulle_rangeset_remove( &_set, range, MulleObjCObjectGetAllocator( self));
}


- (void) addIndex:(NSUInteger)index
{
   _mulle_rangeset_insert( &_set, NSMakeRange( index, 1), MulleObjCObjectGetAllocator( self));
}


- (void) addIndexes:(NSIndexSet *) other
{
   _mulle_rangeset_insert_rangeset( &_set, &other->_set, MulleObjCObjectGetAllocator( self));
}


- (void) removeIndex:(NSUInteger) index
{
   _mulle_rangeset_remove( &_set, NSMakeRange( index, 1), MulleObjCObjectGetAllocator( self));
}


- (void) removeIndexes:(NSIndexSet*) other
{
   _mulle_rangeset_remove_rangeset( &_set, &other->_set, MulleObjCObjectGetAllocator( self));
}


- (void) shiftIndexesStartingAtIndex:(NSUInteger) index
                                  by:(NSInteger) delta
{
   _mulle_rangeset_shift( &_set, index, delta, MulleObjCObjectGetAllocator( self));
}


- (void) removeAllIndexes
{
   _mulle_rangeset_reset( &_set , MulleObjCObjectGetAllocator( self));
}

- (id) copy
 {
    return( [[NSIndexSet alloc] initWithIndexSet:self]);
}

@end
