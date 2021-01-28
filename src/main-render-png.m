#import "import-private.h"

#import "MulleBitmapImage.h"
#import "MulleTextureImage.h"
#import "MulleBitmapImage+PNG.h"
#import "UIImageView.h"
#import "UIStackView.h"
#import "CGContext.h"
#import "CGContext+CGFont.h"
#import "CAGradientLayer.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIColor.h"
#import "UIFont.h"
#import "UIEvent.h"
#import "UILabel.h"
#import "MullePaint.h"
#import "MulleLayout.h"
#import <string.h>


#include "sealie-bitmap.inc"
#include "turtle-bitmap.inc"
#include "viech-bitmap.inc"

void   set_layer_background( CAGradientLayer *layer, CGContext *context)
{
   CGRect              rect;
   CGPoint             end;
   MulleBitmapImage    *image;
   MullePaint          *paint;

#if 1
   // /home/src/srcO/MulleUI/emiliano-arano-pixelized.png
   rect  = [layer frame];
   image = [[[MulleBitmapImage alloc] initWithContentsOfFileWithFileRepresentationString:"emiliano-arano-pixelized.png"] autorelease];
   end   = CGPointMake( CGRectGetMaxX( rect), CGRectGetMaxY( rect));
   paint = [[[MullePaint alloc] initImagePatternWithBitmapImage:image
                                                         origin:rect.origin
                                                            end:end
                                                          angle:0.0
                                                          alpha:1.0
                                                      CGContext:context] autorelease];
#else
   paint = [[[MullePaint alloc] initLinearGradientWithStartPoint:CGPointMake( CGRectGetMinX( rect), CGRectGetMinY( rect))
                                         endPoint:CGPointMake( CGRectGetMaxX( rect), CGRectGetMaxY( rect))
                                       innerColor:MulleColorCreate( 0x00FF00FF)
                                       outerColor:MulleColorCreate( 0xFF0000FF)
                                        CGContext:context] autorelease];

#endif

   [layer setPaint:paint];
}


static CAGradientLayer  *hackLayer;


UIView   *setupScene( UIWindow *window, CGContext *context, int argc, char *argv[])
{
   UIView              *view;
   CGRect              frame;
   CGRect              usable;
   CGRect              rect;
   CGPoint             end;
   CGPoint             referenceCenter;
   CGSize              size;
   UIEdgeInsets        insets;
   MulleBitmapImage    *image;
   UILabel             *label;
   MullePaint          *paint;
   CAGradientLayer     *layer;
   struct MulleLayout  scene;

   frame        = [window frame];
   frame.origin = CGPointZero;
   insets       = UIEdgeInsetsMake( 40, 40, 40, 40);
   usable       = UIEdgeInsetsInsetRect( frame, insets);

   _MulleLayoutInitWithRect( &scene, usable);

   // ICON
   image = [[[MulleBitmapImage alloc] initWithContentsOfFileWithFileRepresentationString:"mulle-tiny-logo-255x256.png"] autorelease];
   rect  = _MulleLayoutAddToRowWithOverflow( &scene, [image size], UIEdgeInsetsMake( 0, 0, 64, 64));
   view  = [[[UIImageView alloc] initWithImage:image] autorelease];
   [view setFrame:rect];

   referenceCenter = MulleRectGetCenter( rect);

   [[window contentPlane] addSubview:view];

#if 0
   // EMOJI
   size = CGSizeMake( 120, 120);
   rect = _MulleLayoutAddToRowWithOverflow( &scene, size, UIEdgeInsetsMake( 32, 32, 32, 32));

   rect = MulleRectAlignCenterInRow( rect, referenceCenter);
   {
      label = [UILabel mulleViewWithFrame:rect];

      [label setCString:argv[ 2]];
      [label setFontPixelSize:110];  // why ?
      [label setAlignmentMode:CAAlignmentCenter];
      [label mulleSetVerticalAlignmentMode:MulleTextVerticalAlignmentBoundsMiddle];
      [label setBackgroundColor:MulleColorCreate( 0xFFFFFF40)];
      [label setTextColor:MulleColorCreate( 0x101020FF)];

      [[window contentPlane] addSubview:label];
   }
#endif

   // TITLE
   size.width  = _MulleLayoutGetRemainingRowSize( &scene).width;
   size.height = 64.0;
   rect = _MulleLayoutAddToRowWithOverflow( &scene, size, UIEdgeInsetsMake( 0, 0, 0, 0));
   if( rect.size.width == 0.0)
      exit( 1);

   rect = MulleRectAlignCenterInRow( rect, referenceCenter);

   {
      label = [UILabel mulleViewWithFrame:rect];

      [label setCString:argv[ 1]];

      [label setFont:[UIFont fontWithNameCString:"hacked"]];
      [label setFontPixelSize:64.0];
      [label setInsets:UIEdgeInsetsMake( 0, 16, 0, 0)];
      [label setAlignmentMode:CAAlignmentLeft];
      [label mulleSetVerticalAlignmentMode:MulleTextVerticalAlignmentBoundsMiddle];
      [label setBackgroundColor:MulleColorCreate( 0xFFFFFF40)];
      [label setTextColor:MulleColorCreate( 0x101020FF)];
//      [label setTextBackgroundColor:MulleColorCreate( 0xFFFFFF40)];

      [[window contentPlane] addSubview:label];
   }

#if 0
   // MULTILINE TEXT

   _MulleLayoutNewRow( &scene);

   size.width  = usable.size.width;
   size.height = _MulleLayoutGetRemainingRowSize( &scene).height - 32.0;
   rect = _MulleLayoutAddToRowWithOverflow( &scene, size, UIEdgeInsetsMake( 32, 0, 0, 0));
   if( rect.size.width == 0.0)
      exit( 2);

   {
      struct mulle_buffer  buffer;
      char                 **s;
      char                 **sentinel;

      mulle_buffer_init( &buffer, NULL);

      s = &argv[ 3];
      sentinel = &argv[ argc];
      while( s < sentinel)
      {
         mulle_buffer_add_string( &buffer, *s);
         mulle_buffer_add_string( &buffer, "\n");
         ++s;
      }

      label = [UILabel mulleViewWithFrame:rect];
      [label setCString:mulle_buffer_get_string( &buffer)];
      mulle_buffer_done( &buffer);

      [label setFontSize:20.0];
      // [label setFont:[UIFont boldSystemFontOfSize:40.0]];
      [label setInsets:UIEdgeInsetsMake( 8, 16, 8, 16)];
      [label setLineBreakMode:NSLineBreakByWordWrapping];
      [label setAlignmentMode:CAAlignmentLeft];
      [label mulleSetVerticalAlignmentMode:MulleTextVerticalAlignmentTop];
      [label setBackgroundColor:MulleColorCreate( 0xFFFFFF40)];
      [label setTextColor:MulleColorCreate( 0x101020FF)];

      [[window contentPlane] addSubview:label];
   }
#endif

   view  = [window contentPlane];
#if 1
   rect  = [view frame];
   layer = [[[CAGradientLayer alloc] initWithFrame:rect] autorelease];

   set_layer_background( layer, context);
   hackLayer = layer;

   [view addLayer:layer];
#endif
   return( view);
}


