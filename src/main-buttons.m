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
#import "UIStepper.h"
#import "UISwitch.h"
#import "UIWindow.h"
#import "UIColor.h"
#import <string.h>



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


// scale stuff for stream
#define SCALE     2.0

int   main()
{
   CGRect               frame;
   CGRect               bounds;
   CGContext            *context;
   UIApplication        *application;
   UIButton             *button;
   UIButton             *inScrollerButton;
   UIButton             *insideButton;
   UIButton             *nestedButton;
   UIButton             *trackingButton;
   UIButton             *uiButton;
   UILabel              *label;
   UIScrollView         *scroller;
   UISegmentedControl   *segmentedControl;
   UIStepper            *stepper;
   UISwitch             *switchButton;
   UIView               *contentView;
   UIView               *view;
   UIWindow             *window;

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

#if 1
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

      /* simple Button */
      {
         frame.origin.x   += frame.size.width + 20;
         frame.size.width  = 120;
         frame.size.height = 44;

         uiButton = [[[UIButton alloc] initWithFrame:frame] autorelease];
         [uiButton setTitleCString:"Button"];

         // [insideButton setClipsSubviews:YES];
         [contentView addSubview:uiButton];
      }

      /* Button with highlighting and tracking rectangle */
      {
         frame.origin.x    = 20;
         frame.size.width  = 120;
         frame.size.height = 44;

         trackingButton = [[[UIButton alloc] initWithFrame:frame] autorelease];
         [trackingButton setTitleCString:"Tracking"];

         frame.origin = CGPointZero;
         [trackingButton addTrackingAreaWithRect:frame
                                         toWindow:window
                                         userInfo:nil];
         [contentView addSubview:trackingButton];

         // [insideButton setClipsSubviews:YES];
      }

      /* UISwitch */
      {
         frame.origin.x    = 20;
         frame.origin.y   += 100;
         frame.size.width  = 120;
         frame.size.height = 44;

         switchButton = [[[UISwitch alloc] initWithFrame:frame] autorelease];
         [contentView addSubview:switchButton];

         // [insideButton setClipsSubviews:YES];
      }

      [window dump];
      [window renderLoopWithContext:context];

      [[UIApplication sharedInstance] terminate];
   }
   mulle_testallocator_reset();   
}

