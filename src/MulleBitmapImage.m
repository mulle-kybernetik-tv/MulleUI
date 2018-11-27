#import "import-private.h"

#import "MulleBitmapImage.h"

#import "stb_image.h"


@implementation MulleBitmapImage

- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) filename
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
	return( self);
}


- (instancetype) initWithConstBytes:(const void *) bytes 
                         bitmapSize:(mulle_bitmap_size) bitmapSize
{
   _image = (void *) bytes;
	if( ! _image) 
   {
      [self release];
      return( nil);
   }

   _bitmapSize = bitmapSize;

	return( self);
}                    

- (instancetype) initWithBytes:(void *) bytes 
                        length:(NSUInteger) length
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

	return( self);
}

- (void) dealloc
{
   if( _shouldFree)
      stbi_image_free( _image);
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

@end
