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

   tigerSVGImage = [[[MulleSVGImage alloc] initWithBytes:svginput
                                          length:strlen( svginput) + 1] autorelease];
   fprintf( stderr, "tigerSVGImage: %p\n", tigerSVGImage);

   tigerLayer = [[[MulleSVGLayer alloc] initWithSVGImage:tigerSVGImage] autorelease];
   [tigerLayer setCStringName:"tiger"];
   fprintf( stderr, "layer: %p\n", tigerLayer);


   // layer = [[[CALayer alloc] init] autorelease];

   frame.origin       = CGPointMake( 0.0 * SCALE, 0.0 * SCALE);
   frame.size.width   = 160 * SCALE;
   frame.size.height  = 100 * SCALE;

   [tigerLayer setFrame:frame];
 //  [layer setBounds:CGRectMake( 0.0, 0.0, 200, 30)];
   [tigerLayer setBackgroundColor:getNVGColor( 0xFFE0D0D0)];
   [tigerLayer setBorderColor:getNVGColor( 0xFF30FF80)];
   [tigerLayer setBorderWidth:32.0f];
   [tigerLayer setCornerRadius:16.0f];

   viechBitmap = [[[MulleBitmapImage alloc] initWithConstBytes:viech_bitmap
                                                    bitmapSize:viech_bitmap_size]
                                                       autorelease];
   fprintf( stderr, "viechBitmap: %p\n", viechBitmap);

   turtleBitmap = [[[MulleBitmapImage alloc] initWithConstBytes:turtle_bitmap
                                                     bitmapSize:turtle_bitmap_size]
                                                  autorelease];
   fprintf( stderr, "turtleBitmapImage: %p\n", turtleBitmap);

   turtleLayer = [[[MulleImageLayer alloc] initWithImage:turtleBitmap] autorelease];
   [turtleLayer setCStringName:"turtle"];
   frame.origin = CGPointMake( 0.0 * SCALE, 100.0  * SCALE);
   frame.size.width  = turtle_bitmap_size.size.width;
   frame.size.height = turtle_bitmap_size.size.height;
   [turtleLayer setFrame:frame];
   fprintf( stderr, "layer: %p\n", turtleLayer);

   /*
    * window and app 
    */
   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 400.0 * SCALE, 300.0 * SCALE)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   context = [CGContext new];
   [context setBackgroundColor:CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0)];

#if 0
   /*
    * view placement in window 
    */
   view = [[[UIView alloc] initWithLayer:tigerLayer] autorelease];
   [window addSubview:view];
#endif

#if 0
   nestedButton = [[[UIButton alloc] initWithLayer:turtleLayer] autorelease];
   [nestedButton setBackgroundImage:turtleBitmap
                           forState:UIControlStateNormal];
   [nestedButton setBackgroundImage:viechBitmap
                           forState:UIControlStateSelected];

   // [insideButton setClipsSubviews:YES];
   [nestedButton setClick:button_callback];
   [window addSubview:nestedButton];
#endif
   frame.origin      = CGPointMake( turtle_bitmap_size.size.width * SCALE, 100.0 * SCALE);
   frame.size.width  = 140;
   frame.size.height = 100;

#if 0
   label = [[[UILabel alloc] initWithFrame:frame] autorelease];

   // [insideButton setClipsSubviews:YES];
   [label setCString:"UILabel"];
   [label setFontName:"sans"];
   [label setFontPixelSize:14.0 * SCALE];
   [label setBackgroundColor:getNVGColor( 0x1F1F1FFF)];
   [label setTextColor:getNVGColor( 0xFEFEFEFF)];

   [window addSubview:label];
#endif

   frame.origin      = CGPointMake( 160.0 * SCALE , 0 * SCALE);
   frame.size.width  = 200;
   frame.size.height = 100;

#if 0
   checkbox = [[[UISwitch alloc] initWithFrame:frame] autorelease];

   // [insideButton setClipsSubviews:YES];
   [checkbox setCString:"UISwitch"];
   [checkbox setFontName:"sans"];
   [checkbox setFontPixelSize:14.0 * SCALE];
   [checkbox setBackgroundColor:getNVGColor( 0x112141FF)];
   [checkbox setTextColor:getNVGColor( 0xFE00FEFF)];

   [window addSubview:checkbox];
#endif

   frame.origin      = CGPointMake( 160.0 * SCALE , 100.0 * SCALE);
   frame.size.width  = 200;
   frame.size.height = 100;

#if 0
   slider = [[[UISlider alloc] initWithFrame:frame] autorelease];

   // [insideButton setClipsSubviews:YES];
   [slider setBackgroundColor:getNVGColor( 0x114111FF)];

   [window addSubview:slider];
   frame           = [label frame];
#endif
   frame.origin.y += frame.size.height;
#if 0
   stepper = [[[UIStepper alloc] initWithFrame:frame] autorelease];

   // [insideButton setClipsSubviews:YES];
   [window addSubview:stepper];
#endif

   frame.origin.y += frame.size.height;

   segmentedControl = [[[UISegmentedControl alloc] initWithFrame:frame] autorelease];
   [segmentedControl setBackgroundColor:getNVGColor( 0xFF00FFFF)]; 
   [segmentedControl insertSegmentWithCString:"1" 
                                     atIndex:0 
                                    animated:NO];  
   [segmentedControl insertSegmentWithCString:"0" 
                                     atIndex:0 
                                    animated:NO];  
   [segmentedControl insertSegmentWithCString:"2" 
                                     atIndex:2 
                                    animated:NO];  
   [segmentedControl insertSegmentWithCString:"3" 
                                     atIndex:3 
                                    animated:NO];  
/*                                    
   [segmentedControl insertSegmentWithCString:"2" 
                                     atIndex:2
                                    animated:NO];  
*/                                    
   [segmentedControl setContentOffset:CGSizeMake( 0, 0) 
                    forSegmentAtIndex:1];     
   [segmentedControl setBackgroundColor:getNVGColor( 0x00FF00FF) 
                    forSegmentAtIndex:1]; 
   [segmentedControl setBackgroundColor:getNVGColor( 0xFFFF00FF) 
                    forSegmentAtIndex:2];  
   [segmentedControl setBackgroundColor:getNVGColor( 0x00FFFFFF) 
                    forSegmentAtIndex:3];                                           
                                                                                      
   [segmentedControl setTextColor:getNVGColor( 0x000000FF)]; 
   [segmentedControl setCornerRadius:8];
   [window addSubview:segmentedControl];

   frame.origin.x   += frame.size.width + 20;
   frame.size.width  = 120;
   frame.size.height = 44;

   uiButton = [[[UIButton alloc] initWithFrame:frame] autorelease];
   [uiButton setTitleCString:"Button"];

   // [insideButton setClipsSubviews:YES];
   [window addSubview:uiButton];

   [window dump];
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

