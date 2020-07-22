#import "import-private.h"

#import "CGContext.h"
#import "CGPath.h"
#import "CGPath+nanovg.h"
#import "UIApplication.h"
#import "UIWindow.h"
#import "UIView.h"
#import "UIColor.h"
#import "CALayer.h"
#import "CAShapeLayer.h"
#import <string.h>
#import "UIEdgeInsets.h"

BOOL  drawStuff( CALayer *layer, 
                 CGContext *context, 
                 CGRect frame, 
                 struct MulleFrameInfo *info)
{
   CGRect              rect;
   struct NVGcontext   *vg;
   CGMutablePathRef    path;

   vg = MulleContextGetNVGContext( context);

//   nvgStrokeWidth( vg, 4);

   nvgBeginPath( vg);
   nvgMoveTo( vg, 400, 400);
   nvgLineTo( vg, 500, 200);
   nvgLineTo( vg, 600, 400);
   nvgClosePath( vg);

   nvgFillColor(vg, MulleColorCreate( 0xFF0000FF));
   nvgFill( vg);

#if 1
   path = CGPathCreate( MulleObjCInstanceGetAllocator( layer));
   CGPathMoveToPoint( path, NULL, 300, 200);
   CGPathAddLineToPoint( path, NULL, 400, 400);
   CGPathAddLineToPoint( path, NULL, 500, 200);
   CGPathCloseSubpath( path);

   nvgBeginPath( vg);
   nvgAddCGPath( vg, path);
   nvgFillColor(vg, MulleColorCreate( 0x00FF00FF));
   nvgFill( vg);
   CGPathDestroy( path);
#endif

   nvgBeginPath( vg);
   nvgMoveTo( vg, 100, 200);
   nvgLineTo( vg, 200, 400);
   nvgLineTo( vg, 300, 200);
   nvgClosePath( vg);

   nvgFillColor(vg, MulleColorCreate( 0x0000FFFF));
   nvgFill( vg);

   return( NO);
}

// scale stuff for stream
#define SCALE     2.0

void   setupScene( UIWindow *window, CGContext *context)
{
   UIView        *view;
   CGRect         frame;
   UIEdgeInsets   insets;
   CALayer        *layer;
  
   frame        = [window frame];
   frame.origin = CGPointZero;

   insets = UIEdgeInsetsMake( 8, 8, 8, 8);
   frame  = UIEdgeInsetsInsetRect( frame, insets);

   view  = [[[UIView alloc] initWithFrame:frame] autorelease];
   layer = [view layer];
   [layer setDrawContentsCallback:drawStuff];
   [window addSubview:view];
}


/*

// scale stuff for stream
#define SCALE     2.0
void   setupScene( UIWindow *window, CGContext *context)
{
   UIView        *view;
   CGRect         frame;
   UIEdgeInsets   insets;
   CAShapeLayer  *layer;
   CGPathRef      path;

   frame        = [window frame];
   frame.origin = CGPointZero;

   insets = UIEdgeInsetsMake( 8, 8, 8, 8);
   frame  = UIEdgeInsetsInsetRect( frame, insets);

   layer = [CAShapeLayer layerWithFrame:frame];
   
   path  = CGPathCreate( MulleObjCInstanceGetAllocator( window));

   CGPathMoveToPoint( path, NULL,    0, 0);
   CGPathAddLineToPoint( path, NULL, 0, 100);
   CGPathAddLineToPoint( path, NULL, 200, 0);
   CGPathAddLineToPoint( path, NULL, 0, 0);
   CGPathCloseSubpath( path);

   [layer setPath:path];
   // now path is owned by layer

   [layer setStrokeColor:[UIColor greenColor]];
   [layer setFillColor:[UIColor blackColor]];

   view  = [[[UIView alloc] initWithLayer:layer] autorelease];
   [window addSubview:view];
}

*/
int   main()
{
   CGContext   *context;
   UIWindow    *window;

   /*
    * window and app 
    */
   mulle_testallocator_initialize();
   mulle_default_allocator = mulle_testallocator;

   @autoreleasepool
   {
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
   mulle_testallocator_reset();
}

