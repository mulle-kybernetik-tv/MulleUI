//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "NSIndexPath.h"

#import "import-private.h"


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


+ (instancetype) indexPathWithIndexes:(NSUInteger *) index
                               length:(NSUInteger) length
{
   NSIndexPath   *indexPath;
   NSUInteger    extra;

   extra     = length ? (sizeof( NSUInteger) * (length - 1)) : 0;
   indexPath = [NSAllocateObject( self, extra, NULL) autorelease];
   indexPath->_length = length;
   memcpy( indexPath->_storage, index, length * sizeof( NSInteger));
   return( indexPath);
}


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
   if( index < _length)
      return( self->_storage[ index]);
   abort();
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
   NSUInteger   i;

   // allow for lazyness
   if( [other length] != [self length])
      return( NO);

   for( i = 0; i < _length; i++)
      if( _storage[ i] != other->_storage[ i])
         return( NO);

   return( YES);
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

@end
