#import "import-private.h"

#import "CGContext.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UIColor.h"
#import "UILabel.h"
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
   [button setTitleCString:"VfL Bochum 1848"];
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
   CGRect             frame;
   CGRect             windowFrame;
   CGRect             bounds;
   CGContext          *context;
   UIWindow           *window;
   UIView             *view;
   UIView             *contentView;
   UIApplication      *application;
   UIButton           *button;

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

   frame.origin      = CGPointMake( 100 * SCALE, 100.0 * SCALE);
   frame.size.width  = 140;
   frame.size.height = 100;

   button = [[[UIButton alloc] initWithFrame:frame] autorelease];
   [button setClick:button_callback];
   [contentView addSubview:button];

   [window dump];

   context = [CGContext object];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

