#import "import-private.h"

#import "CGContext.h"
#import "UIApplication.h"
#import "UIWindow.h"
#import "UIView.h"
#import "UIColor.h"
#import "CALayer.h"
#import <string.h>
#import "UIEdgeInsets.h"




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

void  drawStuff( void *layer, 
                 NVGcontext *vg, 
                 CGRect frame, 
                 struct MulleFrameInfo *info)
{
   CGRect  rect;

   rect = CGRectMake( 100.5, 100, 100, 100);

   _drawStuff( vg, rect, 1);
   rect.origin.x += 300;
   _drawStuff( vg, rect, 0);
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
   layer = [view mainLayer];
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
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 400.0 * SCALE, 300.0 * SCALE)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   context = [CGContext new];
   [context setBackgroundColor:CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0)];

   setupScene( window, context);

   [window dump];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}
