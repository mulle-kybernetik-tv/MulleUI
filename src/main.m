#import "import-private.h"

#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"
#import "MulleBitmapImage.h"
#import "MulleBitmapLayer.h"
#import "CGContext.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UILabel.h"
#import "UISwitch.h"
#import "UISlider.h"
#import "UIScrollView.h"
#import "UIEvent.h"
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
#define SCALE     2.0

int   main()
{
   MulleSVGLayer      *tigerLayer;
   MulleSVGLayer      *shiftedTigerLayer;
   MulleBitmapLayer   *viechLayer;
   MulleBitmapLayer   *sealieLayer;
   MulleBitmapLayer   *turtleLayer;
   MulleBitmapLayer   *turtleLayer2;
   MulleSVGImage      *tigerSVGImage;
   MulleBitmapImage   *viechBitmap;
   MulleBitmapImage   *sealieBitmap;
   MulleBitmapImage   *turtleBitmap;
   CGRect             frame;
   CGRect             bounds;
   CGContext          *context;
   UIWindow           *window;
   UIView             *view;
   UIButton           *button;
   UILabel            *label;
   UIButton           *insideButton;
   UIButton           *nestedButton;
   UIButton           *inScrollerButton;
   UIScrollView       *scroller;
   UIApplication      *application;
   UISwitch           *checkbox;
   UISlider           *slider;

   tigerSVGImage = [[[MulleSVGImage alloc] initWithBytes:svginput
                                          length:strlen( svginput) + 1] autorelease];
   fprintf( stderr, "tigerSVGImage: %p\n", tigerSVGImage);

   tigerLayer = [[[MulleSVGLayer alloc] initWithSVGImage:tigerSVGImage] autorelease];
   [tigerLayer setCStringName:"tiger"];
   fprintf( stderr, "layer: %p\n", tigerLayer);


   // layer = [[[CALayer alloc] init] autorelease];

   frame.origin       = CGPointMake( 0.0 * SCALE, 0.0 * SCALE);
   frame.size.width   = 160 * SCALE;
   frame.size.height  = 100 * SCALE;

   [tigerLayer setFrame:frame];
 //  [layer setBounds:CGRectMake( 0.0, 0.0, 200, 30)];
   [tigerLayer setBackgroundColor:getNVGColor( 0xFFE0D0D0)];
   [tigerLayer setBorderColor:getNVGColor( 0xFF30FF80)];
   [tigerLayer setBorderWidth:32.0f];
   [tigerLayer setCornerRadius:16.0f];

   viechBitmap = [[[MulleBitmapImage alloc] initWithConstBytes:viech_bitmap
                                                    bitmapSize:viech_bitmap_size]
                                                       autorelease];
   fprintf( stderr, "viechBitmap: %p\n", viechBitmap);

   turtleBitmap = [[[MulleBitmapImage alloc] initWithConstBytes:turtle_bitmap
                                                     bitmapSize:turtle_bitmap_size]
                                                  autorelease];
   fprintf( stderr, "turtleBitmapImage: %p\n", turtleBitmap);

   turtleLayer = [[[MulleBitmapLayer alloc] initWithBitmapImage:turtleBitmap] autorelease];
   [turtleLayer setCStringName:"turtle"];
   frame.origin = CGPointMake( 0.0 * SCALE, 100.0  * SCALE);
   frame.size.width  = turtle_bitmap_size.size.width  * SCALE;
   frame.size.height = turtle_bitmap_size.size.height  * SCALE;
   [turtleLayer setFrame:frame];
   fprintf( stderr, "layer: %p\n", turtleLayer);

   /*
    * window and app 
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 640.0 * SCALE, 400.0 * SCALE)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   context = [CGContext new];

   /*
    * view placement in window 
    */
   view = [[[UIView alloc] initWithLayer:tigerLayer] autorelease];
   [window addSubview:view];


   nestedButton = [[[UIButton alloc] initWithLayer:turtleLayer] autorelease];
   [nestedButton setBackgroundImage:turtleBitmap
                           forState:UIControlStateNormal];
   [nestedButton setBackgroundImage:viechBitmap
                           forState:UIControlStateSelected];

   // [insideButton setClipsSubviews:YES];
   [nestedButton setClick:button_callback];
   [window addSubview:nestedButton];

   frame.origin      = CGPointMake( turtle_bitmap_size.size.width * SCALE, 100.0 * SCALE);
   frame.size.width  = 500;
   frame.size.height = 100;

   label = [[[UILabel alloc] initWithFrame:frame] autorelease];

   // [insideButton setClipsSubviews:YES];
   [label setCString:"VfL Bochum 1848"];
   [label setFontName:"sans"];
   [label setFontSize:14.0 * SCALE];
   [label setBackgroundColor:getNVGColor( 0x010101FF)];
   [label setTextColor:getNVGColor( 0xFEFEFEFF)];

   [window addSubview:label];

   frame.origin      = CGPointMake( 160.0 * SCALE , 0 * SCALE);
   frame.size.width  = 200;
   frame.size.height = 100;

   checkbox = [[[UISwitch alloc] initWithFrame:frame] autorelease];

   // [insideButton setClipsSubviews:YES];
   [checkbox setCString:"Is it OK ?"];
   [checkbox setFontName:"sans"];
   [checkbox setFontSize:14.0 * SCALE];
   [checkbox setBackgroundColor:getNVGColor( 0x112141FF)];
   [checkbox setTextColor:getNVGColor( 0xFE00FEFF)];

   [window addSubview:checkbox];

   frame.origin      = CGPointMake( 160.0 * SCALE , 100.0 * SCALE);
   frame.size.width  = 200;
   frame.size.height = 100;

   slider = [[[UISlider alloc] initWithFrame:frame] autorelease];

   // [insideButton setClipsSubviews:YES];
   [slider setBackgroundColor:getNVGColor( 0x114111FF)];

   [window addSubview:slider];

   [window dump];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

