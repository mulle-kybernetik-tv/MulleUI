#import "import-private.h"

#import "MulleBitmapImage.h"

#include "stb_image.h"
#include "bmp-writer.h"


@implementation MulleBitmapImage

struct mulle_allocator    stbi_allocator;  // no contents

+ (void) initialize
{
	stbi_set_unpremultiply_on_load(1);
	stbi_convert_iphone_png_to_rgb(1);   
}


- (instancetype) initWithMulleData:(struct mulle_data) data 
                         allocator:(struct mulle_allocator *) allocator
{
   int   w;
   int   h;
   int   n;

	_image = stbi_load_from_memory( data.bytes, (int) data.length, &w, &h, &n, 4);
	if( ! _image) 
   {
      [self release];
      return( nil);
   }

   self = [super initWithMulleData:data
                         allocator:allocator];

   _bitmapSize.size.width      = w;
   _bitmapSize.size.height     = h;
   _bitmapSize.colorComponents = n;

	return( self);
}

- (instancetype) initWithMulleData:(struct mulle_data) data 
                         allocator:(struct mulle_allocator *) allocator
                     nvgImageFlags:(int) flags
{
   self = [self initWithMulleData:data
                        allocator:allocator];
   if( self)
      _nvgImageFlags = flags;
   return( self);
}


//
// here bytes is a loaded stbi_image already (?)
// so we don't have any fileData!
//
- (instancetype) initWithConstBitmapBytes:(const void *) bytes 
                               bitmapSize:(mulle_bitmap_size) bitmapSize
{
   _image = (void *) bytes;
	if( ! _image) 
   {
      [self release];
      return( nil);
   }

   _dontFreeImage = YES;
   _bitmapSize    = bitmapSize;

	return( self);
}    


// here bytes is a loaded stbi_image already (?)
- (instancetype) initWithConstBitmapBytes:(const void *) bytes 
                               bitmapSize:(mulle_bitmap_size) bitmapSize
                            nvgImageFlags:(int) flags
{
   self = [self initWithConstBitmapBytes:bytes
                              bitmapSize:bitmapSize];
   if( self)
      _nvgImageFlags = flags;
   return( self);
}


- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) filename
                                                      nvgImageFlags:(int) flags
{
   self = [self initWithContentsOfFileWithFileRepresentationString:filename];
   if( self)
      _nvgImageFlags = flags;
 
	return( self);
}


- (void) dealloc
{
   if( ! _dontFreeImage)
      stbi_image_free( _image);
   [_imageSharingObject release];

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


- (struct mulle_data) mulleBitmapData
{
   return( mulle_data_make( _image,
                            (NSUInteger) _bitmapSize.size.width * _bitmapSize.size.height * _bitmapSize.colorComponents));

}


- (mulle_int_size) intSize
{
   return( _bitmapSize.size);
}


- (mulle_bitmap_size) bitmapSize
{
   return( _bitmapSize);
}


- (BOOL) writeToBMPFileWithSystemRepresentation:(char *) filename
{
   mulle_int_size   size;

   if( ! filename || ! *filename)
      return( NO);

   size = _bitmapSize.size;
   return( ! bmp_rgb32_write_file( filename, _image, size.width, size.height, 0) ? YES : NO);
}


// TODO: war früher echte copy, aber das geht nicht, wegen double-free
//       und wozu ? Ist eh R/O
- (id) copy
{
   return( [self retain]);
}


// derive an image with different flags for NVG
- (UIImage *) imageWithNVGImageFlags:(int) flags
{
   MulleBitmapImage   *copy;

   if( flags == _nvgImageFlags)
      return( self);

   copy = NSCopyObject( self, 0, NULL);

   copy->_nvgImageFlags      = flags;
   copy->_imageSharingObject = [self retain];
   copy->_dontFreeImage      = YES;
   copy->_fileDataAllocator  = NULL;
   [copy->_fileDataSharingObject retain];

   return( [copy autorelease]);
}

@end
