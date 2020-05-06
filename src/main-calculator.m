#import "import-private.h"

#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"
#import "MulleBitmapImage.h"
#import "CGContext.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UIView+Yoga.h"
#import "UIScrollView.h"
#import "UIEvent.h"
#import <string.h>


//	stolen from catgl ©2015,2018 Yuichiro Nakada
#define W  200
#define H  100

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


// scale stuff for stream
#define SCALE     2.0


static void   setupSceneInContentPlane( MulleWindowPlane *contentPlane)
{
   UIView     *rootView;
   UIView     *rowView;
   UIView     *view;
   CGRect     frame;
   YGLayout   *yoga;

   frame = [contentPlane bounds];
   assert( frame.size.width > 0.0);
   assert( frame.size.width  > 0.0);

   frame = UIEdgeInsetsInsetRect( frame, UIEdgeInsetsMake( 20, 20, 20, 20));

   rootView  = [[[UIView alloc] initWithFrame:frame] autorelease];
   [rootView setBackgroundColor:getNVGColor( 0x0000FFFF)]; // blue
   [rootView setCStringName:"root"];

   yoga = [rootView yoga];
   [yoga setEnabled:YES];

   // Flex
//   [yoga setDirection:YGDirectionLTR];
   [yoga setFlexDirection:YGFlexDirectionColumn];
//   [yoga setFlexBasis:YGValueAuto];
//   [yoga setFlexGrow:0.0];
//   [yoga setFlexShrink:1.0];
//   [yoga setFlexWrap:YGWrapNoWrap];

   // Alignment
//   [yoga setJustifyContent:YGJustifyCenter];
//   [yoga setAlignItems:YGAlignStretch];
//   [yoga setAlignSelf:YGAlignAuto];
//   [yoga setAlignContent:YGAlignStretch];

   // Layout
   [yoga setPosition:YGPositionTypeAbsolute];
   [yoga setLeft:YGPointValue(frame.origin.x)];
   [yoga setTop:YGPointValue(frame.origin.y)];
   [yoga setWidth:YGPointValue(frame.size.width)];
   [yoga setHeight:YGPointValue(frame.size.height)];


#define N_ROWS 5
#define N_COLS 4

   NSUInteger   i;
   NSUInteger   j;
   char         name[ 100];


   /* CHILD 1 */
   for( i = 0; i < N_ROWS; i++)
   {
      // create a row view (transparent though)
      frame = CGRectMake( 0, 0, 0, 0);
      rowView  = [[[UIView alloc] initWithFrame:frame] autorelease];
      [rowView setBackgroundColor:MulleColorCreateRandom( 0xFF0000FF, 0x00FFFF00)];
 
      yoga = [rowView yoga];
      [yoga setEnabled:YES];

      // Flex
//      [yoga setDirection:YGDirectionLTR];
//      [yoga setFlexDirection:YGFlexDirectionRow];
//      [yoga setFlexBasis:YGValueAuto];
      [yoga setFlexGrow:1.0];
//      [yoga setFlexShrink:1.0];
//      [yoga setFlexWrap:YGWrapNoWrap];

      // Alignment
//      [yoga setJustifyContent:YGJustifyFlexStart];
//      [yoga setAlignItems:YGAlignStretch];
//      [yoga setAlignSelf:YGAlignAuto];
//      [yoga setAlignContent:YGAlignStretch];

      // Layout
      [yoga setPosition:YGPositionTypeRelative];
      [yoga setWidth:YGValueAuto];
      [yoga setHeight:YGValueAuto]; // YGPercentValue( 100.0 / N_ROWS )];
      [yoga setMargin:YGPointValue(10.0)];

//      [yoga setPaddingLeft:YGPointValue( 0.0)];
//      [yoga setPaddingTop:YGPointValue( 10.0)];
//      [yoga setPaddingRight:YGPointValue( 0.0)];
//      [yoga setPaddingBottom:YGPointValue( 10.0)];

//      // used for insetting children apparently
//      [yoga setBorderLeftWidth:( 10.0)];
//      [yoga setBorderTopWidth:( 0.0)];
//      [yoga setBorderRightWidth:( 10.0)];
//      [yoga setBorderBottomWidth:( 0.0)];

      for( j = 0; j < N_COLS; j++)
      {
         // create actual views
         frame = CGRectMake( 0, 0, 0, 0);
         view  = [[[UIButton alloc] initWithFrame:frame] autorelease];
         // [view setBackgroundColor:MulleColorCreateRandom( 0x00FF00FF, 0xFF00FF00)];
         sprintf( name, "%ld,%ld", j, i);
         [(UIButton *) view setTitleCString:name];

         yoga = [view yoga];
         [yoga setEnabled:YES];

         // Flex
//         [yoga setDirection:YGDirectionLTR];
//         [yoga setFlexDirection:YGFlexDirectionRow];
//         [yoga setFlexBasis:YGValueAuto];
         [yoga setFlexGrow:1.0];
//         [yoga setFlexShrink:1.0];
//         [yoga setFlexWrap:YGWrapNoWrap];

         // Alignment
//         [yoga setJustifyContent:YGJustifyFlexStart];
//         [yoga setAlignItems:YGAlignStretch];
//         [yoga setAlignSelf:YGAlignAuto];
//         [yoga setAlignContent:YGAlignStretch];

         // Layout
         [yoga setPosition:YGPositionTypeRelative];
         [yoga setWidth:YGValueAuto];
         [yoga setHeight:YGValueAuto]; // YGPercentValue( 100.0 / N_ROWS )];
         [yoga setMarginHorizontal:YGPointValue(20.0)];
            // no difference seen, not sure what this is for


//
//        [yoga setMarginLeft:YGPointValue( 10.0)];
//        [yoga setMarginTop:YGPointValue( 10.0)];
//        [yoga setMarginRight:YGPointValue( 10.0)];
//        [yoga setMarginBottom:YGPointValue( 10.0)];
//
//         [yoga setMarginStart:YGPointValue(10.0)];
//         [yoga setMarginEnd:YGPointValue(10.0)];
//         [yoga setMarginHorizontal:YGPointValue(10.0)];
//         [yoga setMarginVertical:YGPointValue(10.0)];       

         [rowView addSubview:view];
      }

      [rootView addSubview:rowView];
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
   mulle_testallocator_initialize();
   mulle_default_allocator = mulle_testallocator;

   @autoreleasepool
   {
      window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 640.0 * SCALE, 400.0 * SCALE)] autorelease];
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

