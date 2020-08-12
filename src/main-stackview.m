#import "import-private.h"

#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"
#import "MulleBitmapImage.h"
#import "CGContext.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UIStackView.h"
#import "UIScrollView.h"
#import "UIView+Layout.h"
#import "UIEvent.h"
#import <string.h>


static UIEvent   *button_callback( UIButton *button, UIEvent *event)
{
   fprintf( stderr, "button_callback: %s\n", [button cStringDescription]);
   return( nil);
}

#define N_ROWS 5
#define N_COLS 5 //

static void   setupSceneInContentPlane( MulleWindowPlane *contentPlane)
{
   UIStackView   *rootView;
   UIStackView   *stackView;
   UIView        *view;
   CGRect        frame;
   NSUInteger    i;
   NSUInteger    j;
   char          name[ 100];

   frame = [contentPlane bounds];
   assert( frame.size.width > 0.0);
   assert( frame.size.width  > 0.0);

   rootView  = [[[UIStackView alloc] initWithFrame:CGRectZero] autorelease];
   [rootView setCStringName:"RootView"];
   [rootView setBackgroundColor:getNVGColor( 0xFFFF00FF)]; 
   [rootView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
   [rootView setAxis:UILayoutConstraintAxisVertical];
   [rootView setDistribution:UIStackViewDistributionFillEqually];

   // LCD Display container
   // because the root view is still zero sized, the -10.2 as size is really
   // the margin. The 100 is the height of the display

   for( j = 0; j <= UIStackViewDistributionEqualCentering; j++)
   {
      frame = CGRectMake( 0, 0, 0, 0);
      stackView = [[[UIStackView alloc] initWithFrame:CGRectZero] autorelease];
      [stackView setBackgroundColor:MulleColorCreateRandom( 0x0000FFFF, 0xFFFF0000)]; // blue

      // determine own geometry, take up all space that is given
      [stackView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
      // center in  window  with some margin
      [stackView setMargins:UIEdgeInsetsMake( 10, 10, 10, 10)];
      [rootView addSubview:stackView];

      //
      // available space for row view is made smaller to have a border around them
      // leaving space at the bottom, so that the last demoView with a "wrong"
      // bottom margin can expand there
      //
      [stackView setDistribution:j];
      [stackView setContentInsets:UIEdgeInsetsMake( 10, 10, 10, 10)];
      [stackView setCStringName:"stackView"];
      [stackView setAlignment:UIStackViewAlignmentCenter];
      [stackView setAxis:UILayoutConstraintAxisHorizontal];

      MulleColorCreateRandom( 0xFF0000FF, 0x00FFFF00);
      /* CHILD 1 */
      for( i = 0; i < N_COLS; i++)
      {
         // create a row view (transparent though)
         frame = CGRectMake( 0, 0, 48 + i * 16, 48);
         view  = [[[UIView alloc] initWithFrame:frame] autorelease];
         [view setBackgroundColor:MulleColorCreateRandom( 0xFF0000FF, 0x00FFFF00)];
   //      if( i == 2)
   //         [view setAutoresizingMask:MulleUIViewAutoresizingStickToBottom|MulleUIViewAutoresizingStickToRight];
   //      if( i == 3)
   //         [view setAutoresizingMask:MulleUIViewAutoresizingStickToTop|MulleUIViewAutoresizingStickToRight];
   //      if( i == 1)
   //         [view setAutoresizingMask:MulleUIViewAutoresizingStickToCenter|UIViewAutoresizingFlexibleWidth];

         [stackView addSubview:view];
      }
   }

   [rootView setNeedsLayout];

   [contentPlane addSubview:rootView];
   [contentPlane setNeedsLayout];
}


int  main()
{
   CGContext       *context;
   UIWindow        *window;
   UIApplication   *application;

      /*
       * window and app 
       */

   /* move singleton outside of test allocator code */
   application = [UIApplication sharedInstance];

   mulle_testallocator_initialize();
   mulle_default_allocator = mulle_testallocator;

   @autoreleasepool
   {
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

