#import "import-private.h"

#import "MulleSVGImage.h"
#import "MulleSVGLayer.h"
#import "MulleBitmapImage.h"
#import "MulleBitmapLayer.h"
#import "CGContext.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIButton.h"
#import "UIEvent.h"
#import <string.h>


//	stolen from catgl ©2015,2018 Yuichiro Nakada
#define W  200
#define H  100

#include "tiger-svg.inc"
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


static NVGcolor getNVGColor(uint32_t color)
{
	return nvgRGBA(
		(color >> 0) & 0xff,
		(color >> 8) & 0xff,
		(color >> 16) & 0xff,
		(color >> 24) & 0xff);
}

static UIEvent   *button_callback( UIButton *button, UIEvent *event)
{
   fprintf( stderr, "callback: %s\n", [button cStringDescription]);
   return( nil);
}


int   main()
{
   MulleSVGLayer      *layer1;
   MulleSVGLayer      *layer2;
   MulleBitmapLayer   *layer3;
   MulleBitmapLayer   *layer4;
   MulleBitmapLayer   *layer5;
   MulleSVGImage      *image;
   MulleBitmapImage   *bitmapImage1;
   MulleBitmapImage   *bitmapImage2;
   MulleBitmapImage   *bitmapImage3;
   CGRect             frame;
   CGRect             bounds;
   CGContext          *context;
   UIWindow           *window;
   UIView             *view;
   UIButton           *button;
   UIButton           *insideButton;
   UIButton           *nestedButton;
   UIApplication      *application;

   image = [[[MulleSVGImage alloc] initWithBytes:svginput
                                          length:strlen( svginput) + 1] autorelease];
   fprintf( stderr, "image: %p\n", image);

   layer1 = [[[MulleSVGLayer alloc] initWithSVGImage:image] autorelease];
   [layer1 setCStringName:"layer1"];
   fprintf( stderr, "layer: %p\n", layer1);

   layer2 = [[[MulleSVGLayer alloc] initWithSVGImage:image] autorelease];
   [layer2 setCStringName:"layer2"];
   fprintf( stderr, "layer: %p\n", layer2);


   // layer = [[[CALayer alloc] init] autorelease];

   frame.origin       = CGPointMake( 0.0, 0.0);
   frame.size.width   = 320;
   frame.size.height  = 200;
   [layer1 setFrame:frame];
 //  [layer setBounds:CGRectMake( 0.0, 0.0, 200, 30)];
   [layer1 setBackgroundColor:getNVGColor( 0xD0D0E0FF)];
   [layer1 setBorderColor:getNVGColor( 0x80FF30FF)];
   [layer1 setBorderWidth:32.0f];
   [layer1 setCornerRadius:16.0f];

   frame.origin = CGPointMake( 320, 200);
   [layer2 setFrame:frame];

   bounds = [layer2 bounds];
   bounds.origin.x = -bounds.size.width / 2.0;
   [layer2 setBounds:bounds];
   [layer2 setBackgroundColor:getNVGColor( 0x402060FF)];


   bitmapImage1 = [[[MulleBitmapImage alloc] initWithConstBytes:viech_bitmap
                                                     bitmapSize:viech_bitmap_size]
                                                  autorelease];
   fprintf( stderr, "image: %p\n", bitmapImage1);

   bitmapImage2 = [[[MulleBitmapImage alloc] initWithConstBytes:sealie_bitmap
                                                     bitmapSize:sealie_bitmap_size]
                                                  autorelease];
   fprintf( stderr, "image: %p\n", bitmapImage2);

   bitmapImage3 = [[[MulleBitmapImage alloc] initWithConstBytes:turtle_bitmap
                                                     bitmapSize:turtle_bitmap_size]
                                                  autorelease];
   fprintf( stderr, "image: %p\n", bitmapImage3);


   layer3 = [[[MulleBitmapLayer alloc] initWithBitmapImage:bitmapImage1] autorelease];
   [layer3 setCStringName:"layer3-viech"];
   frame.origin       = CGPointMake( 320.0, 0.0);
   frame.size.width   = 320;
   frame.size.height  = 200;
   [layer3 setFrame:frame];
   fprintf( stderr, "layer: %p\n", layer3);

   layer4 = [[[MulleBitmapLayer alloc] initWithBitmapImage:bitmapImage2] autorelease];
   [layer4 setCStringName:"layer4-sealie"];
   frame.origin       = CGPointMake( 30.0, 2.0);
   frame.size.width   = 102;
   frame.size.height  = 100;
   [layer4 setFrame:frame];
   fprintf( stderr, "layer: %p\n", layer4);

   layer5 = [[[MulleBitmapLayer alloc] initWithBitmapImage:bitmapImage3] autorelease];
   [layer5 setCStringName:"layer5-turtle"];
   frame.origin       = CGPointMake( -50.0, 10.0);
   frame.size.width   = 100;
   frame.size.height  = 117;
   [layer5 setFrame:frame];
   fprintf( stderr, "layer: %p\n", layer5);

   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 640.0, 400.0)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   context = [CGContext new];

#if 1
   view = [[[UIView alloc] initWithLayer:layer1] autorelease];
   [window addSubview:view];
#endif

   view = [[[UIView alloc] initWithLayer:layer2] autorelease];
   [window addSubview:view];
#if 1
   button = [[[UIButton alloc] initWithLayer:layer3] autorelease];
   // [button setClipsSubviews:YES];
   [button setClick:button_callback];

   [window addSubview:button];

   insideButton = [[[UIButton alloc] initWithLayer:layer4] autorelease];
   // [insideButton setClipsSubviews:YES];
   [insideButton setClick:button_callback];
   [button addSubview:insideButton];

   nestedButton = [[[UIButton alloc] initWithLayer:layer5] autorelease];
   // [insideButton setClipsSubviews:YES];
   [nestedButton setClick:button_callback];
   [insideButton addSubview:nestedButton];
#endif
   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

