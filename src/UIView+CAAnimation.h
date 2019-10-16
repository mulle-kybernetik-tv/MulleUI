#import "UIView.h"

#import "CAAnimation.h"

enum UIViewAnimationCurve 
{
   UIViewAnimationCurveEaseInOut,
   UIViewAnimationCurveEaseIn,
   UIViewAnimationCurveEaseOut,
   UIViewAnimationCurveLinear
};

//
// Doing it like this is kinda bad, because different windows could have
// different threads but they couldn't create animations at the same time
// because it is tied to the class. On the other, one can reuse more 
// UIKit code, by keeping this as is.
// Possible solution: Have [UIWindow window] in a thread local variable
// and forward all these UIView calls there
//
@interface UIView ( CAAnimation)

+ (void) beginAnimations:(char *) animationID 
                 context:(void *) context;
+ (void) commitAnimations;

+ (BOOL) areAnimationsEnabled;
+ (void) addAnimatedLayer:(CALayer *) layer;

// not supported
//+ (void) setAnimationDelegate:(id) delegate;
//+ (void) setAnimationWillStartSelector:(SEL) selector;
//+ (void) setAnimationDidStopSelector:(SEL) selector;

+ (NSUInteger) animationCurve;
+ (void) setAnimationCurve:(NSUInteger) curve;

+ (CARelativeTime) animationDelay;
+ (void) setAnimationDelay:(CARelativeTime) delay;

+ (CARelativeTime) animationDuration;
+ (void) setAnimationDuration:(CARelativeTime) duration;

+ (BOOL) animationRepeatAutoreverses;
+ (void) setAnimationRepeatAutoreverses:(BOOL) flag;

// incompatible, this like setAnimationRepeatCount:-1 (YES)
// or setAnimationRepeatCount:0
+ (BOOL) mulleAnimationRepeats;
+ (void) mulleSetAnimationRepeats:(BOOL) flag;

// if repeatCount < 0.0 then it repeats indefinitely
+ (void ) setAnimationRepeatCount:(float) repeatCount;
+ (float) animationRepeatCount;

@end


