#import "import-private.h"

#import "MulleBitmapImage.h"

#import "stb_image.h"
#include "bmp-writer.h"


@implementation MulleBitmapImage

- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) filename
                                                      nvgImageFlags:(int) flags
{
   int   w;
   int   h;
   int   n;

	stbi_set_unpremultiply_on_load(1);
	stbi_convert_iphone_png_to_rgb(1);

	_image = stbi_load( filename, &w, &h, &n, 4);
	if( ! _image) 
   {
      [self release];
      return( nil);
   }

   _bitmapSize.size.width      = w;
   _bitmapSize.size.height     = h;
   _bitmapSize.colorComponents = n;
   _shouldFree                 = YES;
   _nvgImageFlags             = flags;

	return( self);
}


- (instancetype) initWithConstBytes:(const void *) bytes 
                         bitmapSize:(mulle_bitmap_size) bitmapSize
                      nvgImageFlags:(int) flags
{
   _image = (void *) bytes;
	if( ! _image) 
   {
      [self release];
      return( nil);
   }

   _bitmapSize    = bitmapSize;
   _nvgImageFlags = flags;

	return( self);
}                    

- (instancetype) initWithBytes:(void *) bytes 
                        length:(NSUInteger) length
                 nvgImageFlags:(int) flags
{
   int   w;
   int   h;
   int   n;

	_image = stbi_load_from_memory( bytes, (int) (NSInteger) length, &w, &h, &n, 4);
	if( ! _image) 
   {
      [self release];
      return( nil);
   }

   _bitmapSize.size.width      = w;
   _bitmapSize.size.height     = h;
   _bitmapSize.colorComponents = n;
   _shouldFree                 = YES;
   _nvgImageFlags              = flags;

	return( self);
}


- (instancetype) initWithBytes:(void *) bytes 
                        length:(NSUInteger) length
{
   return( [self initWithBytes:bytes
                        length:length
                        nvgImageFlags:0]);
}

- (instancetype) initWithConstBytes:(const void *) bytes 
                         bitmapSize:(mulle_bitmap_size) bitmapSize;
{
   return( [self initWithConstBytes:bytes
                         bitmapSize:bitmapSize
                      nvgImageFlags:0]);
}

- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) s;
{
   return( [self initWithContentsOfFileWithFileRepresentationString:s
                                                      nvgImageFlags:0]);
}

- (void) dealloc
{
   if( _shouldFree)
      stbi_image_free( _image);
   [_parent release];

   [super dealloc];
}


- (CGSize) size
{
   return( CGSizeMake( _bitmapSize.size.width, _bitmapSize.size.height));
}


- (CGRect) visibleBounds
{
   return( CGRectMake( 0.0, 0.0, _bitmapSize.size.width, _bitmapSize.size.height));
}


- (void *) bytes
{
   return( _image);
}


- (mulle_int_size) intSize
{
   return( _bitmapSize.size);
}


- (mulle_bitmap_size) bitmapSize
{
   return( _bitmapSize);
}


- (NSUInteger) length
{
   return( (NSUInteger) _bitmapSize.size.width * _bitmapSize.size.height * _bitmapSize.colorComponents);
}

- (BOOL) writeToBMPFileWithSystemRepresentation:(char *) filename
{
   mulle_int_size   size;

   if( ! filename || ! *filename)
      return( NO);

   size = _bitmapSize.size;
   return( ! bmp_rgb32_write_file( filename, _image, size.width, size.height, 0) ? YES : NO);
}


// derive and image with different flags for NVG
- (UIImage *) imageWithNVGImageFlags:(int) flags
{
   MulleBitmapImage   *copy;

   if( flags == _nvgImageFlags)
      return( self);

   copy = [self copy];
   copy->_nvgImageFlags = flags;
   copy->_parent        = [self retain];
   copy->_shouldFree    = NO;

   return( [copy autorelease]);
}

@end
