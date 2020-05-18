#import "import-private.h"

#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"
#import "MulleBitmapImage.h"
#import "CGContext.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UIView+Yoga.h"
#import "UIStackView.h"
#import "UIScrollView.h"
#import "UIEvent.h"
#import <string.h>


static UIEvent   *button_callback( UIButton *button, UIEvent *event)
{
   fprintf( stderr, "button_callback: %s\n", [button cStringDescription]);
   return( nil);
}



static void   setupSceneInContentPlane( MulleWindowPlane *contentPlane)
{
   UIView     *rootView;
   UIView     *displayView;
   UIView     *keyboardView;
   UIView     *rowView;
   UIView     *view;
   YGLayout   *yoga;
   CGRect     frame;

   frame = [contentPlane bounds];
   assert( frame.size.width > 0.0);
   assert( frame.size.width  > 0.0);

   rootView  = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
   [rootView setCStringName:"RootView"];
   [rootView setBackgroundColor:getNVGColor( 0xFFFF00FF)]; 
   yoga = [rootView yoga];
   [yoga setEnabled:YES];
   [yoga setWidth:YGPercentValue(100.0)];
   [yoga setHeight:YGPercentValue(100.0)];
   [yoga setFlexDirection:YGFlexDirectionColumn];

   // LCD Display container
   displayView  = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
   [displayView setBackgroundColor:getNVGColor( 0xFF7F7FFF)]; 
   [displayView setCStringName:"DisplayView"];
   yoga = [displayView yoga];
   [yoga setEnabled:YES];
   [yoga setWidth:YGValueAuto];
   [yoga setHeight:YGPointValue(100.0)];
   [yoga setMarginLeft:YGPointValue( 10.0)];
   [yoga setMarginTop:YGPointValue( 10.0)];
   [yoga setMarginRight:YGPointValue( 10.0)];
   [yoga setMarginBottom:YGPointValue( 0.0)];   
  
   [rootView addSubview:displayView];

   // Keyboard container
   keyboardView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
   [keyboardView setBackgroundColor:getNVGColor( 0x0000FFFF)]; // blue
   [keyboardView setCStringName:"KeyboardView"];

   yoga = [keyboardView yoga];
   [yoga setEnabled:YES];
   [yoga setWidth:YGValueAuto];
   [yoga setHeight:YGValueAuto];
   [yoga setMarginLeft:YGPointValue( 10.0)];
   [yoga setMarginTop:YGPointValue( 10.0)];
   [yoga setMarginRight:YGPointValue( 10.0)];
   [yoga setMarginBottom:YGPointValue( 10.0)];   
   [yoga setFlexGrow:1.0];  // for this container

   // kids are layed out vertically,
   [yoga setFlexDirection:YGFlexDirectionColumn]; // for kids
   [rootView addSubview:keyboardView];

#define N_ROWS 3
#define N_COLS 0 //

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
      if( i == 0)  // marker for debug
         [yoga setAlignContent:YGAlignSpaceBetween];  // for this container
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

      [keyboardView addSubview:rowView];
   }

   [displayView setNeedsLayout];
   [keyboardView setNeedsLayout];

   [contentPlane addSubview:rootView];

   yoga = [contentPlane yoga];
   [yoga setEnabled:YES];
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

