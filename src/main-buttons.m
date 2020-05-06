#import "import-private.h"

#import "CGContext.h"
#import "MulleBitmapImage.h"
#import "MulleImageLayer.h"
#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UIEvent.h"
#import "UILabel.h"
#import "UIScrollView.h"
#import "UISegmentedControl.h"
#import "UISlider.h"
#import "UIStepper.h"
#import "UISwitch.h"
#import "UIWindow.h"
#import "UIColor.h"
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


static UIEvent   *segmented_callback( UISegmentedControl *control, UIEvent *event)
{
   fprintf( stderr, "segmented_callback: %s (%ld)\n", 
                        [control cStringDescription],
                        (long) [control selectedSegmentIndex]);
   return( nil);
}


static UIEvent   *scroll_callback( UIButton *button, UIEvent *event)
{
   UIScrollView   *scroller;
   CGPoint        offset;

   fprintf( stderr, "scroll_callback: %s\n", [button cStringDescription]);

   scroller = (UIScrollView *) [[button superview] superview];
   assert( [scroller isKindOfClass:[UIScrollView class]]);

   offset    = [scroller contentOffset];
   offset.y += 10;
   [scroller setContentOffset:offset];

   return( nil);
}


// scale stuff for stream
#define SCALE     2.0

int   main()
{
   MulleSVGLayer        *tigerLayer;
   MulleSVGLayer        *shiftedTigerLayer;
   MulleImageLayer      *viechLayer;
   MulleImageLayer      *sealieLayer;
   MulleImageLayer      *turtleLayer;
   MulleImageLayer      *turtleLayer2;
   MulleSVGImage        *tigerSVGImage;
   MulleBitmapImage     *viechBitmap;
   MulleBitmapImage     *sealieBitmap;
   MulleBitmapImage     *turtleBitmap;
   CGRect               frame;
   CGRect               bounds;
   CGContext            *context;
   UIWindow             *window;
   UIView               *view;
   UIButton             *button;
   UILabel              *label;
   UIStepper            *stepper;
   UIButton             *insideButton;
   UIButton             *nestedButton;
   UIButton             *inScrollerButton;
   UIButton             *uiButton;
   UISegmentedControl   *segmentedControl;
   UIScrollView         *scroller;
   UIApplication        *application;
   UISwitch             *checkbox;
   UISlider             *slider;
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

      frame = CGRectMake( 240.0, 340.0, 200.0 * SCALE, 44);

#if 0
      segmentedControl = [[[UISegmentedControl alloc] initWithFrame:frame] autorelease];
      [segmentedControl setBackgroundColor:getNVGColor( 0xFF00FFFF)]; 
      [segmentedControl setSelectedSegmentTintColor:getNVGColor( 0x80FF80FF)]; 
      [segmentedControl insertSegmentWithTitleCString:"Bochum" 
                                              atIndex:0 
                                             animated:NO];  
      [segmentedControl insertSegmentWithTitleCString:"VfL" 
                                              atIndex:0 
                                             animated:NO];  
      [segmentedControl insertSegmentWithTitleCString:"1848" 
                                              atIndex:2 
                                             animated:NO];  

   /*                                    
      [segmentedControl insertSegmentWithCString:"2" 
                                        atIndex:2
                                       animated:NO];  
   */                                    
      [segmentedControl setContentOffset:CGSizeMake( 0, 0) 
                       forSegmentAtIndex:1]; 
   /*                        
      [segmentedControl setBackgroundColor:getNVGColor( 0x00FF00FF) 
                       forSegmentAtIndex:1]; 
      [segmentedControl setBackgroundColor:getNVGColor( 0xFFFF00FF) 
                       forSegmentAtIndex:2];  
      [segmentedControl setBackgroundColor:getNVGColor( 0x00FFFFFF) 
                       forSegmentAtIndex:3];                                           
   */                                                                                      
      [segmentedControl setTextColor:getNVGColor( 0x000000FF)]; 
      [segmentedControl setCornerRadius:8];
      [segmentedControl setSelectedSegmentIndex:2];
      [segmentedControl setClick:segmented_callback];
      [segmentedControl setAllowsMultipleSelection:YES];
      [segmentedControl setAllowsEmptySelection:YES];
      [contentView addSubview:segmentedControl];
      [segmentedControl setFontPixelSize:frame.size.height / 2];
#endif

      frame.origin.x   += frame.size.width + 20;
      frame.size.width  = 120;
      frame.size.height = 44;

      uiButton = [[[UIButton alloc] initWithFrame:frame] autorelease];
      [uiButton setTitleCString:"Button"];

      // [insideButton setClipsSubviews:YES];
      [contentView addSubview:uiButton];

      [window dump];
      [window renderLoopWithContext:context];

      [[UIApplication sharedInstance] terminate];
   }
   mulle_testallocator_reset();   
}

