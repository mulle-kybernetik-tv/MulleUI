#import "import-private.h"

#import "CGContext.h"
#import "MulleTextLayer.h"
#import "UIApplication.h"
#import "UIColor.h"
#import "UIEvent.h"
#import "UITextField.h"
#import "UIView+CAAnimation.h"
#import "UIWindow.h"
#import <string.h>


void setup_window( UIWindow *window)
{
   CGRect          frame;
   UITextField     *textField;
   UIView          *contentView;

   contentView = [window contentPlane];
   [contentView setBackgroundColor:[UIColor greenColor]];

   frame.size.width  = 400;
   frame.size.height = 80;
   frame.origin.x   = (400.0 - frame.size.width ) / 2.0;
   frame.origin.y   = 10;

   textField = [[[UITextField alloc] initWithFrame:frame] autorelease];
   [textField setCString:"TextFyeld"];
   // TODO: this is apparently ignored!!! why ?? (because the prototype
   //       was missing!)
   [textField setFontPixelSize:60.0];
   [textField setCursorPosition:MulleIntegerPointMake( 2, 0)];
   [textField setAlignmentMode:CAAlignmentRight];
   [textField mulleSetVerticalAlignmentMode:MulleTextVerticalAlignmentBottom];
   [textField setEditable:YES];
#if 0      
   [textField setTextOffset:CGPointMake( 80.0, 0.0)];
#endif
   // [insideButton setClipsSubviews:YES];
   [contentView addSubview:textField];
}


int   main()
{
   CGContext       *context;
   CGContext       *context2;
   UIWindow        *window;
   UIWindow        *window2;
   UIApplication   *application;
   char            buf[ 64];
   int             i;

   /*
    * window and app 
    */
   // mulle_testallocator_initialize();
   // mulle_default_allocator = mulle_testallocator;

   @autoreleasepool
   {
      for( i = 1; i <= 100; i++)
      {
          /*
          * window and app 
          */
         sprintf( buf, "Demo %d", i);
         fprintf( stderr, "Window #%d\n", i);
         window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 400.0, 300.0)
                                        titleCString:buf
                                           styleMask:0] autorelease];
         assert( window);
         setup_window( window);

         [[UIApplication sharedInstance] addWindow:window];

         context = [window createContext];
         assert( context);

         [context setBackgroundColor:CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0)];
         [window renderLoopWithContext:context
                     maxFramesToRender:3];
         // sleep( 1);
      }
      // [[UIApplication sharedInstance] terminate];
   }
   //   mulle_testallocator_reset();   
}

