#import "NSIndexSet.h"

#import "import-private.h"


@implementation NSIndexSet

+ (instancetype) indexSet
{
   return( [[NSIndexSet new] autorelease]);
}


+ (instancetype) indexSetWithIndex:(NSUInteger)index
{
   NSRange   range;

   range = NSMakeRange( index, 1);
   return( [[[self alloc] mulleInitWithIndexesInRanges:&range
                                                length:1] autorelease]);
}


+ (instancetype) indexSetWithIndexesInRange:(NSRange) range
{
    return( [[[self alloc] mulleInitWithIndexesInRanges:&range
                                                 length:1] autorelease]);
}


- (instancetype) initWithIndex:(NSUInteger) index
{
   NSRange   range;

   range = NSMakeRange( index, 1);
   return( [self mulleInitWithIndexesInRanges:&range
                                       length:1]);
}


- (instancetype) initWithIndexesInRange:(NSRange) range
{
   return( [self mulleInitWithIndexesInRanges:&range
                                       length:1]);
}


- (instancetype) mulleInitWithIndexesInRanges:(NSRange *) ranges
                                       length:(NSUInteger) n
{
   struct mulle_allocator   *allocator;

   allocator = MulleObjCInstanceGetAllocator( self);
   _mulle__rangeset_init( &_set, n, allocator);
   _mulle__rangeset_insert_ranges( &_set, ranges, n, allocator);
   return( self);
}


- (instancetype) initWithIndexSet:(NSIndexSet *) other
{
   if( other)
      self = [self mulleInitWithIndexesInRanges:other->_set._ranges
                                         length:other->_set._length];
   return( self);
}


- (BOOL) containsIndex:(NSUInteger) anIndex
{
   return( _mulle__rangeset_contains( &_set, NSMakeRange( anIndex, 1)));
}


- (BOOL) containsIndexes:(NSIndexSet *) other
{
   NSRange      *p;
   NSRange      *sentinel;
   NSUInteger   n;

   n        = _mulle__rangeset_get_rangecount( &other->_set);
   p        = other->_set._ranges;
   sentinel = &p[ n];
   while( p < sentinel)
   {
      if( ! _mulle__rangeset_contains( &_set, *p))
         return( NO);
      ++p;
   }
   return( YES);
}


- (BOOL) containsIndexesInRange:(NSRange) range
{
   return( _mulle__rangeset_contains( &_set, range));
}


- (BOOL) intersectsIndexesInRange:(NSRange) range
{
   return( _mulle__rangeset_intersects( &_set, range));
}


- (NSUInteger) count
{
   return( _mulle__rangeset_sum_lengths( &_set));
}


- (NSUInteger) countOfIndexesInRange:(NSRange) range
{
   return( _mulle__rangeset_sum_lengths_range( &_set, range));
}


- (NSUInteger) firstIndex
{
   return( _mulle__rangeset_get_first( &_set));
}


- (NSUInteger) lastIndex
{
   return( _mulle__rangeset_get_first( &_set));
}


- (BOOL) isEqual:(id) other
{
   if (self == other)
      return( YES);

   if( ! [other isKindOfClass:[NSIndexSet class]])
      return( NO);

   return( [self isEqualToIndexSet:other]);
}


- (BOOL) isEqualToIndexSet:(NSIndexSet *) other
{
   unsigned int   length;
   unsigned int   other_length;
   NSRange        *p;
   NSRange        *q;
   NSRange        *sentinel;

   assert( ! [other isKindOfClass:[NSIndexSet class]]);

   if( self == other)
      return YES;

   length       = _mulle__rangeset_get_rangecount( &_set);
   other_length = _mulle__rangeset_get_rangecount( &other->_set);
   if( length != other_length)
      return( NO);

   p        = _set._ranges;
   q        = other->_set._ranges;
   sentinel = &p[ length];
   while( p < sentinel)
   {
      if( p->location != q->location || p->length != q->length)
         return( NO);
      ++p;
      ++q;
   }
   return( YES);
}

- (NSUInteger) indexLessThanIndex:(NSUInteger) index
{
   return( _mulle__rangeset_search( &_set, index, mulle_rangeset_less_than));
}


- (NSUInteger) indexLessThanOrEqualToIndex:(NSUInteger) index
{
   return( _mulle__rangeset_search( &_set, index, mulle_rangeset_less_than_or_equal));
}


- (NSUInteger) indexGreaterThanIndex:(NSUInteger) index
{
   return( _mulle__rangeset_search( &_set, index, mulle_rangeset_greater_than));
}


- (NSUInteger) indexGreaterThanOrEqualToIndex:(NSUInteger) index
{
   return( _mulle__rangeset_search( &_set, index, mulle_rangeset_greater_than_or_equal));
}


- (NSUInteger) getIndexes:(NSUInteger *) buf
                 maxCount:(NSUInteger) maxCount
             inIndexRange:(NSRangePointer) indexRange
{
   NSRange      all;
   NSRange      intersect;
   NSRange      *found;
   NSRange      *p;
   NSUInteger   *q;
   NSRange      *p_sentinel;
   NSUInteger   *q_sentinel;
   NSUInteger   sentinel;

   if( ! indexRange)
   {
      all        = NSMakeRange( 0, mulle_range_max);
      indexRange = &all;
   }

   found = mulle_range_intersects_bsearch( _set._ranges, _set._length, *indexRange);
   if( ! found)
   {
      *indexRange = NSMakeRange( 0, 0);
      return( 0);
   }

   // have first range of the intersection in found
   p          = found;
   p_sentinel = &_set._ranges[ _set._length];
   q          = buf;
   q_sentinel = &q[ maxCount];

   while( p < p_sentinel)
   {
      intersect = mulle_range_intersect( *p, *indexRange);
      sentinel  = mulle_range_get_end( intersect);
      for(;;)
      {
         // buffer exhausted ?
         if( q >= q_sentinel)
         {
            // figure out how much more we have, and store it in indexRange
            if( indexRange != &all)
            {
               *indexRange = intersect;
               // add remaining
               while( ++p < p_sentinel)
               {
                  intersect = mulle_range_intersect( *p, *indexRange);
                  if( ! intersect.length)
                     break;

                  *indexRange = mulle_range_union( *indexRange, intersect);
               }
            }
            return( maxCount);
         }

         if( ! intersect.length)
            break;
         *q++ = intersect.location++;
         --intersect.length;
      }
      ++p;
   }

   // exhausted
   *indexRange = NSMakeRange( 0, 0);
   return( q - buf);
}

@end
