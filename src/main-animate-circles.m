#import "import-private.h"

#import "CGBase.h"
#import "CGContext.h"
#import "CGGeometry.h"
#import "CGColor+MulleObjC.h"
#import "CGGeometry+MulleObjC.h"
#import "UIApplication.h"
#import "UIWindow.h"
#import "UIView.h"
#import "UIView+CAAnimation.h"
#import "UIColor.h"
#import "CALayer.h"
#import <string.h>
#import "UIEdgeInsets.h"


@interface CircleLayer : CALayer

@property( observable) CGFloat     scale;  // 0 - 1
@property( observable) CGColorRef  color;  // 0 - 1
@property( observable) CGRect      box;    // 0 - 1

@end


@implementation CircleLayer

- (instancetype) initWithFrame:(CGRect) frame
{
   _scale = 1;
   _color = MulleColorCreate( 0x000000FF);
   _box   = frame;
   return( [super initWithFrame:frame]);
}

@end


BOOL  drawStuff( CALayer *aLayer,
                 CGContext *context,
                 CGRect frame,
                 struct MulleFrameInfo *info)
{
   CircleLayer   *layer = (CircleLayer *) aLayer;
   CGFloat        radius;
   CGRect         box;
   struct NVGcontext   *vg;

   vg = MulleContextGetNVGContext( context);
   nvgBeginPath( vg);
   radius = MulleCGFloatMinimum( CGRectGetWidth( frame), CGRectGetHeight( frame)) / 2 - 10;
   radius *= [layer scale];

   nvgCircle( vg, CGRectGetMidX( frame), CGRectGetMidY( frame), radius);
   nvgStrokeColor( vg, [layer color]);
   nvgStrokeWidth( vg, 3.5);
   nvgStroke( vg);

   nvgBeginPath( vg);
   box = [layer box];
   nvgRect( vg, CGRectGetMinX( box), CGRectGetMinY( box), CGRectGetWidth( box), CGRectGetHeight( box));
   nvgStrokeColor( vg, [layer color]);
   nvgStrokeWidth( vg, 3.5);
   nvgStroke( vg);

   return( NO);
}

// scale stuff for stream
#define SCALE     2.0

void   setupScene( UIWindow *window, CGContext *context)
{
   UIView        *view;
   CGRect         frame;
   UIEdgeInsets   insets;
   CircleLayer    *layer;

   frame        = [window frame];
   frame.origin = CGPointZero;

   insets = UIEdgeInsetsMake( 8, 8, 8, 8);
   frame  = UIEdgeInsetsInsetRect( frame, insets);

   layer = [[[CircleLayer alloc] initWithFrame:frame] autorelease];
   view  = [[[UIView alloc] initWithLayer:layer] autorelease];
   [layer setDrawContentsCallback:drawStuff];
   [window addSubview:view];

   [layer setColor:MulleColorCreate( 0xFF0000FF)];

   // UIView -> CAAnimation
   [UIView beginAnimations:"animation"
                    context:NULL];
   [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
   [UIView setAnimationDelay:2];
   [UIView setAnimationDuration:2];
   [UIView setAnimationRepeatCount:20];
   [layer setScale:-1.0];
   [layer setColor:MulleColorCreate( 0x0000FFFF)];
   [layer setBox:CGRectMake( 100, 100, 100, 100)];
   [UIView commitAnimations];
}


int   main()
{
   CGContext   *context;
   UIWindow    *window;

   /*
    * window and app
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 400.0 * SCALE, 300.0 * SCALE)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   context = [[CGContext new] autorelease];
   [context setBackgroundColor:CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0)];

   setupScene( window, context);

   [window dump];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