static void   printImage( UIWindow *window, CGContext *context)
{
   struct MulleFrameInfo   info;
   MulleTextureImage       *image;
   MulleBitmapImage        *bitmapImage;
//   CGContext               *context;
   UIView                  *view;

   view = [window contentPlane];

   assert( view);
   // [view layout];

   [window getFrameInfo:&info];

   info.frame.size      =
   info.windowSize      =
   info.framebufferSize = [view frame].size;
   info.UIScale.dx      = 1.0;
   info.UIScale.dy      = 1.0;
   info.pixelRatio      = 1.0; // difference framebuffer / window (egal)

   // image is only valid as long as context exists, get rid of it as soon
   // as possible, or until we can make it better...
   @autoreleasepool
   {
      image = (MulleTextureImage *) [view textureImageWithContext:context
                                                        frameInfo:&info
                                                          options:NVG_IMAGE_FLIPY];
      bitmapImage = [image bitmapImage];
      [bitmapImage writeToPNGFileWithSystemRepresentation:"render-png.png"];
   }
}


// #1 name
// #2 emoji
// #3-#n text lines

int   main( int argc, char *argv[])
{
   CGContext                     *context;
   UIWindow                      *window;
   UIView                        *view;
   MulleTextureImage             *image;
   MulleBitmapImage              *bitmapImage;
   CGSize                        windowSize;

   if( argc < 3)
   {
      fprintf( stderr, "usage: Title Emoji Text\n");
      return( -1);
   }

   windowSize = CGSizeMake( 1280, 640);

#if 0
   // produces shader vert error, which is boring
   // this is just an assert to verify that a CGContext can't live w/o a
   // window
   context = [[CGContext new] autorelease];
   assert( ! context);  // can't work without a window
#endif

   window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0,
                                                         0.0,
                                                         windowSize.width,
                                                         windowSize.height)
                                titleCString:NULL
                                   styleMask:MulleWindowStyleMaskInvisible] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   //
   // get rid of context before terminate
   //
   @autoreleasepool
   {
      context = [[CGContext new] autorelease];
      [context setBackgroundColor:CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0)];
      [context addFontWithContentsOfFileWithFileRepresentationString:"Roboto-Regular-Hacked.ttf"
                                                     fontNameCString:"hacked"];
      view = setupScene( window, context, argc, argv);

      // view is already nicely layouted
      printImage( window, context);
   }

   [[UIApplication sharedInstance] terminate];
}
