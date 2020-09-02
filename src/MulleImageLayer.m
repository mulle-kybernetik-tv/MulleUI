#import "MulleImageLayer.h"

#import "UIImage.h"
#import "CGContext.h"

// #define RENDER_DEBUG

@implementation UIImage( MulleImageLayer)

#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

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

// rename to drawWithContext: ?
- (BOOL) drawInContext:(CGContext *) context
{
   int          textureId;
   NVGpaint     imgPaint;
   NVGcontext   *vg;
   CGSize       imageSize;

   if( ! [super drawInContext:context])
   {
#ifdef RENDER_DEBUG
      fprintf( stderr, "%s drawInContext said NO\n", [self cStringDescription]);
#endif   
      return( NO);
   }

   if( ! _image)
      return( YES);
     
   textureId = [_image textureIDWithContext:context];
   if( textureId == -1)
   {
      // or draw black ?
      assert( 0);
      return( YES);
   }

   // TODO: check contentMode and translate/scale accordingly

   imageSize = [_image size];
   vg        = [context nvgContext];
   imgPaint  = nvgImagePattern( vg, 0, 0, imageSize.width, imageSize.height, 0.0f/180.0f*NVG_PI, textureId, 1.0);

   nvgBeginPath( vg);
   // shouldn't this be the frame ?
   nvgRoundedRect( vg, 0,
                       0,
                       imageSize.width,
                       imageSize.height,
                       (int) _cornerRadius);
   nvgFillPaint( vg, imgPaint);
  // nvgFillColor( vg, getNVGColor( 0x402060FF));
   nvgFill( vg);

   return( YES);
}


- (CGRect) visibleBounds
{
   CGRect   bounds;

   bounds = [_image visibleBounds];
   return( bounds);
}

@end
