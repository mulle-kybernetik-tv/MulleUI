#import "import-private.h"

#import "CGContext.h"
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
   
   /* 
    * window and app 
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, W * SCALE, H * SCALE)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   view0 = [[[UIView alloc] initWithFrame:CGRectMake( 20, 20, 500, 300)] autorelease];
   [[view0 layer] setBackgroundColor:getNVGColor( 0x7F7F7F7F)];

   view1 = [[[UIView alloc] initWithFrame:CGRectMake( 40, 100, 420, 100)] autorelease];
   [[view1 layer] setBackgroundColor:getNVGColor( 0x7F00007F)];
   [view0 addSubview:view1];

   [window addSubview:view0];

   // must be after view was added to window
   [view1 addTrackingAreaWithRect:CGRectMake( 160, 25, 50, 50)
                         userInfo:nil];


   /*
    * view placement in window 
    */
#if 0    
   [window addTrackingAreaWithRect:CGRectMake( 20, 20, 300, 100)
                          userInfo:nil];
   [window addTrackingAreaWithRect:CGRectMake( 170, 20, 300, 100)
                          userInfo:nil];
   [window addTrackingAreaWithRect:CGRectMake( 95, 80, 300, 100)
                          userInfo:nil];
   [window addTrackingView:window];
#endif   
   [window setupQuadtree];

   [window dump];

   context = [[CGContext new] autorelease];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

