#import "import-private.h"

#import "CGContext.h"
#import "UIApplication.h"
#import "UIWindow.h"
#import "UIView.h"
#import "UIColor.h"
#import "CALayer.h"
#import <string.h>
#import "UIEdgeInsets.h"


// Topics:
//  * create a window
//  * place view inside window
//  * add drawing C code to the views layer to produce the graphics
//  * run renderloop (with event handling)
//
void   _drawStuff( NVGcontext *vg, 
                   CGRect rect,
                   int antialias)
{
   nvgShapeAntiAlias( vg, antialias);  
   nvgStrokeWidth( vg, 10.0);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, rect.origin.x, 
                       rect.origin.y, 
                       rect.size.width, 
                       rect.size.height, 
                       20);
   nvgStrokeColor(vg, MulleColorCreate( 0x8080007F));
   nvgStroke( vg);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, rect.origin.x + 50, 
                       rect.origin.y, 
                       rect.size.width, 
                       rect.size.height, 
                       20);
   nvgStrokeColor(vg, MulleColorCreate( 0x0080807F));
   nvgStroke( vg);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, rect.origin.x + 50, 
                       rect.origin.y + 50, 
                       rect.size.width, 
                       rect.size.height, 
                       20);
   nvgStrokeColor(vg, MulleColorCreate( 0x8000807F));
   nvgStroke( vg);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, rect.origin.x, 
                       rect.origin.y + 50, 
                       rect.size.width, 
                       rect.size.height, 
                       20);
   nvgStrokeColor(vg, MulleColorCreate( 0x8080807F));
   nvgStroke( vg);

   nvgShapeAntiAlias( vg, 1);  
}                 


BOOL  drawStuff( CALayer *layer, 
                 CGContext *context, 
                 CGRect frame, 
                 struct MulleFrameInfo *info)
{
   CGRect              rect;
   struct NVGcontext   *vg;

   vg = MulleContextGetNVGContext( context);

   rect = CGRectMake( 100.5, 100, 100, 100);
   rect.origin.x += frame.origin.x;
   rect.origin.y += frame.origin.y;

   _drawStuff( vg, rect, 1);
   rect.origin.x += 300;
   _drawStuff( vg, rect, 0);
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

