#import "import-private.h"

#import "CGContext.h"
#import "UIApplication.h"
#import "UIEvent.h"
#import "UIEdgeInsets.h"
#import "UISlider.h"
#import "UIWindow.h"
#import "UIColor.h"
#import "UIView+CAAnimation.h"
#import "MulleSliderLayer.h"
#import "CAAnimation.h"
#import <string.h>


static UIEvent   *slider_callback( UISlider *slider, UIEvent *event)
{
   fprintf( stderr, "slider_callback: %s\n", [slider cStringDescription]);
   return( nil);
}


// scale stuff for stream
#define SCALE     2.0

int   main()
{
   CGRect            frame;
   CGContext         *context;
   UIWindow          *window;
   UISlider          *slider;
   UIView            *contentView;
   MulleSliderLayer  *layer;

    /*
    * window and app 
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 400.0 * SCALE, 300.0 * SCALE)] autorelease];
   assert( window);

   contentView = [[[UIView alloc] initWithFrame:CGRectMake( 0.0, 0.0, 400.0 * SCALE, 300.0 * SCALE)] autorelease];
   [contentView setBackgroundColor:[UIColor whiteColor]];
   [window addSubview:contentView];

   [[UIApplication sharedInstance] addWindow:window];

   context = [CGContext new];
   [context setBackgroundColor:CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0)];

   frame = CGRectMake( 240.0, 340.0, 200.0 * SCALE, 44);

   slider = [[[UISlider alloc] initWithFrame:frame] autorelease];

   // [insideButton setClipsSubviews:YES];
   [slider setBackgroundColor:getNVGColor( 0xCC8800FF)];
   [slider setControlInsets:UIEdgeInsetsMake( 0, 20, 0, 20)];
   [contentView addSubview:slider];

   frame = CGRectMake( 140.0, 140.0, 44, 200.0 * SCALE);

   slider = [[[UISlider alloc] initWithFrame:frame] autorelease];

   // [insideButton setClipsSubviews:YES];
   [slider setBackgroundColor:getNVGColor( 0xCC8800FF)];
   [slider setControlInsets:UIEdgeInsetsMake( 20, 0, 20, 0)];
   [contentView addSubview:slider];

   // UIView -> CAAnimation
   [UIView beginAnimations:"animation" 
                    context:NULL];
   [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
   [UIView setAnimationDelay:0];        
   [UIView setAnimationDuration:4];        

   layer = (MulleSliderLayer *) [slider layer];
   assert( layer);
   [layer setControlInsets:MulleEdgeInsetsMake( 60, 10, 60, 10)];
   [UIView commitAnimations];

   [window dump];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

