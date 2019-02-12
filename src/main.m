#import "import-private.h"

#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"
#import "MulleBitmapImage.h"
#import "MulleBitmapLayer.h"
#import "CGContext.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UIScrollView.h"
#import "UIEvent.h"
#import <string.h>


//	stolen from catgl ©2015,2018 Yuichiro Nakada
#define W  200
#define H  100

#include "tiger-svg.inc"
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

   scroller = [button superview];
   assert( [scroller isKindOfClass:[UIScrollView class]]);

   offset    = [scroller contentOffset];
   offset.y += 10;
   [scroller setContentOffset:offset];

   return( nil);
}


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
   UIButton           *insideButton;
   UIButton           *nestedButton;
   UIButton           *inScrollerButton;
   UIScrollView       *scroller;
   UIApplication      *application;

   tigerSVGImage = [[[MulleSVGImage alloc] initWithBytes:svginput
                                          length:strlen( svginput) + 1] autorelease];
   fprintf( stderr, "tigerSVGImage: %p\n", tigerSVGImage);

   tigerLayer = [[[MulleSVGLayer alloc] initWithSVGImage:tigerSVGImage] autorelease];
   [tigerLayer setCStringName:"tiger"];
   fprintf( stderr, "layer: %p\n", tigerLayer);

   shiftedTigerLayer = [[[MulleSVGLayer alloc] initWithSVGImage:tigerSVGImage] autorelease];
   [shiftedTigerLayer setCStringName:"shiftedTiger"];
   fprintf( stderr, "layer: %p\n", shiftedTigerLayer);


   // layer = [[[CALayer alloc] init] autorelease];

   frame.origin       = CGPointMake( 0.0, 0.0);
   frame.size.width   = 320;
   frame.size.height  = 200;
   [tigerLayer setFrame:frame];
 //  [layer setBounds:CGRectMake( 0.0, 0.0, 200, 30)];
   [tigerLayer setBackgroundColor:getNVGColor( 0xFFE0D0D0)];
   [tigerLayer setBorderColor:getNVGColor( 0xFF30FF80)];
   [tigerLayer setBorderWidth:32.0f];
   [tigerLayer setCornerRadius:16.0f];

   frame.origin = CGPointMake( 320, 200);
   [shiftedTigerLayer setFrame:frame];

   bounds = [shiftedTigerLayer bounds];
   bounds.origin.x = -bounds.size.width / 2.0;
   [shiftedTigerLayer setBounds:bounds];
   [shiftedTigerLayer setBackgroundColor:getNVGColor( 0x407040FF)];


   viechBitmap = [[[MulleBitmapImage alloc] initWithConstBytes:viech_bitmap
                                                     bitmapSize:viech_bitmap_size]
                                                  autorelease];
   fprintf( stderr, "viechBitmapImage: %p\n", viechBitmap);

   sealieBitmap = [[[MulleBitmapImage alloc] initWithConstBytes:sealie_bitmap
                                                     bitmapSize:sealie_bitmap_size]
                                                  autorelease];
   fprintf( stderr, "sealieBitmapImage: %p\n", sealieBitmap);

   turtleBitmap = [[[MulleBitmapImage alloc] initWithConstBytes:turtle_bitmap
                                                     bitmapSize:turtle_bitmap_size]
                                                  autorelease];
   fprintf( stderr, "turtleBitmapImage: %p\n", turtleBitmap);


   viechLayer = [[[MulleBitmapLayer alloc] initWithBitmapImage:viechBitmap] autorelease];
   [viechLayer setCStringName:"viech"];
   frame.origin       = CGPointMake( 320.0, 0.0);
   frame.size.width   = 320;
   frame.size.height  = 200;
   [viechLayer setFrame:frame];
   fprintf( stderr, "layer: %p\n", viechLayer);

   sealieLayer = [[[MulleBitmapLayer alloc] initWithBitmapImage:sealieBitmap] autorelease];
   [sealieLayer setCStringName:"sealie"];
   frame.origin       = CGPointMake( 30.0, 2.0);
   frame.size.width   = 102;
   frame.size.height  = 100;
   [sealieLayer setFrame:frame];
   fprintf( stderr, "layer: %p\n", sealieLayer);

   turtleLayer = [[[MulleBitmapLayer alloc] initWithBitmapImage:turtleBitmap] autorelease];
   [turtleLayer setCStringName:"turtle"];
   frame.origin       = CGPointMake( -50.0, 10.0);
   frame.size.width   = 100;
   frame.size.height  = 117;
   [turtleLayer setFrame:frame];
   fprintf( stderr, "layer: %p\n", turtleLayer);

   /*
    * window and app 
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 640.0, 400.0)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   context = [CGContext new];

   /*
    * view placement in window 
    */
   view = [[[UIView alloc] initWithLayer:tigerLayer] autorelease];
   [window addSubview:view];

   view = [[[UIView alloc] initWithLayer:shiftedTigerLayer] autorelease];
   [window addSubview:view];

   button = [[[UIButton alloc] initWithLayer:viechLayer] autorelease];
   // [button setClipsSubviews:YES];
   [button setClick:button_callback];
   [button setDisabled:YES];
   [window addSubview:button];

   insideButton = [[[UIButton alloc] initWithLayer:sealieLayer] autorelease];
   // [insideButton setClipsSubviews:YES];
   [insideButton setClick:button_callback];
   [button addSubview:insideButton];

   nestedButton = [[[UIButton alloc] initWithLayer:turtleLayer] autorelease];
   [nestedButton setBackgroundImage:turtleBitmap
                           forState:UIControlStateNormal];
   [nestedButton setBackgroundImage:viechBitmap
                           forState:UIControlStateSelected];

   // [insideButton setClipsSubviews:YES];
   [nestedButton setClick:button_callback];
   [insideButton addSubview:nestedButton];


   frame    = CGRectMake( 0.0, 200.0, 320.0, 200.0);
   scroller = [[[UIScrollView alloc] initWithFrame:frame] autorelease];
   [window addSubview:scroller];

   // another turtleLayer
   turtleLayer2 = [[[MulleBitmapLayer alloc] initWithBitmapImage:turtleBitmap] autorelease];
   [turtleLayer2 setCStringName:"turtle2"];
   frame.origin       = CGPointMake( 0.0, 0.0);
   frame.size.width   = 320;
   frame.size.height  = 400;
   [turtleLayer2 setFrame:frame];
   fprintf( stderr, "layer: %p\n", turtleLayer2);

   inScrollerButton = [[[UIButton alloc] initWithLayer:turtleLayer2] autorelease];
   [inScrollerButton setBackgroundImage:turtleBitmap
                               forState:UIControlStateNormal];
   [inScrollerButton setBackgroundImage:sealieBitmap
                               forState:UIControlStateSelected];

   // [insideButton setClipsSubviews:YES];
   [inScrollerButton setClick:scroll_callback];
   [scroller addSubview:inScrollerButton];

   [window dump];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

