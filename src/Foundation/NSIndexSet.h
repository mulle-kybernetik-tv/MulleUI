#import "import.h"


@interface NSIndexSet : NSObject <NSCopying>
{
   struct _mulle_rangeset   _set;
   NSUInteger               _count;
}

- (NSUInteger) count;
- (NSUInteger) firstIndex;
- (NSUInteger) lastIndex;


+ (instancetype) indexSet;
+ (instancetype) indexSetWithIndex:(NSUInteger) index;
+ (instancetype) indexSetWithIndexesInRange:(NSRange) indexRange;
- (instancetype) initWithIndex:(NSUInteger) index;
- (instancetype) initWithIndexesInRange:(NSRange) indexRange;
- (instancetype) initWithIndexSet:(NSIndexSet *) indexSet;

- (instancetype) mulleInitWithIndexesInRanges:(NSRange *) ranges
                                      length:(NSUInteger) n;

- (BOOL) containsIndex:(NSUInteger) index;
- (BOOL) containsIndexes:(NSIndexSet *) indexSet;
- (BOOL) containsIndexesInRange:(NSRange) indexRange;
- (BOOL) intersectsIndexesInRange:(NSRange) indexRange;

- (NSUInteger) countOfIndexesInRange:(NSRange)indexRange;

//- (NSUInteger)indexPassingTest:(BOOL (^)(NSUInteger, BOOL*))predicate;
//- (NSIndexSet*)indexesPassingTest:(BOOL (^)(NSUInteger, BOOL*))predicate;
//- (NSUInteger)indexWithOptions:(NSEnumerationOptions)options passingTest:(BOOL (^)(NSUInteger, BOOL*))predicate;
//- (NSIndexSet*)indexesWithOptions:(NSEnumerationOptions)options passingTest:(BOOL (^)(NSUInteger, BOOL*))predicate;
//- (NSUInteger)indexInRange:(NSRange)range options:(NSEnumerationOptions)options passingTest:(BOOL (^)(NSUInteger, BOOL*))predicate;
//- (NSIndexSet*)indexesInRange:(NSRange)range options:(NSEnumerationOptions)options passingTest:(BOOL (^)(NSUInteger, BOOL*))predicate;
//- (void)enumerateRangesInRange:(NSRange)range options:(NSEnumerationOptions)options usingBlock:(void (^)(NSRange, BOOL*))block;
//- (void)enumerateRangesUsingBlock:(void (^)(NSRange, BOOL*))block;
// - (void)enumerateRangesWithOptions:(NSEnumerationOptions)options usingBlock:(void (^)(NSRange, BOOL*))block;

- (BOOL) isEqualToIndexSet:(NSIndexSet *) indexSet;
- (NSUInteger) indexLessThanIndex:(NSUInteger) index;
- (NSUInteger) indexLessThanOrEqualToIndex:(NSUInteger) index;
- (NSUInteger) indexGreaterThanOrEqualToIndex:(NSUInteger) index;
- (NSUInteger) indexGreaterThanIndex:(NSUInteger) index;
- (NSUInteger) getIndexes:(NSUInteger *) indexBuffer
                 maxCount:(NSUInteger) bufferSize
             inIndexRange:(NSRange *) indexRange;
//- (void)enumerateIndexesUsingBlock:(void (^)(NSUInteger, BOOL*))block;
//- (void)enumerateIndexesWithOptions:(NSEnumerationOptions)options usingBlock:(void (^)(NSUInteger, BOOL*))block;
//- (void)enumerateIndexesInRange:(NSRange) range options:(NSEnumerationOptions)options usingBlock:(void (^)(NSUInteger, BOOL*))block;

@end
