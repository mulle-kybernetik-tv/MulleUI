#import "MulleImageLayer.h"

#import "UIImage.h"
#import "CGContext.h"


@implementation UIImage( MulleImageLayer)

- (Class) preferredLayerClass
{
	return( [MulleImageLayer class]);
}

@end


@implementation MulleImageLayer

- (instancetype) initWithImage:(UIImage *) image
{
   CGRect   bounds;

	assert( ! image || [image isKindOfClass:[UIImage class]]);

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
   int              textureId;
   NVGpaint         imgPaint;
   NVGcontext       *vg;
   CGSize           imageSize;
   CGRect           frame;

   if( ! [super drawInContext:context])
      return( NO);

   if( ! _image)
      return( YES);

   textureId = [context textureIDForImage:_image];
   if( textureId == -1)
   {
      // or draw black ?
      assert( 0);
      return( YES);
   }

   imageSize = [_image size];
   frame     = [self frame];
   vg        = [context nvgContext];
   imgPaint  = nvgImagePattern( vg, 0, 0, imageSize.width, imageSize.height, 0.0f/180.0f*NVG_PI, textureId, 1.0);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, 0,
                       0,
                       imageSize.width,
                       imageSize.height,
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
