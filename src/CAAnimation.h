#import "import.h"

#import "CGBase.h"
#import "CGGeometry.h"
#import "CALayer.h"  // for colorref

#include <time.h>


//
// CAAnimation is just a struct in this UIKit
//

enum CAAnimationBits
{
   CAAnimationStarted     = 0x1,
   CAAnimationHasReversed = 0x2,
   CAAnimationRepeats     = 0x10000,
   CAAnimationReverses    = 0x20000
};


//
// Step0: convert timespec to double (MulleTime)
// Step1: make time based instead of renderFrame based
// Step2: turn into CAAnimation or some sort
// Step3: add to CALayer
// Collect all layers ?
// Step4: After rendering, run through all animations in all layers
//
typedef double    CARelativeTime;

static inline void   CARelativeTimeInit( CARelativeTime *p, double value)
{
   if( p)
      *p = value;
}


struct CARelativeTimeRange
{
   CARelativeTime   delay;
   CARelativeTime   duration;
};

static inline struct CARelativeTimeRange   
   CARelativeTimeRangeMake( CARelativeTime delay, CARelativeTime duration) 
{
    struct CARelativeTimeRange result = { delay, duration };
    return result;
}

static inline void   CARelativeTimeRangeInit( struct CARelativeTimeRange *p, 
                                              CARelativeTime delay,
                                              CARelativeTime duration)
{
   if( p)
   {
      p->delay    = delay;
      p->duration = duration;
   }
}


typedef double    CAAbsoluteTime;


static inline void   CAAbsoluteTimeInit( CAAbsoluteTime *p, double value)
{
   if( p)
      *p = value;
}

struct CAAbsoluteTimeRange
{
   CAAbsoluteTime   start;
   CAAbsoluteTime   end;
};

static inline struct CAAbsoluteTimeRange   
   CAAbsoluteTimeRangeMake( CAAbsoluteTime start, CAAbsoluteTime end) 
{
    struct CAAbsoluteTimeRange result = { start, end };
    return result;
}

static inline void   CAAbsoluteTimeRangeInit( struct CAAbsoluteTimeRange *p, 
                                              CAAbsoluteTime start,
                                              CAAbsoluteTime end)
{
   if( p)
   {
      p->start = start;
      p->end   = end;
   }
}


#ifndef NS_IN_S
# define NS_IN_S (1000*1000*1000)
#endif

static inline CAAbsoluteTime   CAAbsoluteTimeWithTimespec( struct timespec a)
{
   return( a.tv_sec + a.tv_nsec / (double) NS_IN_S);
}



static inline CAAbsoluteTime   CAAbsoluteTimeWithSecondsAndNanoseconds( int tv_sec, long tv_nsec)
{
   return( tv_sec + tv_nsec / (double) NS_IN_S);
}

static inline CARelativeTime   CARelativeTimeWithSecondsAndNanoseconds( int tv_sec, long tv_nsec)
{
   return( tv_sec + tv_nsec / (double) NS_IN_S);
}


static inline double   CATimeAdd( double a, double b)
{
   return( a + b);
}


static inline double   CATimeSubtract( double a, double b)
{
   return( a - b);
}


// stuff to animate:
//  CGPoint
//  CGColor
//  CGFloat
//  CGRect
//  BOOL

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


struct CAAnimationValueRange
{
   union CAAnimationValue   start;
   union CAAnimationValue   end;
};


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


//
// TODO: interpolating RGB is easy, but not necessarily very nice looking.
//       Possibly implement http://labs.adamluptak.com/javascript-color-blending/
//       though it is costly
//
struct CAAnimation
{
   struct CAAbsoluteTimeRange   absolute;   
   struct CARelativeTimeRange   relative;  // delay, copied from initialRenderdelay
   enum CAAnimationValueType    valueType;
   union CAAnimationValue       start;     
   union CAAnimationValue       end;     
   union CAAnimationValue       repeatStart;  
     
   SEL                          propertySetter;

   MulleQuadratic    quadratic;
   NSUInteger        bits;
};


void   CAAnimationInit( struct CAAnimation *info,
                        SEL propertySetter,
                        enum CAAnimationValueType type,
                        struct CAAnimationValueRange *range,
                        struct CARelativeTimeRange timeRange,
                        NSUInteger bits);


void   CAPointAnimationInit( struct CAAnimation *info,
                            SEL propertySetter,
                            CGPoint start,
                            CGPoint end,
                            struct CARelativeTimeRange timeRange,
                            NSUInteger bits);

void   CARectAnimationInit( struct CAAnimation *info,
                            SEL propertySetter,
                            CGRect  start,
                            CGRect  end,
                            struct CARelativeTimeRange timeRange,
                            NSUInteger bits);

void   CAColorAnimationInit( struct CAAnimation *info,
                             SEL propertySetter,
                             CGColorRef  start,
                             CGColorRef  end,
                             struct CARelativeTimeRange timeRange,
                             NSUInteger bits);

void  CAAnimationAnimate( struct CAAnimation *info, 
                          CALayer *layer, 
                          CAAbsoluteTime now);
