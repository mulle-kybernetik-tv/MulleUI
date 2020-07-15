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
   MulleImageLayer    *buttonLayer;
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

   sealieBitmap = [[[MulleBitmapImage alloc] initWithConstBytes:sealie_bitmap
                                                     bitmapSize:sealie_bitmap_size]
                                                  autorelease];

   turtleBitmap = [[[MulleBitmapImage alloc] initWithContentsOfFileWithFileRepresentationString:"/home/src/srcO/MulleUI/bengal.jpg"] autorelease];
   assert( turtleBitmap);

   // WINDOW
   windowFrame = CGRectMake( 0.0, 200.0, 340.0 * SCALE, 220.0 * SCALE);
   window      = [[[UIWindow alloc] initWithFrame:windowFrame] autorelease];
   assert( window);

   windowFrame = CGRectMake( 1.0 * SCALE, .0 * SCALE, (340.0 - 2) * SCALE, (220.0 - 2) * SCALE);
   contentView = [[[UIView alloc] initWithFrame:windowFrame] autorelease];
   [contentView setBackgroundColor:[UIColor yellowColor]];
   [window addSubview:contentView];

   [[UIApplication sharedInstance] addWindow:window];

   // BUTTON IN SCROLLVIEW
   buttonLayer = [[[MulleImageLayer alloc] initWithImage:turtleBitmap] autorelease];
   // [buttonLayer setCStringName:"button"];
   frame.origin       = CGPointMake( 0.0 * SCALE, 0.0 * SCALE);
   frame.size.width   = 320 * SCALE * 10;
   frame.size.height  = 200 * SCALE * 10;
   [buttonLayer setFrame:frame];
   fprintf( stderr, "layer: %p\n", buttonLayer);

   inScrollerButton = [[[UIButton alloc] initWithLayer:buttonLayer] autorelease];
   [inScrollerButton setBackgroundImage:turtleBitmap
                               forState:UIControlStateNormal];
   [inScrollerButton setBackgroundImage:sealieBitmap
                               forState:UIControlStateSelected];
   [inScrollerButton setClick:dump_window];
//   [contentView addSubview:inScrollerButton];

   // SCROLLVIEW
   bounds   = frame;
   frame    = CGRectMake( 10.0 * SCALE, 10.0 * SCALE, 320.0 * SCALE, 200.0 * SCALE);
   scroller = [[[UIScrollView alloc] initWithFrame:frame] autorelease];
   [scroller setZoomEnabled:YES];
   [scroller setContentSize:bounds.size];
   [[scroller contentView] addSubview:inScrollerButton];
   [contentView addSubview:scroller];

   [window dump];

   context = [CGContext object];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

