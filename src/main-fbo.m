#import "import-private.h"

#import "MulleBitmapImage.h"
#import "MulleTextureImage.h"
#import "MulleBitmapImage+PNG.h"
#import "UIImageView.h"
#import "UIStackView.h"
#import "CGContext.h"
#import "CAGradientLayer.h"
#import "UIWindow.h"
#import "UIApplication.h"
#import "UIColor.h"
#import "UIEvent.h"
#import "UILabel.h"
#import "MullePaint.h"
#import "MulleLayout.h"
#import "CGGeometry.h"
#import <string.h>


static MulleTextureImage   *textureImageWithSize( CGSize size, CGContext *context, NSUInteger options)
{
   struct MulleFrameInfo      renderInfo;
   MulleTextureImage          *image;
   CGRect                     frame;
   struct mulle_bitmap_size   bitmapSize;
   NVGcontext                 *vg;

   frame.origin                      = CGPointZero;
   frame.size                        = size;

   renderInfo.frame                  = frame;
   renderInfo.windowSize             = frame.size;
   renderInfo.framebufferSize.width  = frame.size.width;
   renderInfo.framebufferSize.height = frame.size.height;
   renderInfo.UIScale                = CGVectorMake( 1, 1);
   renderInfo.pixelRatio             = 1.0;
   renderInfo.isPerfEnabled          = NO;

   bitmapSize.size.width      = (int) (renderInfo.framebufferSize.width + 0.5);
   bitmapSize.size.height     = (int) (renderInfo.framebufferSize.height + 0.5);
   bitmapSize.colorComponents = 4;
  
   image = [context framebufferImageWithBitmapSize:bitmapSize
                                           options:options];
   if( ! image)
      return( image);
   
   // render view into a framebuffer tied to the texture
   nvgluBindFramebuffer( [image framebuffer]);
   @autoreleasepool
   {
      [context startRenderWithFrameInfo:&renderInfo];
      [context clearFramebuffer];

      vg = [context nvgContext];

      nvgCreateFont( vg, "foo", "Anonymous Pro.ttf");

      if( options & NVG_IMAGE_FLIPY)
      {
         nvgScale( vg, 1.0, -1.0);
         nvgTranslate( vg, -frame.origin.x, -frame.origin.y - frame.size.height);
      }
      else
         nvgTranslate( vg, -frame.origin.x, -frame.origin.y);


      nvgBeginPath( vg);
      nvgRoundedRect( vg, frame.origin.x ,
                          frame.origin.y + 20,
                          frame.size.width,
                          frame.size.height -20,
                          40);
      nvgFillColor(vg, nvgRGBA(220,160,0,255));
      nvgFill( vg);

      nvgFontFace( vg, "foo");
      nvgFontSize( vg, 64);
      nvgTextColor( vg, nvgRGBA(0,0,0,255), nvgRGBA(220,160,0,255)); // TODO: use textColor
      nvgText( vg, frame.origin.x + frame.size.width / 2.0, 
                   frame.origin.y + frame.size.height / 2.0, 
                   "XX1XX", NULL);
      nvgText( vg, -frame.origin.x, 
                   frame.origin.y, 
                   "XX2XX", NULL);
      nvgText( vg, -frame.origin.x, 
                   -frame.origin.y, 
                   "XX3XX", NULL);
      nvgText( vg, 0, 
                   0, 
                   "XX4XX", NULL);
      nvgText( vg, -frame.origin.x, 
                   frame.origin.y, 
                   "XX5XX", NULL);

      [context endRender];
   }
   nvgluBindFramebuffer( NULL);

   return( image);
}



static void   printImage( UIWindow *window, CGContext *context)
{
   MulleTextureImage   *image;
   MulleBitmapImage    *bitmapImage;


   // image is only valid as long as context exists, get rid of it as soon
   // as possible, or until we can make it better...
   @autoreleasepool
   {
      image       = textureImageWithSize( [[window contentPlane] frame].size, context, NVG_IMAGE_FLIPY);
      bitmapImage = [image bitmapImage];                                                               
      [bitmapImage writeToPNGFileWithSystemRepresentation:"fbo.png"];
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

   /*
    * window and app 
    */
   @autoreleasepool
   {
      windowSize = CGSizeMake( 1280, 640);

      context = [[CGContext new] autorelease];
      assert( ! context);  // can't work without a window

      window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 
                                                            0.0, 
                                                            windowSize.width, 
                                                            windowSize.height)] autorelease];
      assert( window);

      [[UIApplication sharedInstance] addWindow:window];

      context = [[CGContext new] autorelease];

      // view is already nicely layouted
      printImage( window, context);

      [[UIApplication sharedInstance] terminate];
   }
}
