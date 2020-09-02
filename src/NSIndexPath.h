//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "NSObject.h")
#  import "NSObject.h"
# endif
#endif

#import "import.h"


@interface NSIndexPath : NSObject
{
   NSUInteger   _length;
   NSUInteger   _storage[ 1];
}

+ (instancetype) indexPathWithIndex:(NSUInteger) index;
+ (instancetype) indexPathWithIndexes:(NSUInteger *) index
                               length:(NSUInteger) length;

+ (instancetype) indexPathForRow:(NSUInteger) row
                       inSection:(NSUInteger) section;
+ (instancetype) indexPathForItem:(NSUInteger) item 
                        inSection:(NSUInteger) section;

- (NSUInteger) indexAtPosition:(NSUInteger) index;
- (void) getIndexes:(NSUInteger *) indexes
              range:(NSRange) range;

- (void) getIndexes:(NSUInteger *) indexes;

- (NSUInteger) section;
- (NSUInteger) row;
- (NSUInteger) item;
- (NSUInteger) length;

- (NSComparisonResult) compare:(id) other;

@end
