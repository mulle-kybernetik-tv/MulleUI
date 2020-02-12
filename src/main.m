#import "import-private.h"

#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"
#import "MulleBitmapImage.h"
#import "MulleImageLayer.h"
#import "CGContext.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UIColor.h"
#import "UIScrollView.h"
#import "UIEvent.h"
#import <string.h>


// stolen from catgl ©2015,2018 Yuichiro Nakada
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


static UIEvent   *dump_window( UIButton *button, UIEvent *event)
{
   fprintf( stderr, "dump_window: %s\n", [button cStringDescription]);

   [[button window] dump];

   return( nil);
}


// scale stuff for stream
#define SCALE     2.0

int   main()
{
   MulleSVGLayer      *tigerLayer;
   MulleSVGLayer      *shiftedTigerLayer;
   MulleImageLayer    *viechLayer;
   MulleImageLayer    *sealieLayer;
   MulleImageLayer    *turtleLayer;
   MulleImageLayer    *turtleLayer2;
   MulleSVGImage      *tigerSVGImage;
   MulleBitmapImage   *viechBitmap;
   MulleBitmapImage   *sealieBitmap;
   MulleBitmapImage   *turtleBitmap;
   CGRect             frame;
   CGRect             windowFrame;
   CGRect             bounds;
   CGContext          *context;
   UIWindow           *window;
   UIView             *view;
   UIView             *contentView;
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

   frame.origin       = CGPointMake( 0.0 * SCALE, 0.0 * SCALE);
   frame.size.width   = 320 * SCALE;
   frame.size.height  = 200 * SCALE;
   [tigerLayer setFrame:frame];
 //  [layer setBounds:CGRectMake( 0.0, 0.0, 200, 30)];
   [tigerLayer setBackgroundColor:getNVGColor( 0xFFE0D0D0)];
   [tigerLayer setBorderColor:getNVGColor( 0xFF30FF80)];
   [tigerLayer setBorderWidth:32.0f];
   [tigerLayer setCornerRadius:16.0f];

   frame.origin = CGPointMake( 320 * SCALE, 200 * SCALE);
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


   viechLayer = [[[MulleImageLayer alloc] initWithImage:viechBitmap] autorelease];
   [viechLayer setCStringName:"viech"];
   frame.origin       = CGPointMake( 320.0 * SCALE, 0.0 * SCALE);
   frame.size.width   = 320 * SCALE;
   frame.size.height  = 200 * SCALE;
   [viechLayer setFrame:frame];
   fprintf( stderr, "layer: %p\n", viechLayer);

   sealieLayer = [[[MulleImageLayer alloc] initWithImage:sealieBitmap] autorelease];
   [sealieLayer setCStringName:"sealie"];
   frame.origin       = CGPointMake( 30.0, 2.0);
   frame.size.width   = 102;
   frame.size.height  = 100;
   [sealieLayer setFrame:frame];
   fprintf( stderr, "layer: %p\n", sealieLayer);

   turtleLayer = [[[MulleImageLayer alloc] initWithImage:turtleBitmap] autorelease];
   [turtleLayer setCStringName:"turtle"];
   frame.origin       = CGPointMake( -50.0, 10.0);
   frame.size.width   = 100;
   frame.size.height  = 117;
   [turtleLayer setFrame:frame];
   fprintf( stderr, "layer: %p\n", turtleLayer);

   /*
    * window and app 
    */
   windowFrame = CGRectMake( 0.0, 0.0, 340.0 * SCALE, 220.0 * SCALE);
   window      = [[[UIWindow alloc] initWithFrame:windowFrame] autorelease];
   assert( window);

   windowFrame = CGRectMake( 1.0 * SCALE, 1.0 * SCALE, (340.0 - 2) * SCALE, (220.0 - 2) * SCALE);
   contentView = [[[UIView alloc] initWithFrame:windowFrame] autorelease];
   [contentView setBackgroundColor:[UIColor yellowColor]];
   [window addSubview:contentView];

   [[UIApplication sharedInstance] addWindow:window];

   /*
    * view placement in window 
    */
#if 0
   view = [[[UIView alloc] initWithLayer:tigerLayer] autorelease];
   [contentView addSubview:view];

   view = [[[UIView alloc] initWithLayer:shiftedTigerLayer] autorelease];
   [contentView addSubview:view];

   button = [[[UIButton alloc] initWithLayer:viechLayer] autorelease];
   // [button setClipsSubviews:YES];
   [button setClick:button_callback];
   [button setDisabled:YES];
   [contentView addSubview:button];

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
#endif

#if 1
    // another turtleLayer
   turtleLayer2 = [[[MulleImageLayer alloc] initWithImage:turtleBitmap] autorelease];
   [turtleLayer2 setCStringName:"turtle2"];
   frame.origin       = CGPointMake( 0.0 * SCALE, 0.0 * SCALE);
   frame.size.width   = 320 * SCALE * 10;
   frame.size.height  = 200 * SCALE * 10;
   [turtleLayer2 setFrame:frame];
   fprintf( stderr, "layer: %p\n", turtleLayer2);

   inScrollerButton = [[[UIButton alloc] initWithLayer:turtleLayer2] autorelease];
   [inScrollerButton setBackgroundImage:turtleBitmap
                               forState:UIControlStateNormal];
   [inScrollerButton setBackgroundImage:sealieBitmap
                               forState:UIControlStateSelected];
//   [contentView addSubview:inScrollerButton];
#endif   
#if 1
   bounds   = frame;
   frame    = CGRectMake( 10.0 * SCALE, 10.0 * SCALE, 320.0 * SCALE, 200.0 * SCALE);
   scroller = [[[UIScrollView alloc] initWithFrame:frame] autorelease];
   [scroller setContentSize:bounds.size];
   [[scroller contentView] addSubview:inScrollerButton];
   [contentView addSubview:scroller];
   [inScrollerButton setClick:dump_window];
#endif

   // [insideButton setClipsSubviews:YES];
#if 0
   [inScrollerButton setClick:scroll_callback];
   [[scroller contentView] addSubview:inScrollerButton];
#endif

   [window dump];

   context = [CGContext object];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

