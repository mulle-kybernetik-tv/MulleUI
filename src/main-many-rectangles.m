#import "import-private.h"

#import "CGBase.h"
#import "CGContext.h"
#import "CGGeometry.h"
#import "CGColor+MulleObjC.h"
#import "CGGeometry+CString.h"
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

// memo: this actually draws outside of the layer somewhat, should fix this
//       as noticed when reusing the code in the collection view demo
void  drawStuff( CALayer *aLayer, 
                 CGContext *context, 
                 CGRect frame, 
                 struct MulleFrameInfo *info)
{
   CircleLayer   *layer = (CircleLayer *) aLayer;
   CGFloat        radius;
   CGRect         box;
   struct NVGcontext   *vg;

   vg = MulleContextGetNVGContext( context);
   nvgBezierTessellation( vg, NVG_TESS_AFD);

   nvgBeginPath( vg);
   radius = MulleCGFloatMinimum( CGRectGetWidth( frame), CGRectGetHeight( frame)) / 2 - 10;
   radius *= [layer scale];

   nvgRect( vg, CGRectGetMidX( frame) - radius, 
                CGRectGetMidY( frame) - radius, 
                radius * 2, 
                radius * 2);

//   nvgCircle( vg, CGRectGetMidX( frame), CGRectGetMidY( frame), radius);
   nvgFillColor( vg, [layer color]);
   nvgStrokeWidth( vg, 3.5);
   nvgFill( vg);
/*
   nvgBeginPath( vg);
   box = [layer box];
   nvgRect( vg, CGRectGetMinX( box), CGRectGetMinY( box), CGRectGetWidth( box), CGRectGetHeight( box));
   nvgFillColor( vg, [layer color]);
   nvgStrokeWidth( vg, 3.5);
   nvgFill( vg);
*/
}

// scale stuff for stream
#define SCALE     2.0

void   setupScene( UIWindow *window, CGContext *context)
{
   UIView        *view;
   CGRect         frame;
   CGRect         rect;
   UIEdgeInsets   insets;
   CircleLayer    *layer;
   CGFloat        scale;
   CGFloat        translate;
   NSInteger      i;
   struct mulle_pointerarrayenumerator   rover;

   frame        = [window frame];
   frame.origin = CGPointZero;

   insets = UIEdgeInsetsMake( 8, 8, 8, 8);
   frame  = UIEdgeInsetsInsetRect( frame, insets);

   layer = [[[CircleLayer alloc] initWithFrame:frame] autorelease];
   view  = [[[UIView alloc] initWithLayer:layer] autorelease];
   [layer setDrawContentsCallback:drawStuff];
   [window addSubview:view];

   [layer setColor:MulleColorCreate( 0xFF0000FF)];

   for( i = 0; i < 1000; i++)
   {
      rect  = frame;
      scale = (rand() % 750 + 250) / 1000.0;
      assert( scale <= 1.0);
      rect.size.width   = rect.size.width * scale;
      rect.size.height  = rect.size.height * scale;

      translate         = (rand() % 1000) / 1000.0;
      assert( translate <= 1.0);
      rect.origin.x    += (frame.size.width - rect.size.width) * translate;
      translate         = (rand() % 1000) / 1000.0;
      assert( translate <= 1.0);
      rect.origin.y    += (frame.size.height - rect.size.height) * translate;

      // fprintf( stderr, "%s", CGRectCStringDescription( rect));
      layer = [[[CircleLayer alloc] initWithFrame:rect] autorelease];
      [layer setDrawContentsCallback:drawStuff];
      [layer setColor:MulleColorCreate( 0x00FF00FF)];
      [view addLayer:layer];
   }

   // UIView -> CAAnimation
   [UIView beginAnimations:"animation" 
                    context:NULL];
   [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
   [UIView setAnimationDelay:0];        
   [UIView setAnimationDuration:10];        
   [UIView setAnimationRepeatCount:20]; 

   rover = mulle_pointerarray_enumerate_nil( [view _layers]);
   while( (layer = _mulle_pointerarrayenumerator_next( &rover)))
   {
      [layer setScale:-1.0];
      [layer setColor:MulleColorCreateRandom( 0x000000FF, 0x00FF0000)];
   }
   mulle_pointerarrayenumerator_done( &rover);
         

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

