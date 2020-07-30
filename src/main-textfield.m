#import "import-private.h"

#import "CGContext.h"
#import "UIApplication.h"
#import "UIEvent.h"
#import "UITextField.h"
#import "UIWindow.h"
#import "UIColor.h"
#import <string.h>



// scale stuff for stream
#define SCALE     2.0

int   main()
{
   CGRect               frame;
   CGContext            *context;
   UIWindow             *window;
   UITextField          *textView;
   UIApplication        *application;
   UIView               *contentView;

   /*
    * window and app 
    */
   mulle_testallocator_initialize();
   mulle_default_allocator = mulle_testallocator;

   @autoreleasepool
   {
       /*
       * window and app 
       */
      window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 400.0 * SCALE, 300.0 * SCALE)] autorelease];
      assert( window);

      contentView = [[[UIView alloc] initWithFrame:CGRectMake( 0.0, 0.0, 400.0 * SCALE, 300.0 * SCALE)] autorelease];
      [contentView setBackgroundColor:[UIColor whiteColor]];
      [window addSubview:contentView];

      [[UIApplication sharedInstance] addWindow:window];

      context = [[CGContext new] autorelease];
      [context setBackgroundColor:CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0)];

      /* simple Button */
      {
         frame.size.width  = 400;
         frame.size.height = 100;
         frame.origin.x   = (400.0 * SCALE - frame.size.width ) / 2.0;
         frame.origin.y   = (300.0 * SCALE - frame.size.height) / 2.0;

         textView = [[[UITextField alloc] initWithFrame:frame] autorelease];
         [textView setCString:"TextView"];
         [textView setFontPixelSize:64.0];
         [textView setCursorPosition:2];
         [textView setEditable:YES];

         // [insideButton setClipsSubviews:YES];
         [contentView addSubview:textView];
      }

      [window dump];
      [window renderLoopWithContext:context];

      [[UIApplication sharedInstance] terminate];
   }
   mulle_testallocator_reset();   
}

