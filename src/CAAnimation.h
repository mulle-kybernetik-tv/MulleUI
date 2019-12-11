#import "import.h"

#import "CGBase.h"
#import "CGGeometry.h"
#import "CGColor.h"
#import "CATime.h"


enum CAAnimationBits
{
   CAAnimationStarted     = 0x1,
   CAAnimationHasReversed = 0x2,
   // options
   CAAnimationReverses    = 0x10000
};



// stuff to animate:
//  CGPoint
//  CGColor
//  CGFloat
//  CGRect
//  BOOL
// none of these values are retain/release

union CAAnimationValue
{
   BOOL         boolValue;
   NSInteger    integerValue;
   CGFloat      floatValue;
   CGColorRef   color;
   CGPoint      point;
   CGSize       size;
   CGRect       rect;
};


static inline union CAAnimationValue
   CGAnimationValueMakeWithRect( CGRect rect)
{
   union CAAnimationValue  value;

   value.rect = rect;
   return( value);
}

static inline union CAAnimationValue
   CGAnimationValueMakeWithColor( CGColorRef color)
{
   union CAAnimationValue  value;

   value.color = color;
   return( value);
}


struct CAAnimationValueRange
{
   union CAAnimationValue   start;
   union CAAnimationValue   end;
};


static inline struct CAAnimationValueRange 
   CGAnimationValueRangeMakeWithRects( CGRect start, CGRect end)
{
   struct CAAnimationValueRange  range;

   range.start.rect = start;
   range.end.rect   = end;
   return( range);
}

static inline struct CAAnimationValueRange 
   CGAnimationValueRangeMakeWithColors( CGColorRef start, CGColorRef end)
{
   struct CAAnimationValueRange  range;

   range.start.color = start;
   range.end.color   = end;
   return( range);
}


enum CAAnimationValueType
{
   CAAnimationValueUndefined,
   CAAnimationValueBOOL,
   CAAnimationValueNSInteger,
   CAAnimationValueCGFloat,
   CAAnimationValueCGColorRef,
   CAAnimationValueCGPoint,
   CAAnimationValueCGSize,
   CAAnimationValueCGRect
};


struct CAAnimationOptions
{
   struct CARelativeTimeRange    timeRange;
   CGFloat                       repeatCount;
   MulleQuadratic                curve;
   NSUInteger                    bits;  // reverse flag mainly
};



@class CALayer;

// All animations in one UIView beginAnimations:context: have the
// same duration and start and repeatCount

@interface MulleAnimationDelegate : NSObject

@property( assign) id     delegate;
@property( assign) SEL    animationWillStartSelector;
@property( assign) SEL    animationDidStopSelector;
@property( assign) void   *context;
@property( assign) char   *identifier; 

@property( assign) NSUInteger  started; 
@property( assign) NSUInteger  ended; 

- (void) willStart;
- (void) didPreempt;
- (void) didEnd;

@end



//
// TODO: interpolating RGB is easy, but not necessarily very nice looking.
//       Possibly implement http://labs.adamluptak.com/javascript-color-blending/
//       though it is costly
//
@interface CAAnimation : NSObject
{
   struct CARelativeTimeRange   _relative;  // delay, copied from initialRenderdelay
   enum CAAnimationValueType    _valueType;
   union CAAnimationValue       _start;     
   union CAAnimationValue       _end;     
   union CAAnimationValue       _repeatStart;  

   MulleQuadratic               _quadratic;
   SEL                          _propertySetter;

   // mutating state
   struct CAAbsoluteTimeRange   _absolute;   
   CGFloat                      _repeatCount; // original state will be lost 
   NSUInteger                   _bits;        // options and more
   NSUInteger                   _frames;
}

//@property( retain) CAAnimationGroup        *animationGroup;
@property( retain) MulleAnimationDelegate  *animationDelegate;


- (id) initWithPropertySetter:(SEL) propertySetter
                    valueType:(enum CAAnimationValueType) type
                   valueRange:(struct CAAnimationValueRange *) range
                  repeatStart:(union CAAnimationValue) repeatStart
                      options:(struct CAAnimationOptions *) options;

- (id) initWithPropertySetter:(SEL) propertySetter
                   startColor:(CGColorRef) start
                     endColor:(CGColorRef) end
                      options:(struct CAAnimationOptions *) options;

- (id) initWithPropertySetter:(SEL) propertySetter
                    startRect:(CGRect) start
                      endRect:(CGRect) end
                      options:(struct CAAnimationOptions *) options;

- (id) initWithPropertySetter:(SEL) propertySetter
              startFloatValue:(CGFloat) start
                endFloatValue:(CGFloat) end
                      options:(struct CAAnimationOptions *) options;

// called by the renderloop
- (void) animateLayer:(CALayer *) layer
         absoluteTime:(CAAbsoluteTime) now;

// subclass must override this method, to do their special effect
- (void) animateLayer:(CALayer *) layer
normalizedRelativeTime:(double) x;

// used if options are set to CAAnimationReverses (and CAAnimationRepeats)
- (void) reverse;

@end

