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



//
// here bytes is a loaded stbi_image already (?)
// so we don't have any fileData!
//
- (instancetype) initWithConstRGBA:(const void *) bytes 
                        bitmapSize:(struct mulle_bitmap_size) bitmapSize
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
- (instancetype) initWithConstRGBA:(const void *) bytes 
                        bitmapSize:(mulle_bitmap_size) bitmapSize
                     nvgImageFlags:(int) flags
{
   self = [self initWithConstRGBA:bytes
                       bitmapSize:bitmapSize];
   if( self)
      _nvgImageFlags = flags;
   return( self);
} 


- (instancetype) initWithRGBAMulleData:(struct mulle_data) data 
                            bitmapSize:(mulle_bitmap_size) bitmapSize
                             allocator:(struct mulle_allocator *) allocator
                         nvgImageFlags:(int) flags
{
   self = [self initWithConstRGBA:(const void *) data.bytes
                       bitmapSize:bitmapSize
                    nvgImageFlags:flags];
   if( self)
   {
      _fileData           = data;
      _fileDataAllocator  = allocator;
      _fileEncoding       = UIImageDataEncodingRGBA;
   }

   return( self);
} 


enum UIImageDataEncoding   MulleBitmapImageDataEncodingFromMulleData(struct mulle_data data)
{
   // can't do this, because stbi__context is unavailable as are the
   // various test methods

   // https://en.wikipedia.org/wiki/Portable_Network_Graphics
   static uint8_t   png_header[] = { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0xA };
   uint8_t          *start;
   uint8_t          *end;

   if( data.length > sizeof( png_header) && 
      ! memcmp( data.bytes, png_header, sizeof( png_header)))
   {      
      return( UIImageDataEncodingPNG);
   }
   
   // https://stackoverflow.com/questions/4550296/how-to-identify-contents-of-a-byte-is-a-jpeg
   if( data.length > 4)
   {
      start = data.bytes;
      end   = &start[ data.length];
      if( start[ 0] == 0xFF && start[ 1] == 0xD8 &&
          end[ -2] == 0xFF && end[ -1] == 0xD9)
      {
         return( UIImageDataEncodingJPG);
      }

      if( start[ 0] == 'B' && start[ 1] == 'M')
         return( UIImageDataEncodingBMP);
   }

   return( UIImageDataEncodingUnknown);
}


- (instancetype) initWithFileMulleData:(struct mulle_data) data 
                             allocator:(struct mulle_allocator *) allocator
{
   int   w;
   int   h;
   int   n;

	_image = stbi_load_from_memory( data.bytes, (int) data.length, &w, &h, &n, 4);
	if( ! _image || ! w || ! h || ! n) 
   {
      [self release];
      return( nil);
   }

   self = [super initWithFileMulleData:data
                             allocator:allocator];

   _bitmapSize.size.width      = w;
   _bitmapSize.size.height     = h;
   _bitmapSize.colorComponents = n;

   _fileEncoding = MulleBitmapImageDataEncodingFromMulleData( data);

	return( self);
}

- (instancetype) initWithFileMulleData:(struct mulle_data) data 
                             allocator:(struct mulle_allocator *) allocator
                         nvgImageFlags:(int) flags
{
   self = [self initWithFileMulleData:data
                            allocator:allocator];
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


- (void *) bytes
{
   return( _image);
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
