#import "MulleBitmapLayer.h"

#import "MulleBitmapImage.h"
#import "CGContext.h"

#import "nanovg.h"


static NVGcolor getNVGColor(uint32_t color) 
{
	return nvgRGBA(
		(color >> 24) & 0xff,
		(color >> 16) & 0xff,
		(color >> 8) & 0xff,
		(color >> 0) & 0xff);
}


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
