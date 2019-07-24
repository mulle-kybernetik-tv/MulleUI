#import "MulleBitmapLayer.h"

#import "MulleBitmapImage.h"
#import "CGContext.h"

#import "nanovg.h"
#include "bmp-writer.h"


@implementation MulleBitmapImage( MulleBitmapLayer)

- (Class) preferredLayerClass
{
	return( [MulleBitmapLayer class]);
}

@end


@implementation MulleBitmapLayer


- (instancetype) initWithBitmapImage:(MulleBitmapImage *) image
{
   CGRect   bounds;

	assert( ! image || [image isKindOfClass:[MulleBitmapImage class]]);

   if( ! (self = [super init]))
      return( self);

   _image = [image retain];  // ownership transfer
   if( image)
   {
      bounds.origin = CGPointMake( 0.0, 0.0);
      bounds.size   = [_image size];

      [self setBounds:bounds];
   }

   return( self);
}


- (BOOL) writeToBMPFileWithSystemRepresentation:(char *) filename
{
   mulle_int_size   size;

   if( ! filename || ! *filename)
      return( NO);

   size = [(MulleBitmapImage *) _image intSize];
   return( ! bmp_rgb32_write_file( filename, [_image bytes], size.width, size.height, 0) ? YES : NO);
}


- (void) dealloc
{
   [_image release];
   [super dealloc];
}


- (BOOL) drawInContext:(CGContext *) context
{
   mulle_int_size   size;
   int              textureId;
   NVGpaint         imgPaint;
   NVGcontext       *vg;

   if( ! [super drawInContext:context])
      return( NO);

   if( ! _image)
      return( YES);

   vg        = [context nvgContext];
   size      = [(MulleBitmapImage *) _image intSize];
   textureId = nvgCreateImageRGBA( vg, size.width, size.height, 0, [(MulleBitmapImage *) _image bytes]);
//   fprintf( stderr, "textureid: %d\n", textureId);

   imgPaint  = nvgImagePattern( vg, 0, 0, size.width, size.height, 0.0f/180.0f*NVG_PI, textureId, 1.0);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, 0,
                       0,
                       size.width,
                       size.height,
                       (int) _cornerRadius);
   nvgFillPaint( vg, imgPaint);
  // nvgFillColor( vg, getNVGColor( 0x402060FF));
   nvgFill( vg);

   // if I delete the image here, the texture is gone from the picture
   // nvgDeleteImage( vg, textureId);

   return( YES);
}


- (CGRect) visibleBounds
{
   CGRect   bounds;

   bounds = [_image visibleBounds];
   return( bounds);
}

@end
