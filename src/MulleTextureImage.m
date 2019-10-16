#import "MulleTextureImage.h"

#import "CGContext.h"

#import "import-private.h"


@implementation MulleTextureImage

- (instancetype) initWithSize:(CGSize) size
                      options:(NSUInteger) options
                      context:(CGContext *) context
{
   assert( context && [context isKindOfClass:[CGContext class]]);

   // TODO: would like to move this code to CGContext
   _framebuffer = nvgluCreateFramebuffer( [context nvgContext], size.width, size.height, options);
   if( ! _framebuffer)
   {
      [self release];
      return( nil);
   }


   //
   // image is dependent on the graphics context, and can't live without it
   //
   _context = context;
   _size    = size;
   return( self);
}


- (int) textureIDWithContext:(CGContext *) context
{
   if( context != _context)
      return( -1);
   return( ((NVGLUframebuffer *) _framebuffer)->image);
}


- (void) finalize
{
   [_context removeTextureImage:self];   
   if( _framebuffer)
   	nvgluDeleteFramebuffer((NVGLUframebuffer *) _framebuffer);   
   [super finalize];
}

@end

