#import "import-private.h"

#import "MulleBitmapImage.h"
#import "UIImageView.h"
#import "UIStackView.h"
#import "CGContext.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIColor.h"
#import <string.h>


#include "sealie-bitmap.inc"
#include "turtle-bitmap.inc"
#include "viech-bitmap.inc"


// scale stuff for stream
#define SCALE     2.0

void   setupScene( UIWindow *window, CGContext *context)
{
   UIView             *view;
   CGRect             frame;
   UIEdgeInsets       insets;
   MulleBitmapImage   *image;
   UIStackView        *stackView;

   frame            = [window frame];
   insets           = UIEdgeInsetsMake( 80, 80, 280, 80);
   frame            = UIEdgeInsetsInsetRect( frame, insets);
   frame.size.width = 102 + 100 + 20.0f + 4;

   stackView = [[[UIStackView alloc] initWithFrame:frame] autorelease];
   insets    = UIEdgeInsetsMake( 2, 2, 2, 2);
   [stackView setContentInsets:insets];
   [stackView setDistribution:MulleStackViewDistributionFillRowColumn];
   [stackView setAxis:UILayoutConstraintAxisHorizontal];
   // [stackView setMinimumInteritemSpacing:20.0];
   [stackView setBorderWidth:1.0];
   [stackView setBorderColor:[UIColor blackColor]];
   [window addSubview:stackView];

   {
      image = [[[MulleBitmapImage alloc] initWithConstBitmapBytes:sealie_bitmap
                                                       bitmapSize:sealie_bitmap_size]
                                                         autorelease];

      view  = [[[UIImageView alloc] initWithImage:image] autorelease];
      [stackView addSubview:view];
   }

   {
      image = [[[MulleBitmapImage alloc] initWithConstBitmapBytes:turtle_bitmap
                                                       bitmapSize:turtle_bitmap_size]
                                                  autorelease];

      view  = [[[UIImageView alloc] initWithImage:image] autorelease];
      [stackView addSubview:view];
   }

   {
      image = [[[MulleBitmapImage alloc] initWithConstBitmapBytes:viech_bitmap
                                                 bitmapSize:viech_bitmap_size]
                                                     autorelease];

      view  = [[[UIImageView alloc] initWithImage:image] autorelease];
      [stackView addSubview:view];
   }      
}


int   main()
{
   CGContext   *context;
   UIWindow    *window;

   /*
    * window and app 
    */
   @autoreleasepool
   {
      window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 400.0 * SCALE, 300.0 * SCALE)] autorelease];
      assert( window);

      [[UIApplication sharedInstance] addWindow:window];

      context = [[CGContext new] autorelease];
      [context setBackgroundColor:CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0)];

      setupScene( window, context);

      [window dump];

      [window renderLoopWithContext:context];
      [[UIApplication sharedInstance] terminate];
   }
}
