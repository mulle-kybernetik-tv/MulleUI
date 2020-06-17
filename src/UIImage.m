#import "UIImage.h"

#import "CGContext.h"


@implementation UIImage 

// "abstract"
- (Class) preferredLayerClass
{
	return( Nil);
}

- (int) textureIDWithContext:(CGContext *) context
{
   return( context ? [context registerTextureIDForImage:self] : -1);
}

- (int) nvgImageFlags
{
   return( 0);
}

- (UIImage *) imageWithNVGImageFlags:(int) flags
{
   if( flags == [self nvgImageFlags])
      return( self);
   return( nil);
}

@end
