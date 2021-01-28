#import "MulleTextureImage.h"

#import "CGContext.h"

#import "import-private.h"

#import "MulleBitmapImage.h"


@implementation MulleTextureImage

- (instancetype) initWithBitmapSize:(mulle_bitmap_size) bitmapSize
                            context:(CGContext *) context
                            options:(NSUInteger) options
{
   assert( context && [context isKindOfClass:[CGContext class]]);

   // TODO: would like to move this code to CGContext
   _image = nvgluCreateFramebuffer( [context nvgContext],
                                    bitmapSize.size.width,
                                    bitmapSize.size.height,
                                    options);
   if( ! _image)
   {
      [self release];
      return( nil);
   }

   //
   // Image is dependent on the graphics context, and can't live without it
   // TextureImage is threfore retained by the context and not the other way
   // (how long does the context live though)
   //
   _context       = context;
   _bitmapSize    = bitmapSize;
   _nvgImageFlags = options;

   return( self);
}


- (int) textureIDWithContext:(CGContext *) context
{
   if( context != _context)
      return( -1);
   return( ((NVGLUframebuffer *) _image)->image);
}


- (void) finalize
{
   [_context removeFramebufferImage:self];
   _context = nil;

   if( _image)
   {
   	nvgluDeleteFramebuffer((NVGLUframebuffer *) _image);
      _image = nil;
   }
   [super finalize];
}


- (void *) framebuffer
{
   return( _image);
}


- (void *) image
{
   return( NULL);
}


- (MulleBitmapImage *) bitmapImage
{
   struct mulle_data           data;
   MulleBitmapImage            *bitmapImage;
   struct mulle_bitmap_size    bitmapSize;
   void                        *framebuffer;

   framebuffer = [self framebuffer];
   if( ! framebuffer)
      return( nil);
   bitmapSize                 = _bitmapSize;
   bitmapSize.colorComponents = 4;

   data.length = bitmapSize.size.width * bitmapSize.size.height * 4;
   data.bytes  = mulle_allocator_malloc( &mulle_stdlib_allocator, data.length);
   memset( data.bytes, 0xFF, data.length);

   nvgluBindFramebuffer( framebuffer);
   {
      glReadPixels( 0, 0,
                   bitmapSize.size.width,
                   bitmapSize.size.height,
                   GL_RGBA,
    	             GL_UNSIGNED_BYTE,
    	             data.bytes);
   }
   nvgluBindFramebuffer( NULL);

   bitmapImage = [[MulleBitmapImage alloc] initWithRGBACData:data
                                                     bitmapSize:bitmapSize
                                                      allocator:&mulle_stdlib_allocator
                                                  nvgImageFlags:_nvgImageFlags];
   return( [bitmapImage autorelease]);
}

@end

