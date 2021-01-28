//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MulleBitmapImage+PNG.h"

#import "import-private.h"

#include <zlib.h>

// stolen from https://github.com/DanielGibson/stb/commit/1dae231b1ec01b403a937ffe04421ca4e287efc2
static unsigned char  *compress_for_stbiw( unsigned char *data,
                                    int data_len,
                                    int *out_len,
                                    int quality)
{
   uLongf          bufSize = compressBound( data_len);
   unsigned char   *buf = malloc(bufSize);

   if( buf == NULL)
      return( buf);

   if( compress2( buf, &bufSize, data, data_len, quality) != Z_OK)
   {
      free( buf);
      return( NULL);
   }
   *out_len = bufSize;

   return( buf);
}

// stb_image is owned by nanovg, but we own stb_image_write
#define STBIW_ZLIB_COMPRESS compress_for_stbiw
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"


@implementation MulleBitmapImage ( PNG)


- (id) initWithPNGData:(NSData *) data
{
   return( [self initWithCData:mulle_data_make( [data bytes], [data length])
                         allocator:NULL
                     nvgImageFlags:0]);
}


- (BOOL) writeToPNGFileWithSystemRepresentation:(char *) filename
{
   int                        rval;
   struct mulle_bitmap_size   bitmapSize;
   void                       *image;

   bitmapSize = [self bitmapSize];
   image      = [self image];
   if( ! image)
      return( NO);

   rval = stbi_write_png( filename,
                          bitmapSize.size.width,
                          bitmapSize.size.height,
                          4,
                          image,
                          bitmapSize.size.width * bitmapSize.colorComponents);
   return( rval != 0);
}


static void   appendData(void *context, void *data, int size)
{
   NSMutableData   *buffer = context;

   [buffer appendBytes:data
                length:size];
}


- (NSData *) PNGData
{
   int                        rval;
   NSMutableData              *buffer;
   NSUInteger                 lineLength;
   void                       *image;
   struct mulle_bitmap_size   bitmapSize;

   image = [self image];
   if( ! image)
      return( nil);

   bitmapSize = [self bitmapSize];
   lineLength = bitmapSize.size.width * bitmapSize.colorComponents;

   buffer = [NSMutableData dataWithCapacity:1024 + bitmapSize.size.width * lineLength];
   rval   = stbi_write_png_to_func( appendData,
                                    buffer,
                                    bitmapSize.size.width,
                                    bitmapSize.size.height,
                                    4,
                                    image,
                                    lineLength);
   if( rval == 0)
      return( nil);

    // shrink to fit
   [buffer setLength:[buffer length]];
   return( buffer);
}

@end
