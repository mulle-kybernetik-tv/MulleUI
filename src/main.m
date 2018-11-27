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


//	stolen from catgl ©2015,2018 Yuichiro Nakada
#define W  200
#define H  100

#include "tiger-svg.inc"
#include "sealie-bitmap.inc"

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
   fprintf( stderr, "callback\n");
   return( nil);
}


int   main()
{
   MulleSVGLayer      *layer1;
   MulleSVGLayer      *layer2;
   MulleBitmapLayer   *layer3;
   MulleBitmapLayer   *layer4;
   MulleSVGImage      *image;
   MulleBitmapImage   *bitmapImage;
   CGRect             frame;
   CGRect             bounds;
   CGContext          *context;
   UIWindow           *window;
   UIView             *view;
   UIButton           *button;
   UIButton           *insideButton;
   UIApplication      *application;

   image = [[[MulleSVGImage alloc] initWithBytes:svginput
                                          length:strlen( svginput) + 1] autorelease];
   fprintf( stderr, "image: %p\n", image);

   layer1 = [[[MulleSVGLayer alloc] initWithSVGImage:image] autorelease];
   fprintf( stderr, "layer: %p\n", layer1);

   layer2 = [[[MulleSVGLayer alloc] initWithSVGImage:image] autorelease];
   fprintf( stderr, "layer: %p\n", layer2);


   bitmapImage = [[[MulleBitmapImage alloc] initWithConstBytes:sealie_bitmap
                                                    bitmapSize:sealie_bitmap_size]
                                                  autorelease];
   fprintf( stderr, "image: %p\n", bitmapImage);

   layer3 = [[[MulleBitmapLayer alloc] initWithBitmapImage:bitmapImage] autorelease];


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

   frame.origin       = CGPointMake( 320.0, 0.0);
   frame.size.width   = 320;
   frame.size.height  = 200;
   [layer3 setFrame:frame];
   fprintf( stderr, "layer: %p\n", layer3);

   layer4 = [[[MulleBitmapLayer alloc] initWithBitmapImage:bitmapImage] autorelease];
   frame.origin       = CGPointMake( 80.0, 80.0);
   frame.size.width   = 120;
   frame.size.height  = 50;

   [layer4 setFrame:frame];
   fprintf( stderr, "layer: %p\n", layer4);

   window  = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 640.0, 400.0)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   context = [CGContext new];

   view = [[[UIView alloc] initWithLayer:layer1] autorelease];
   [window addSubview:view];
   view = [[[UIView alloc] initWithLayer:layer2] autorelease];
   [window addSubview:view];
   button = [[[UIButton alloc] initWithLayer:layer3] autorelease];
   [button setClick:button_callback];
   [window addSubview:button];

   insideButton = [[[UIButton alloc] initWithLayer:layer4] autorelease];
   [insideButton setClick:button_callback];
   [button addSubview:insideButton];

   [window renderLoopWithContext:context];

   [[UIApplication sharedInstance] terminate];
}

