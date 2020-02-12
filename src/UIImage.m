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
   return( context ? [context registeredTextureIDForImage:self] : -1);
}

@end
