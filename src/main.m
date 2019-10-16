#import "import-private.h"

#import "CGContext.h"
#import "CGGeometry+CString.h"
#import "CALayer.h"
#import "CAAnimation.h"
#import "MulleBitmapImage.h"
#import "MulleImageLayer.h"
#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UIEvent.h"
#import "UILabel.h"
#import "UIScrollView.h"
#import "UISegmentedControl.h"
#import "UISlider.h"
#import "UIStepper.h"
#import "UISwitch.h"
#import "UIView+CAAnimation.h"
#import "UIWindow.h"
#import <string.h>


//	stolen from catgl ©2015,2018 Yuichiro Nakada
#define W  320
#define H  200

#include "Ghostscript_Tiger-svg.inc"
#include "sealie-bitmap.inc"
#include "turtle-bitmap.inc"
#include "viech-bitmap.inc"

#if 0
static char   svginput[] = \
"<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">\n"
"   <rect x=\"100\" y=\"50\" width=\"200\" height=\"100\" stroke=\"#c04949\" stroke-linejoin=\"round\" stroke-width=\"5.265\"/>\n"
"</svg>\n"
"\n"
;
#endif


static UIEvent   *button_callback( UIButton *button, UIEvent *event)
{
   fprintf( stderr, "button_callback: %s\n", [button cStringDescription]);
   return( nil);
}


static UIEvent   *scroll_callback( UIButton *button, UIEvent *event)
{
   UIScrollView   *scroller;
   CGPoint        offset;

   fprintf( stderr, "scroll_callback: %s\n", [button cStringDescription]);

   scroller = (UIScrollView *) [[button superview] superview];
   assert( [scroller isKindOfClass:[UIScrollView class]]);

   offset    = [scroller contentOffset];
   offset.y += 10;
   [scroller setContentOffset:offset];

   return( nil);
}


@implementation UIView( MouseMotion)

- (UIEvent *) mouseDragged:(UIEvent *) event 
{
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, CGPointCStringDescription( [event mousePosition]));
   return( nil);
}

- (UIEvent *) mouseEntered:(UIEvent *) event 
{
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, CGPointCStringDescription( [event mousePosition]));
   return( nil);
}

- (UIEvent *) mouseMoved:(UIEvent *) event 
{
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, CGPointCStringDescription( [event mousePosition]));
   return( nil);
}

- (UIEvent *) mouseExited:(UIEvent *) event 
{
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, CGPointCStringDescription( [event mousePosition]));
   return( nil);
}

@end


static void   draw_bezier( NVGcontext *vg, CGRect frame, struct MulleFrameInfo *info)
{
   MulleQuadraticBezier   bezier;
   CGPoint                point;
   CGFloat                t;
   void                   (*f)( NVGcontext *, float, float);

   frame.origin.x    += 10;
   frame.origin.y    += 10;
   frame.size.width  -= 10 * 2;
   frame.size.height -= 10 * 2;

   nvgBeginPath( vg);
   nvgRoundedRect( vg, frame.origin.x, 
                       frame.origin.y, 
                       frame.size.width, 
                       frame.size.height, 
                       10);
   nvgFillColor(vg, getNVGColor( 0x5F7F5FFF));
   nvgFill( vg);

//   fprintf( stderr, "%u: %s\n", info->renderFrame, CGRectCStringDescription( frame));

   MulleQuadraticBezierInit( &bezier, CGPointMake( 0.0, 0.0),
                                      CGPointMake( 0.33, 0.66),
                                      CGPointMake( 0.66, 0.33),
                                      CGPointMake( 1.0, 1.0));

   nvgBeginPath( vg);
   f = nvgMoveTo;
   for( t = 0.0; t <= 1.0; t += 1.0 / frame.size.width)
   {
      point = MulleQuadraticBezierGetPointForNormalizedDistance( &bezier, t);

      assert( point.x >= 0 && point.x <= 1.0);
      assert( point.y >= 0 && point.y <= 1.0);

      point.x = frame.origin.x + point.x * frame.size.width;
      point.y = frame.origin.y + point.y * frame.size.height;
      (*f)( vg, point.x, point.y);
      f = nvgLineTo;


//      fprintf( stderr, "%.2f: %s\n", t, CGPointCStringDescription( point));
   }
   nvgStrokeColor(vg, getNVGColor( 0xFF0000FF));
   nvgStroke( vg);
}                                                               


// scale stuff for stream
#define SCALE     2.0

int   main()
{
   CGContext            *context;
   CGRect               bounds;
   CGRect               frame;
   MulleBitmapImage     *sealieBitmap;
   MulleBitmapImage     *turtleBitmap;
   MulleBitmapImage     *viechBitmap;
   MulleImageLayer      *sealieLayer;
   MulleImageLayer      *turtleLayer;
   MulleImageLayer      *turtleLayer2;
   MulleImageLayer      *viechLayer;
   MulleSVGImage        *tigerSVGImage;
   MulleSVGLayer        *shiftedTigerLayer;
   MulleSVGLayer        *tigerLayer;
   UIApplication        *application;
   UIButton             *button;
   UIButton             *inScrollerButton;
   UIButton             *insideButton;
   UIButton             *nestedButton;
   UILabel              *label;
   UIScrollView         *scroller;
   UISegmentedControl   *segmentedControl;
   UISlider             *slider;
   UIStepper            *stepper;
   UISwitch             *checkbox;
   UIView               *view0;
   UIView               *view1;
   UIWindow             *window;
   CALayer              *layer;

   /* 
    * window and app 
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, W * SCALE, H * SCALE)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   view0 = [[[UIView alloc] initWithFrame:CGRectMake( 100, 100, 400, 200)] autorelease];
   layer = [view0 layer];
   [layer setBackgroundColor:getNVGColor( 0x7F7F7F7F)];
   [layer setBorderColor:getNVGColor( 0xFFFFFFFF)];
   [layer setBorderWidth:4.0];
   [layer setDrawContentsCallback:draw_bezier];

   [UIView beginAnimations:NULL
                   context:NULL];
   {
      [layer setBackgroundColor:getNVGColor( 0x00FF00FF)];
      [layer setFrame:CGRectMake( 0, 0, 600, 400)];
      [layer setBorderColor:getNVGColor( 0xFF0000FF)];
      [layer setBorderWidth:40.0];
      [layer setCornerRadius:30.0];
      [UIView setAnimationRepeatCount:-1.0];
      [UIView setAnimationRepeatAutoreverses:YES];
      [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
   }
   [UIView commitAnimations];

   [window addSubview:view0];
 
   /*
    * view placement in window 
    */

   context = [[CGContext new] autorelease];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

