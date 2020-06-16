#import "import-private.h"


#import "CGContext.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UIStackView.h"
#import "UIView+Layout.h"
#import "UIEvent.h"
#import <string.h>



#define N_SUBVIEWS  10

static void   setupSceneInContentPlane( MulleWindowPlane *contentPlane)
{
   UIStackView          *rootView;
   UIView               *view;
   CGRect               frame;
   NSUInteger           i;
   NSUInteger           j;
   char                 name[ 100];

   frame = [contentPlane bounds];
   assert( frame.size.width > 0.0);
   assert( frame.size.width  > 0.0);

   rootView  = [[[UIStackView alloc] initWithFrame:CGRectMake( 0, 0, 256, 256)] autorelease];
   [rootView setCStringName:"rowColumnView"];
   [rootView setBackgroundColor:getNVGColor( 0xFFFF00FF)]; 
   [rootView setAutoresizingMask:MulleUIViewAutoresizingStickToCenter];
   [rootView setAxis:UILayoutConstraintAxisVertical];
   [rootView setDistribution:MulleStackViewDistributionFillRowColumn];
   [rootView setContentInsets:UIEdgeInsetsMake( 10, 10, 10, 10)];

   MulleColorCreateRandom( 0xFF0000FF, 0x00FFFF00);
   /* CHILD 1 */
   for( i = 0; i < N_SUBVIEWS; i++)
   {
      frame = CGRectMake( 0, 0, 8 + i * 8, 8 + i * 8);
      view  = [[[UIView alloc] initWithFrame:frame] autorelease];
      [view setBackgroundColor:MulleColorCreateRandom( 0xFF0000FF, 0x00FFFF00)];

      [rootView addSubview:view];
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

