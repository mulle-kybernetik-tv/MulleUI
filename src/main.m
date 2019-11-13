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
   [yoga setWidth:YGPointValue([root bounds].size.width)];
   [yoga setHeight:YGPointValue([root bounds].size.height)];

   // https://yogalayout.com/docs/flex-wrap/
   // If wrapping is allowed items are wrapped into multiple lines along the 
   // main axis if needed. 
   [yoga setFlexWrap:YGWrapWrap];

   [yoga setFlexDirection:YGFlexDirectionRow];

   // https://yogalayout.com/docs/align-content/
   // Align wrapped lines in the center of the container's cross axis.
   // alignCenterVertically (as we are a row)
   [yoga setAlignItems:YGAlignCenter];

   // https://yogalayout.com/docs/align-content
   // 
   [yoga setAlignContent:YGAlignCenter];

   // https://yogalayout.com/docs/justify-content
   // Align children of a container in the center of the container's main axis.
   // Spacing within the line.: center sticks together in the middle 
   // alignCenterHorizontally (as we are a row)
   [yoga setJustifyContent:YGJustifyCenter];

   {
#define N_TILES 4

      NSUInteger   i;
      uint8_t      c;
      char         name[ 32];

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
   }

#if 0
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
#endif
   [root setNeedsLayout];
}


int  main()
{
   CGContext       *context;
   UIApplication   *application;
   UIWindow        *window;

   /* 
    * window and app 
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, W * SCALE, H * SCALE)] autorelease];
   assert( window);

   application = [UIApplication sharedInstance];
   [application addWindow:window];

   setupSceneInWindow( window);
   /*
    * view placement in window 
    */

   [window dump];

   context = [[CGContext new] autorelease];
   [window renderLoopWithContext:context];

   [application terminate];
}

