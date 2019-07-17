#import "import-private.h"

#import "CGContext.h"
#import "MulleBitmapImage.h"
#import "MulleBitmapLayer.h"
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
#define W  200
#define H  100

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
#define SCALE      1.0
#define FONT_SIZE  10

int   main()
{
   MulleSVGLayer        *tigerLayer;
   MulleSVGLayer        *shiftedTigerLayer;
   MulleBitmapLayer     *viechLayer;
   MulleBitmapLayer     *sealieLayer;
   MulleBitmapLayer     *turtleLayer;
   MulleBitmapLayer     *turtleLayer2;
   MulleSVGImage        *tigerSVGImage;
   MulleBitmapImage     *viechBitmap;
   MulleBitmapImage     *sealieBitmap;
   MulleBitmapImage     *turtleBitmap;
   CGRect               frame;
   CGRect               bounds;
   CGContext            *context;
   UIWindow             *window;
   UIView               *view;
   UIButton             *button;
   UILabel              *label;
   UIStepper            *stepper;
   UIButton             *insideButton;
   UIButton             *nestedButton;
   UIButton             *inScrollerButton;
   UISegmentedControl   *segmentedControl;
   UIScrollView         *scroller;
   UIApplication        *application;
   UISwitch             *checkbox;
   UISlider             *slider;

   /*
    * window and app 
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 400.0 * SCALE, 300.0 * SCALE)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   context = [CGContext new];

   frame.origin      = CGPointMake( 0 * SCALE, 100.0 * SCALE);
   frame.size.width  = 300;
   frame.size.height = FONT_SIZE * 1.1;

   label = [[[UILabel alloc] initWithFrame:frame] autorelease];

   // [insideButton setClipsSubviews:YES];
   [label setCString:"   XXX"];
   [label setFontName:"sans"];
   [label setFontSize:FONT_SIZE];
   [label setBackgroundColor:getNVGColor( 0xFFFFFFFF)];
   [label setTextColor:getNVGColor( 0x000000FF)];

   [window addSubview:label];

   frame.origin.y    += frame.size.height;

   label = [[[UILabel alloc] initWithFrame:frame] autorelease];

   // [insideButton setClipsSubviews:YES];
   [label setCString:"   abc"];
   [label setFontName:"sans"];
   [label setFontSize:FONT_SIZE];
   [label setBackgroundColor:getNVGColor( 0xFFFFFFFF)];
   [label setTextColor:getNVGColor( 0x000000FF)];

   [window addSubview:label];

   frame.origin.y    += frame.size.height;

   label = [[[UILabel alloc] initWithFrame:frame] autorelease];

   // [insideButton setClipsSubviews:YES];
   [label setCString:"   123"];
   [label setFontName:"sans"];
   [label setFontSize:FONT_SIZE];
   [label setBackgroundColor:getNVGColor( 0xFFFFFFFF)];
   [label setTextColor:getNVGColor( 0x000000FF)];

   [window addSubview:label];

   [window dump];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

