#import "import-private.h"

#import "CALayer.h"
#import "CGContext.h"
#import "UIWindow.h"
#import "UIColor.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UIStackView.h"
#import "UIScrollView.h"
#import "MulleBitmapImage.h"
#import "MulleMenu.h" // rename to MulleMenuView.h
#import "MulleMenuButton.h"
#import "UIView+Layout.h"
#import "NSValue+CGGeometry.h"
#import "UIEvent.h"
#import <string.h>


static MulleBitmapImage      *bengalBitmap;
static MulleBitmapImage      *patternBitmap;

static char   *javascript = "quadcurve.js";

void  drawStuff( CALayer *layer,
                 CGContext *context,
                 CGRect frame,
                 struct MulleFrameInfo *info)
{
   CGRect              rect;
   MulleJS             *js;
   struct NVGcontext   *nvg;
   CGSize              size;
   char                *filename;

   nvg = MulleContextGetNVGContext( context);

   // clip javascript drawing
   nvgScissor( nvg, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
   nvgTranslate( nvg, frame.origin.x, frame.origin.y);

   @autoreleasepool
   {
      [context fontWithName:"sans"];
      js = [MulleJS object];
      [js setObject:context
             forKey:@"CGContext"];
      [js setObject:[NSValue valueWithPointer:nvg]
             forKey:@"nvgContext"];
      [js setObject:bengalBitmap
             forKey:@"bengal"];
      [js setObject:patternBitmap
             forKey:@"pattern"];
      [js setObject:@(frame.size.width)
             forKey:@"width"];
      [js setObject:@(frame.size.height)
             forKey:@"height"];
      [js setObject:[UIColor mulleValueWithCGColor:[(id) layer backgroundColor]]
             forKey:@"backgroundColor"];

      filename = MulleObjC_asprintf( "/home/src/srcO/MulleUI/src/%s", javascript);
      [js runScriptFileCString:filename];
   }
}

static MulleMenu   *menu;

static UIEvent   *showMenu( id <UIControl> control, UIEvent *event)
{
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);

   assert( menu);

   [menu setHidden:NO];
   return( nil);
}


static UIEvent   *buttonClicked( id <UIControl> control, UIEvent *event)
{
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);

   javascript = [control titleCString];
   [menu setHidden:YES];
   return( nil);
}

static UIEvent   *menuOutsideClicked( id <UIControl> control, UIEvent *event)
{
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);

   [menu setHidden:YES];
   return( nil);
}


static void   setupSceneInContentPlane( MulleWindowPlane *contentPlane)
{
   UIView             *rootView;
   UIView             *displayView;
   MulleMenu          *menuView;
   UIButton           *button;
   MulleMenuButton    *menuButton;
   MulleWindowPlane   *menuPlane;
   CALayer            *layer;
   CGRect             frame;
   int                i;
   UIWindow           *window;

   window    = [contentPlane window];
   menuPlane = [window menuPlane];

   frame = [contentPlane bounds];
   assert( frame.size.width > 0.0);
   assert( frame.size.width  > 0.0);

   rootView  = [UIView mulleViewWithFrame:CGRectZero];
   [rootView setCStringName:"RootView"];
   [rootView setBackgroundColor:getNVGColor( 0xFFFFFFFF)];
   [rootView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];

   // LCD Display container
   // because the root view is still zero sized, the -10.2 as size is really
   // the margin. The 100 is the height of the display

   displayView  = [UIView mulleViewWithFrame:CGRectZero];
   [displayView setBackgroundColor:getNVGColor( 0x00007FFF)];
   [displayView setCStringName:"DisplayView"];
   [displayView setMargins:UIEdgeInsetsMake( 10, 10, 10, 10)];
   [displayView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];

   layer = [displayView layer];
   [displayView setDrawContentsCallback:drawStuff];
   [rootView addSubview:displayView];

   button  = [UIButton mulleViewWithFrame:CGRectMake( 0, 0, 120, 20)];
   [button setTitleCString:"Change"];
   [button setMargins:UIEdgeInsetsMake( 0, 0, 10, 10)];
   [button setAutoresizingMask:MulleUIViewAutoresizingStickToBottom|MulleUIViewAutoresizingStickToRight];
   [button setClick:showMenu];
   [displayView addSubview:button];


   menuView = [MulleMenu mulleViewWithFrame:CGRectMake( 0, 0, 200, 75)];
   [menuView setAutoresizingMask:MulleUIViewAutoresizingStickToBottom|MulleUIViewAutoresizingStickToRight];
   [menuView setMargins:UIEdgeInsetsMake( 0, 0, 10, 50)];
   [menuView setClick:menuOutsideClicked];
   [menuView setHidden:YES];

   menu = menuView;

   for( i = 0; i < 5; i++)
   {
      static char  *titles[] =
      {
         "quadcurve.js",
         "donutpie.js",
         "pie-chart-demo.js",
         "colorsandlines.js",
         "drawings.js"
      };
      menuButton = [MulleMenuButton mulleViewWithFrame:CGRectMake( 0, 0, 0, 20)];
      [menuButton setTitleCString:titles[ i]];
      [menuButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
      [menuButton setClick:buttonClicked];
      /* TODO: Tricky, if the button resizes then the tracking area must also
               resize. BUT, it's not really dynamic yet.
       */
      [menuButton addTrackingAreaWithRect:CGRectMake( 0, 0, 200, 20)
                                 toWindow:window
                                 userInfo:nil];
      [menuView addMenuButton:menuButton];
   }
   [menuPlane addSubview:menuView];
   [menuPlane setNeedsLayout];
   [menuPlane setHidden:NO];

   [rootView setNeedsLayout];

   [contentPlane addSubview:rootView];
}


int  main()
{
   CGContext       *context;
   UIWindow        *window;
   UIApplication   *application;
   MulleJS         *js;
      /*
       * window and app
       */

   /* move singleton outside of test allocator code */
   application = [UIApplication sharedInstance];

   mulle_testallocator_initialize();
   mulle_default_allocator = mulle_testallocator;

   @autoreleasepool
   {
      bengalBitmap   = [[[MulleBitmapImage alloc] initWithContentsOfFileWithFileRepresentationString:"/home/src/srcO/MulleUI/bengal_s.jpg"] autorelease];
      patternBitmap = [[[MulleBitmapImage alloc] initWithContentsOfFileWithFileRepresentationString:"/home/src/srcO/MulleUI/pattern.png"] autorelease];

      window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 729.00, 449.00)] autorelease];
      assert( window);

      [application addWindow:window];

      setupSceneInContentPlane( [window contentPlane]);

      [window dump];

      context = [[CGContext new] autorelease];
      [window renderLoopWithContext:context];

      [application terminate];
   }

   /*
      Hunt for leaks:

      MULLE_OBJC_EPHEMERAL_SINGLETON=YES \
      MULLE_OBJC_TRACE_INSTANCE=YES \
      MULLE_OBJC_TRACE_METHOD_CALL=YES \
      MULLE_TESTALLOCATOR_TRACE=2 \
         ./kitchen/Debug/calculator
   */

   mulle_testallocator_reset();
  }

