#import "import-private.h"

#import "CGContext.h"
#import "MulleTextLayer.h"
#import "UIApplication.h"
#import "UIColor.h"
#import "UIEvent.h"
#import "UILabel.h"
#import "UITextField.h"
#import "UIView+CAAnimation.h"
#import "UIWindow.h"
#import <string.h>



// scale stuff for stream
#define SCALE     2.0

int   main()
{
   CGRect          frame;
   CGContext       *context;
   UIWindow        *window;
   UITextField     *textField;
   UIApplication   *application;
   UIView          *contentView;
   UILabel         *label;

   /*
    * window and app 
    */
   // mulle_testallocator_initialize();
   // mulle_default_allocator = mulle_testallocator;

   @autoreleasepool
   {
       /*
       * window and app 
       */
      window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 400.0 * SCALE, 300.0 * SCALE)] autorelease];
      assert( window);

      contentView = [window contentPlane];
      [contentView setBackgroundColor:[UIColor greenColor]];

      [[UIApplication sharedInstance] addWindow:window];
#if 1
      // multilline UILabel
      {
         frame.size.width  = 400;
         frame.size.height = 200;
         frame.origin.x    = (400.0 * SCALE - frame.size.width ) / 2.0;
         frame.origin.y    = 100.0 ;

         label = [[[UILabel alloc] initWithFrame:frame] autorelease];
//         [label setCString:"ob o b"];

         
         [label setCString:"Line #0 some more text to be clipped\n"
"   Line #1\n"
"Line #2\n"
"Line #3\n"
"Line #4\n"
"Line #5\n"
"Line #6\n"
"Line #7\n"
"Line #8\n"
"Line #9\n"
];

         // TODO: this is apparently ignored!!! why ?? (because the prototype
         //       was missing!)
         [label setFontPixelSize:30.0];
         // [label setFont:[UIFont boldSystemFontOfSize:40.0]];
         [label setLineBreakMode:NSLineBreakByWordWrapping];
         [label setUserInteractionEnabled:YES];
         [label setAlignmentMode:CAAlignmentRight];
         [label mulleSetVerticalAlignmentMode:MulleTextVerticalAlignmentTop];
         [label setBackgroundColor:[UIColor underPageBackgroundColor]];
         [label setTextColor:[UIColor whiteColor]];
         [label setSelection:NSMakeRange( 10, 20)];
         // TODO: UILabel shouldn't support these
         [label setCursorPosition:MulleIntegerPointMake( 12, 0)];
         [label setEditable:YES];
         [contentView addSubview:label];
      }
#endif

#if 1
      {
         frame.size.width  = 400;
         frame.size.height = 100;
         frame.origin.x   = (400.0 * SCALE - frame.size.width ) / 2.0;
         frame.origin.y   = 400;

         textField = [[[UITextField alloc] initWithFrame:frame] autorelease];
         [textField setCString:"TextField"];
         // TODO: this is apparently ignored!!! why ?? (because the prototype
         //       was missing!)
         [textField setFontPixelSize:80.0];
         [textField setCursorPosition:MulleIntegerPointMake( 2, 0)];
         [textField setAlignmentMode:CAAlignmentRight];
         [textField setEditable:YES];
#if 0      
         [textField setTextOffset:CGPointMake( 80.0, 0.0)];
#endif
         // [insideButton setClipsSubviews:YES];
         [contentView addSubview:textField];
      }
#endif

#if 0
      {
         // UIView -> CAAnimation
         [UIView beginAnimations:"animation"
                          context:NULL];
         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
         [UIView setAnimationRepeatAutoreverses:YES];
         [UIView setAnimationDelay:2];
         [UIView setAnimationDuration:2];
         [UIView setAnimationRepeatCount:20];

         [textField setTextOffset:CGPointMake( -80.0, 0.0)];

         [UIView commitAnimations];
      }
#endif

      [window dump];

      context = [[CGContext new] autorelease];
      [context setBackgroundColor:CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0)];

      [window renderLoopWithContext:context];

      [[UIApplication sharedInstance] terminate];
   }
   //   mulle_testallocator_reset();   
}

