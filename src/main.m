#import "import-private.h"

#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"
#import "MulleBitmapImage.h"
#import "MulleBitmapLayer.h"
#import "CGContext.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UIView+Yoga.h"
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

   scroller = [[button superview] superview];
   assert( [scroller isKindOfClass:[UIScrollView class]]);

   offset    = [scroller contentOffset];
   offset.y += 10;
   [scroller setContentOffset:offset];

   return( nil);
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
    [[root mainLayer] setBackgroundColor:getNVGColor( 0xFF0000FF)]; // red
    [[root mainLayer] setCStringName:"root"];
    [window addSubview:root];

    yoga = [root yoga];
    [yoga setEnabled:YES];
    [yoga setFlexWrap:YGWrapWrap];
    [yoga setFlexDirection:YGFlexDirectionRow];
    [yoga setWidth:YGPointValue([root bounds].size.width)];
    [yoga setHeight:YGPointValue([root bounds].size.height)];
//    [yoga setAlignItems:YGAlignCenter];
//    [yoga setJustifyContent:YGJustifyCenter];

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
       [[child1 mainLayer] setBackgroundColor:nvgRGBA( c, c, c, 0xFF)];  // blue
       sprintf( name, "child%d", i + 1);
       [[child1 mainLayer] setCStringName:name];
       [root addSubview:child1];
       yoga = [child1 yoga];
       [yoga setEnabled:YES];
       [yoga setFlexShrink:1.0];  // must be set. Not default 1.0
       [yoga setPosition:YGPositionTypeRelative];
//       [yoga setMinWidth:YGPointValue(190)];
       [yoga setHeight:YGPointValue(190)];
    }

//    /* CHILD 2 */
//    frame = CGRectMake( 0.0, 0.0, 100.0, 100.0);
//    child2 = [[[UIView alloc] initWithFrame:frame] autorelease];
//    [[child2 mainLayer] setBackgroundColor:getNVGColor( 0x00FF00FF)];  // green
//    [[child2 mainLayer] setCStringName:"child2"];
//    [root addSubview:child2];
//
//    yoga = [child2 yoga];
//    [yoga setEnabled:YES];
//    [yoga setPosition:YGPositionTypeRelative];
//    [yoga setWidth:YGPointValue(100)];
//    [yoga setHeight:YGPointValue(100)];
//
//    [yoga setHeight:YGPointValue(100)];
//
   /* CHILD 2 */
   frame = CGRectMake( 200.0, 200.0, 220.0, 100.0);
   child2 = [[[UIView alloc] initWithFrame:frame] autorelease];
   [[child2 mainLayer] setBackgroundColor:getNVGColor( 0x00FF00FF)]; // green
   [[child2 mainLayer] setCStringName:"*child2"];
   yoga = [child2 yoga];
   [yoga setEnabled:YES];
   [yoga setPosition:YGPositionTypeRelative];
   [yoga setFlexShrink:1.0];  // must be set. Not default 1.0
   [root addSubview:child2];

   /* CHILD 3 */
   frame = CGRectMake( 50.0, 0.0, 100.0, 100.0);
   child3 = [[[UIView alloc] initWithFrame:frame] autorelease];
   [[child3 mainLayer] setBackgroundColor:getNVGColor( 0xFFFF00FF)]; // yellow
   [[child3 mainLayer] setCStringName:"*child3"];
   [child2 addSubview:child3];

    [window dump];
    [[root yoga] applyLayoutPreservingOrigin:NO];
}


int   main()
{
   CGContext       *context;
   UIWindow        *window;
   UIApplication   *application;

   /*
    * window and app 
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 640.0 * SCALE, 400.0 * SCALE)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   setupSceneInWindow( window);

   [window dump];

   context = [CGContext new];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

