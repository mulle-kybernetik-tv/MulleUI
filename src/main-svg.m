#import "import-private.h"

#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"
#import "CGContext.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIEvent.h"
#import "UIView+Yoga.h"
#import <string.h>


#include "Ghostscript_Tiger-svg.inc"


// scale stuff for stream
#define SCALE     2.0


static void   setupSceneInContentPlane( MulleWindowPlane *contentPlane)
{
   MulleSVGImage  *tigerSVGImage;
   MulleSVGLayer  *tigerLayer;
   CGRect         frame;
   UIView         *view;
   YGLayout       *yoga;

   tigerSVGImage = [[[MulleSVGImage alloc] initWithBytes:svginput
                                                  length:strlen( svginput) + 1] autorelease];
   fprintf( stderr, "tigerSVGImage: %p\n", tigerSVGImage);

   tigerLayer = [[[MulleSVGLayer alloc] initWithSVGImage:tigerSVGImage] autorelease];
   [tigerLayer setCStringName:"tiger"];
   fprintf( stderr, "layer: %p\n", tigerLayer);

   [tigerLayer setFrame:CGRectZero];
 //  [layer setBounds:CGRectMake( 0.0, 0.0, 200, 30)];
   [tigerLayer setBackgroundColor:getNVGColor( 0xFFE0D0D0)];
   [tigerLayer setBorderColor:getNVGColor( 0xFF30FF80)];
   [tigerLayer setBorderWidth:32.0f];
   [tigerLayer setCornerRadius:16.0f];


   view = [[[UIView alloc] initWithLayer:tigerLayer] autorelease];
   yoga = [view yoga];

//   [yoga setMarginLeft:YGPercentValue( 5.0)];
//   [yoga setMarginTop:YGPercentValue( 5.0)];
   [yoga setEnabled:YES];
   [yoga setWidth:YGPercentValue( 100.0)];
   [yoga setHeight:YGPercentValue( 100.0)]; 
   [view setNeedsLayout];

   yoga = [contentPlane yoga];
   [yoga setEnabled:YES];
   [contentPlane setNeedsLayout];

   [contentPlane addSubview:view];
}


int  main()
{
   CGContext       *context;
   UIWindow        *window;
   UIApplication   *application;

      /*
       * window and app 
       */
   mulle_testallocator_initialize();
   mulle_default_allocator = mulle_testallocator;

   @autoreleasepool
   {
      window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 320.0 * SCALE, 200.0 * SCALE)] autorelease];
      assert( window);

      [[UIApplication sharedInstance] addWindow:window];

      setupSceneInContentPlane( [window contentPlane]);

      [window dump];

      context = [[CGContext new] autorelease];
      [window renderLoopWithContext:context];

      [[UIApplication sharedInstance] terminate];
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

