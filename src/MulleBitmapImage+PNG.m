//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MulleBitmapImage+PNG.h"

#import "import-private.h"


// stb_image is owned by nanovg, but we own stb_image_write
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"


@implementation MulleBitmapImage ( PNG)


- (id) initWithPNGData:(NSData *) data
{
   return( [self initWithBytes:[data bytes]
                        length:[data length]
                 nvgImageFlags:0]);
}



- (BOOL) writeToPNGFileWithSystemRepresentation:(char *) filename
{
   int   rval;
  
   rval = stbi_write_png( filename, 
                          _bitmapSize.size.width, 
                          _bitmapSize.size.height, 
                          4, 
                          _image, 
                          _bitmapSize.size.width * _bitmapSize.colorComponents);
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
   int             rval;
   NSMutableData   *buffer;
   NSUInteger      lineLength;

   lineLength = _bitmapSize.size.width * _bitmapSize.colorComponents;

   buffer = [NSMutableData dataWithCapacity:1024 + _bitmapSize.size.width * lineLength];
   rval   = stbi_write_png_to_func( appendData, 
                                    buffer, 
                                    _bitmapSize.size.width, 
                                    _bitmapSize.size.height, 
                                    4, 
                                    _image, 
                                    lineLength);
   if( rval == 0)
      return( nil);

    // shrink to fit
   [buffer setLength:[buffer length]];
   return( buffer);
}

@end
