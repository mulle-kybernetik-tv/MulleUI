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


void  drawStuff( void *aLayer, 
                 CGContext *context, 
                 CGRect frame, 
                 struct MulleFrameInfo *info)
{
   CircleLayer   *layer = aLayer;
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
   struct mulle_pointerarray             array;

   frame = [window frame];

   for( i = 0; i < 1000; i++)
   {
      rect.origin.x = rand() % ((int) frame.size.width - 16);
      rect.origin.y = rand() % ((int) frame.size.height - 16);
      rect.size     = CGSizeMake( 32 ,32);
      layer = [[[CircleLayer alloc] initWithFrame:rect] autorelease];
      view  = [[[UIView alloc] initWithLayer:layer] autorelease];
      [layer setDrawContentsCallback:drawStuff];
      [layer setColor:MulleColorCreateRandom( 0x00FF00FF, 0xFF00FF00)];
      [window addSubview:view];
   }

   _mulle_pointerarray_init( &array, 0, 0, NULL);
   [window addSubviewsIntersectingRect:CGRectMake( frame.size.width / 4,
                                                   frame.size.height / 4,
                                                   frame.size.width / 2,
                                                   frame.size.height / 2)
                      toPointerArray:&array
              invertIntersectionTest:YES];

   rover = mulle_pointerarray_enumerate_nil( &array);
   while( view = _mulle_pointerarrayenumerator_next( &rover))
      [view setColor:MulleColorCreateRandom( 0xFF0000FF, 0x00FFFF00)];
   mulle_pointerarrayenumerator_done( &rover);
  
   mulle_pointerarray_done( &array);
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

