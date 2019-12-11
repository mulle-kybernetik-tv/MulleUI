#import "NSIndexSet.h"


@interface NSMutableIndexSet : NSIndexSet <NSCopying>

- (void) addIndex:(NSUInteger) index;
- (void) addIndexes:(NSIndexSet *) indexSet;
- (void) addIndexesInRange:(NSRange) indexRange;
- (void) removeIndex:(NSUInteger) index;
- (void) removeIndexes:(NSIndexSet *) indexSet;
- (void) removeAllIndexes;
- (void) removeIndexesInRange:(NSRange) indexRange;
- (void) shiftIndexesStartingAtIndex:(NSUInteger) startIndex
                                  by:(NSInteger) delta;
@end


@interface NSIndexSet( NSMutableCopying)

- (instancetype) mutableCopy;

@end
