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


@implementation NSObject( NSIndexPath)

- (BOOL) __isNSIndexPath
{
   return( NO);
}

@end


@implementation NSIndexPath

- (BOOL) __isNSIndexPath
{
   return( YES);
}


+ (instancetype) indexPathWithIndex:(NSUInteger) index
{
   return( [self indexPathWithIndexes:&index
                               length:1]);
}


+ (instancetype) indexPathWithIndexes:(NSUInteger *) indexes
                               length:(NSUInteger) length
{
   NSIndexPath   *indexPath;
   NSUInteger    extra;

   extra     = length ? (sizeof( NSUInteger) * (length - 1)) : 0;
   indexPath = [NSAllocateObject( self, extra, NULL) autorelease];
   indexPath->_length = length;
   memcpy( indexPath->_storage, indexes, length * sizeof( NSInteger));
   return( indexPath);
}

+ (instancetype) mulleIndexPathWithIndexes:(NSUInteger *) indexes
                                    length:(NSUInteger) length
                                  andIndex:(NSUInteger) index
{
   NSIndexPath   *indexPath;
   NSUInteger    extra;

   extra     = sizeof( NSUInteger) * length;
   indexPath = [NSAllocateObject( self, extra, NULL) autorelease];
   memcpy( indexPath->_storage, indexes, length * sizeof( NSInteger));
   indexPath->_storage[ length] = index;
   indexPath->_length = length + 1;

   return( indexPath);
}

#pragma clang diagnostic ignored  "-Warray-bounds"

+ (instancetype) indexPathForRow:(NSUInteger) row
                       inSection:(NSUInteger) section
{
   NSIndexPath   *indexPath;

   indexPath               = [NSAllocateObject( self, sizeof( NSUInteger), NULL) autorelease];
   indexPath->_length      = 2;
   indexPath->_storage[ 0] = section;
   indexPath->_storage[ 1] = row;

   return( indexPath);
}


+ (instancetype) indexPathForItem:(NSUInteger) item 
                        inSection:(NSUInteger) section
{
   NSIndexPath   *indexPath;

   indexPath               = [NSAllocateObject( self, sizeof( NSUInteger), NULL) autorelease];
   indexPath->_length      = 2;
   indexPath->_storage[ 0] = section;
   indexPath->_storage[ 1] = item;

   return( indexPath);
}

- (NSUInteger) indexAtPosition:(NSUInteger) index
{
   return( index < _length ? _storage[ index] : NSNotFound);
}


- (void) getIndexes:(NSUInteger *) indexes
              range:(NSRange) range
{
   range = MulleObjCValidateRangeAgainstLength( range, _length);
   memcpy( indexes, 
           &_storage[ range.location], 
           sizeof( NSUInteger) * range.length);

}


- (void) getIndexes:(NSUInteger *) indexes
{
   memcpy( indexes, _storage, sizeof( NSUInteger) * _length);
}


- (NSUInteger) section
{
   if( ! _length)
      abort();
   return( _storage[ 0]);
}


- (NSUInteger) row
{
   if( _length < 2)
      abort();
   return( _storage[ 1]);
}


- (NSUInteger) item
{
   if( _length < 2)
      abort();
   return( _storage[ 1]);
}


- (NSUInteger) length
{
   return( _length);
}


- (NSUInteger) hash
{
   NSUInteger   i;
   NSUInteger   hash;

   hash = 0xc2b2ae35;   // TODO: NAIVE SEED CHECK THAT THIS IS GOOD
   for( i = 0; i < _length; i++)
      hash ^= mulle_hash_integer( _storage[ i]);
   return( hash);
}


- (BOOL) isEqualToIndexPath:(NSIndexPath *) other 
{
   NSUInteger   otherLength;

   // allow for lazyness
   otherLength = [other length];
   if( otherLength != [self length])
      return( NO);

   return( memcmp( _storage, other->_storage, otherLength * sizeof( NSUInteger)) == 0);
}


- (BOOL) isEqual:(id) other 
{
   if( ! [other __isNSIndexPath])
      return( NO);
   return( [other isEqualToIndexPath:self]);
}

//
// 1.2 is considered larger than 1.1.3
//
- (NSComparisonResult) compare:(id) other;
{
   NSUInteger   length;
   NSUInteger   otherLength;
   NSUInteger   i, n;

   NSParameterAssert( ! other || [other isKindOfClass:[NSIndexPath class]]);

   length      = [self length];
   otherLength = [other length];

   n = length < otherLength ? length : otherLength;
   for( i = 0; i < n; i++)
   {
      if( _storage[ i] == ((NSIndexPath *) other)->_storage[ i])
         continue;
      if( _storage[ i] < ((NSIndexPath *) other)->_storage[ i])
         return( NSOrderedAscending);
      return( NSOrderedDescending);
   }
   if( length == otherLength)
      return( NSOrderedSame);
   if ( length < otherLength)
      return( NSOrderedAscending);
   return( NSOrderedDescending);
}



- (NSIndexPath *) indexPathByAddingIndex:(NSUInteger) newIndex
{
   assert( newIndex != NSNotFound);
   return( [NSIndexPath mulleIndexPathWithIndexes:_storage
                                            length:_length
                                          andIndex:newIndex]);
}


- (NSIndexPath *) indexPathByRemovingLastIndex
{
   if( _length)
      return( [NSIndexPath indexPathWithIndexes:_storage
                                         length:_length - 1]);
   return( self);
}


- (id) copy
{
   return( [self retain]);
}

@end
