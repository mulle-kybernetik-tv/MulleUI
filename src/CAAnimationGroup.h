#import "CAAnimation.h"


// CAAnimationGroup animations all must belong to the same layer
// as the group...
@interface CAAnimationGroup : CAAnimation

@property( assign) id<NSArray>  animations;

@end
