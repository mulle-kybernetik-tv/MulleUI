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


static void   setupSceneInWindow( UIWindow *window)
{
   UIView     *rootView;
   UIView     *rowView;
   UIView     *view;
   CGRect     frame;
   YGLayout   *yoga;

   frame = [window bounds];
   assert( frame.size.width > 0.0);
   assert( frame.size.width  > 0.0);

   frame = UIEdgeInsetsInsetRect( frame, UIEdgeInsetsMake( 20, 20, 20, 20));

   rootView  = [[[UIView alloc] initWithFrame:frame] autorelease];
   [rootView setBackgroundColor:getNVGColor( 0x0000FFFF)]; // red
   [rootView setCStringName:"root"];

   yoga = [rootView yoga];
   [yoga setEnabled:YES];
   [yoga setPosition:YGPositionTypeAbsolute];
   [yoga setLeft:YGPointValue(frame.origin.x)];
   [yoga setTop:YGPointValue(frame.origin.y)];
   [yoga setWidth:YGPointValue(frame.size.width)];
   [yoga setHeight:YGPointValue(frame.size.height)];
   [yoga setAlignItems:YGAlignCenter];
   [yoga setJustifyContent:YGJustifyCenter];
   [yoga setFlexDirection:YGFlexDirectionColumn];

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
      [yoga setPosition:YGPositionTypeRelative];
      [yoga setWidth:YGValueAuto];
      [yoga setHeight:YGPercentValue( 100.0 / N_ROWS )];
      [yoga setFlexDirection:YGFlexDirectionRow];

      // if our view is invisible padding and border is the same
      // but additive

//      [yoga setPaddingLeft:YGPointValue( 10.0)];
      [yoga setPaddingTop:YGPointValue( 10.0)];
//      [yoga setPaddingRight:YGPointValue( 10.0)];
      [yoga setPaddingBottom:YGPointValue( 10.0)];

//      // used for insetting children apparently
      [yoga setBorderLeftWidth:( 10.0)];
//      [yoga setBorderTopWidth:( 20.0)];
      [yoga setBorderRightWidth:( 10.0)];
//      [yoga setBorderBottomWidth:( 20.0)];

      for( j = 0; j < N_COLS; j++)
      {
         // create actual views
         frame = CGRectMake( 0, 0, 0, 0);
         view  = [[[UIView alloc] initWithFrame:frame] autorelease];
         [view setBackgroundColor:MulleColorCreateRandom( 0x00FF00FF, 0xFF00FF00)];
         sprintf( name, "view %ld,%ld", j, i);
         [view setCStringName:name];

         yoga = [view yoga];
         [yoga setEnabled:YES];
         [yoga setPosition:YGPositionTypeRelative];
         [yoga setWidth:YGPercentValue( 100.0 / N_COLS)];
         [yoga setHeight:YGValueAuto];

         // no difference seen, not sure what this is for


//
//        [yoga setMarginLeft:YGPointValue( 10.0)];
//        [yoga setMarginTop:YGPointValue( 10.0)];
//        [yoga setMarginRight:YGPointValue( 10.0)];
//        [yoga setMarginBottom:YGPointValue( 10.0)];

//         [yoga setMarginStart:YGPointValue(10.0)];
//         [yoga setMarginEnd:YGPointValue(10.0)];
         [yoga setMarginHorizontal:YGPointValue(10.0)];
//         [yoga setMarginVertical:YGPointValue(10.0)];       

         [rowView addSubview:view];
      }
      [rootView addSubview:rowView];
   }

   [rootView setNeedsLayout];
 
   [window addSubview:rootView];
}


int  main()
{
   CGContext       *context;
   UIWindow        *window;
   UIApplication   *application;

   /*
    * window and app 
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 640.0 * SCALE, 400.0 * SCALE)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   setupSceneInWindow( window);

   [window dump];

   context = [CGContext new];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

