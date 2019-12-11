//******************************************************************************
//
// Copyright (c) Microsoft. All rights reserved.
//
// This code is licensed under the MIT License (MIT).
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************

#import "NSIndexPath.h"

#import "import-private.h"

#include <string.h>


@implementation NSIndexPath

+ (NSIndexPath *) indexPathWithIndex:(NSUInteger) index
{
    return( [[[self alloc] initWithIndexes:&index
                                   length:1] autorelease]);
}


+ (NSIndexPath *) indexPathWithIndexes:(NSUInteger*) indexes
                                length:(NSUInteger) length
{
    return( [[[self alloc] initWithIndexes:indexes
                                    length:length] autorelease]);
}


- (instancetype) init
{
    return( [self initWithIndexes:NULL
                          length:0]);
}


- (instancetype) initWithIndex:(NSUInteger) index
{
    return( [self initWithIndexes:&index
                           length:1]);
}


- (instancetype) initWithIndexes:(NSUInteger *) indexes
                          length:(NSUInteger) length
{
   assert( ! length || indexes);

   if( self = [super init])
   {
      if( length)
      {
         _indexes = MulleObjCObjectAllocateNonZeroedMemory( self, length * sizeof( NSUInteger));
         _length  = length;
         memcpy( _indexes, indexes, length * sizeof( NSUInteger));
      }
   }

   return( self);
}

- (instancetype) mulleInitWithIndexes:(NSUInteger *) indexes
                               length:(NSUInteger) length
                             andIndex:(NSUInteger) index
{
   assert( ! length || indexes);

   if( self = [super init])
   {
      _length  = length + 1;
      _indexes = MulleObjCObjectAllocateNonZeroedMemory( self, _length * sizeof( NSUInteger));
      memcpy( _indexes, indexes, length * sizeof( NSUInteger));
      _indexes[ length] = index;
   }

   return( self);
}


- (BOOL) isEqual:(id) other
{
   NSIndexPath  *otherPath;
   NSUInteger   otherLength;

   if( ! [other isKindOfClass:[NSIndexPath class]])
      return( NO);
   otherPath = other;

   otherLength = [other length];
   if( otherLength != _length)
      return( NO);

   return( memcmp( _indexes, otherPath->_indexes, otherLength * sizeof( NSUInteger)) == 0);
}


- (NSUInteger) indexAtPosition:(NSUInteger) position
{
   return( position < _length ? _indexes[ position] : NSNotFound);
}


- (void) getIndexes:(NSUInteger*) indexes
{
   memcpy( indexes, _indexes, _length * sizeof( NSUInteger));
}


- (NSIndexPath *) indexPathByAddingIndex:(NSUInteger) newIndex
{
   assert( newIndex != NSNotFound);
   return( [[[NSIndexPath alloc] mulleInitWithIndexes:_indexes
                                               length:_length
                                             andIndex:newIndex]
                                                         autorelease]);
}


- (NSIndexPath *) indexPathByRemovingLastIndex
{
   if( _length)
      return( [NSIndexPath indexPathWithIndexes:_indexes
                                         length:_length - 1]);
   return( self);
}


- (NSUInteger) length
{
   return( _length);
}


// TODO: use better hash ?
- (NSUInteger) hash
{
   return( (NSUInteger) _mulle_objc_fnv1a( _indexes, _length * sizeof( NSUInteger)));
}


- (NSComparisonResult) compare:(NSIndexPath *) other
{
   NSUInteger   len1;
   NSUInteger   len2 ;
   NSUInteger   val1;
   NSUInteger   val2;
   NSUInteger   i;

   assert( [other isKindOfClass:[NSIndexPath class]]);

   if( self == other)
      return( NSOrderedSame);
   if( ! other)
      return( NSOrderedDescending);

   len1 = _length;
   len2 = other->_length;

   for( i = 0; i < len1 && i < len2; i++)
   {
      val1 = _indexes[ i];
      val2 = other->_indexes[ i];

      if( val1 != val2)
         return( val1 < val2 ? NSOrderedAscending : NSOrderedDescending);
   }

   if( len1 != len2)
      return( len1 < len2 ? NSOrderedAscending : NSOrderedDescending);
   return( NSOrderedSame);
}


- (void) getIndexes:(NSUInteger *) indexes
              range:(NSRange) range
{
   if( range.location + range.length > _length || range.length > _length)
   {
      fprintf( stderr, "-[%s]: range [%lu, %lu] beyond bounds (%lu)\n",
                           __FUNCTION__,
                           (unsigned long) range.location,
                           (unsigned long) range.length,
                           (unsigned long) _length);
      abort();
   }

   memcpy( indexes, &_indexes[ range.location], range.length * sizeof( NSUInteger));
}

@end
