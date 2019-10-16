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
#import "UIView+Yoga.h"
#import "UIScrollView.h"
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


static void   setupSceneInWindow( UIWindow *window)
{
   UIView     *root;
   UIView     *child1;
   UIView     *child2;
   UIView     *child3;
   CGRect     frame;
   YGLayout   *yoga;

   frame = [window bounds];
   assert( frame.size.width > 0.0);
   assert( frame.size.height > 0.0);

   root  = [[[UIView alloc] initWithFrame:frame] autorelease];
   [[root layer] setBackgroundColor:getNVGColor( 0xFF0000FF)]; // red
   [[root layer] setCStringName:"root"];
   [window addSubview:root];

   yoga = [root yoga];
   [yoga setEnabled:YES];
   [yoga setFlexWrap:YGWrapWrap];
   [yoga setFlexDirection:YGFlexDirectionRow];
   [yoga setWidth:YGPointValue([root bounds].size.width)];
   [yoga setHeight:YGPointValue([root bounds].size.height)];
   [yoga setAlignItems:YGAlignCenter];
   [yoga setJustifyContent:YGJustifyCenter];

#define N_TILES 19

   NSUInteger   i;
   uint8_t      c;
   char         name[ N_TILES];

   /* CHILD 1 */
   for( i = 0; i < N_TILES; i++)
   {
      frame = CGRectMake( 0.0, 0.0, 220.0, 1.0);
      child1 = [[[UIView alloc] initWithFrame:frame] autorelease];
      c = i ? (230 / N_TILES * i) + 20 : 0;
      [[child1 layer] setBackgroundColor:nvgRGBA( c, c, c, 0xFF)];  // blue
      sprintf( name, "child%ld", (long) i + 1);
      [[child1 layer] setCStringName:name];
      [root addSubview:child1];
      yoga = [child1 yoga];
      [yoga setEnabled:YES];
      [yoga setFlexShrink:1.0];  // must be set. Not default 1.0
      [yoga setPosition:YGPositionTypeRelative];
//      [yoga setMinWidth:YGPointValue(190)];
      [yoga setHeight:YGPointValue(190)];
   }

   /* CHILD 2 */
   frame = CGRectMake( 200.0, 200.0, 220.0, 100.0);
   child2 = [[[UIView alloc] initWithFrame:frame] autorelease];
   [[child2 layer] setBackgroundColor:getNVGColor( 0x00FF00FF)]; // green
   [[child2 layer] setCStringName:"*child2"];
   yoga = [child2 yoga];
   [yoga setEnabled:YES];
   [yoga setPosition:YGPositionTypeRelative];
   [yoga setFlexShrink:1.0];  // must be set. Not default 1.0
   [root addSubview:child2];

   /* CHILD 3 */
   frame = CGRectMake( 50.0, 0.0, 100.0, 100.0);
   child3 = [[[UIView alloc] initWithFrame:frame] autorelease];
   [[child3 layer] setBackgroundColor:getNVGColor( 0xFFFF00FF)]; // yellow
   [[child3 layer] setCStringName:"*child3"];
   [child2 addSubview:child3];

   [root setNeedsLayout];
}


int  main()
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

   setupSceneInWindow( window);

   [window dump];

   context = [[CGContext new] autorelease];
#if 0
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
 #endif
   /*
    * view placement in window 
    */

   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

