#import "CALayer.h"


@interface CALayer( CAAnimation)

- (void) addAnimation:(CAAnimation *) animation;
- (void) removeAllAnimations;
- (NSUInteger) numberOfAnimations;

- (void) willAnimateWithAbsoluteTime:(CAAbsoluteTime) time;
- (void) animateWithAbsoluteTime:(CAAbsoluteTime) time;

- (void) animatePropertiesWithSnapshotlayer:(CALayer *) snapshot
                          animationDelegate:(MulleAnimationDelegate *) animationDelegate
                           animationOptions:(struct CAAnimationOptions *) animationOptions;
//
// called by UIView to create implicit animations from snapshotted values
// the snapshot will be gone afterwards. Also cancels all other 
// animations. (?)
//
- (void) commitImplicitAnimationsWithAnimationID:(char *) animationsID
                               animationDelegate:(MulleAnimationDelegate *) animationDelegate;

@end

