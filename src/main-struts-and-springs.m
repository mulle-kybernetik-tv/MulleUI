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
   UIView        *rootView;
   UIView        *displayView;
   UIStackView   *keyboardView;
   UIStackView   *rowView;
   UIView        *view;
   CGRect        frame;
   NSUInteger    i;
   NSUInteger    j;
   char          name[ 100];

   frame = [contentPlane bounds];
   assert( frame.size.width > 0.0);
   assert( frame.size.width  > 0.0);

   rootView  = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
   [rootView setCStringName:"RootView"];
   [rootView setBackgroundColor:getNVGColor( 0xFFFF00FF)]; 
   [rootView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];

   // LCD Display container
   // because the root view is still zero sized, the -10.2 as size is really
   // the margin. The 100 is the height of the display
   frame = CGRectMake( 0, 0, 0, 100);

   displayView  = [[[UIView alloc] initWithFrame:frame] autorelease];
   [displayView setBackgroundColor:getNVGColor( 0xFF7F7FFF)]; 
   [displayView setCStringName:"DisplayView"];
   [displayView setMargins:UIEdgeInsetsMake( 10, 10, 0, 10)];
   [displayView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
   [rootView addSubview:displayView];

   // Keyboard container
   // Offset 120 pixels from the top, therefore 20 margin from keyboard
   // the margin. Reduced by the height of the display and bottom margins
   frame = CGRectMake( 0, 0, 0, 0);
   keyboardView = [[[UIStackView alloc] initWithFrame:CGRectZero] autorelease];
   [keyboardView setBackgroundColor:getNVGColor( 0x0000FFFF)]; // blue

   // determine own geometry, take up all space that is given
   [keyboardView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
   // move below displayView and have 10 distance to root view
   [keyboardView setMargins:UIEdgeInsetsMake( 120, 10, 10, 10)];

   //
   // available space for row view is made smaller to have a border around them
   // leaving space at the bottom, so that the last rowView with a "wrong"
   // bottom margin can expand there
   //
   [keyboardView setContentInsets:UIEdgeInsetsMake( 10, 10, 0, 10)];
   [keyboardView setCStringName:"KeyboardView"];

   [rootView addSubview:keyboardView];

   /* CHILD 1 */
   for( i = 0; i < N_ROWS; i++)
   {
      // create a row view (transparent though)
      frame = CGRectMake( 0, 0, 0, 0);
      rowView  = [[[UIStackView alloc] initWithFrame:frame] autorelease];
      [rowView setBackgroundColor:MulleColorCreateRandom( 0xFF0000FF, 0x00FFFF00)];

      // determine own geometry, take up all space that is given
      [rowView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
      // if every rowview has the same margins, they will get evenly 
      // autosized (if flexible) as available space is calculated the same 
      // we want 10 distance, we get 10 distance on the bottom for free from
      // the container
      [rowView setMargins:UIEdgeInsetsMake( 0, 0, 10, 0)];

      // specify settings for kids, have 20 margin on the left an right
      // and a pixel on top (gratuitously for testing)
      // 
      [rowView setContentInsets:UIEdgeInsetsMake( 1, 20, 1, 0)];
      [rowView setAxis:UILayoutConstraintAxisHorizontal];

      [keyboardView addSubview:rowView];

      for( j = 0; j < N_COLS; j++)
      {
         // create actual views
         frame = CGRectMake( 0, 0, 0, 0);
         view  = [[[UIButton alloc] initWithFrame:frame] autorelease];
         [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
         [view setMargins:UIEdgeInsetsMake( 0, 0, 0, 20)];
         sprintf( name, "%ld,%ld", j, i);
         [(UIButton *) view setTitleCString:name];

         [rowView addSubview:view];
      }      
   }

   [rootView setNeedsLayout];

   [contentPlane addSubview:rootView];
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

