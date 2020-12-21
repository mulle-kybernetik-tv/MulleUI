#import "_MulleBitmapImage.h"

#import "CGGeometry.h"




//
// A bitmap image is not yet a texture, when loaded. So you can use it 
// without a NVG context. By default we keep the original incoming data
// so when asked for it, we do not suffer back and forth compression lossage
// Everything is RGBA currently
@interface MulleBitmapImage : _MulleBitmapImage < NSCopying>
{
   id         _imageSharingObject;
   BOOL       _dontFreeImage;
}

// methods with RGBA are unwrapped, uncompressed binary RGBA data
- (instancetype) initWithFileMulleData:(struct mulle_data) data 
                             allocator:(struct mulle_allocator *) allocator
                         nvgImageFlags:(int) flags;

// Other methods expect PNG or JPG data
                // const meaning readonly memory 
- (instancetype) initWithConstRGBA:(const void *) bytes 
                        bitmapSize:(mulle_bitmap_size) bitmapSize
                     nvgImageFlags:(int) flags;
- (instancetype) initWithConstRGBA:(const void *) bytes 
                        bitmapSize:(mulle_bitmap_size) bitmapSize;

- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) s
                                                      nvgImageFlags:(int) flags;

- (BOOL) writeToBMPFileWithSystemRepresentation:(char *) filename;


- (mulle_int_size) intSize;


// derive and image with different flags for NVG,
- (UIImage *) imageWithNVGImageFlags:(int) flags;

- (void *) bytes;

@end

enum UIImageDataEncoding   MulleBitmapImageDataEncodingFromMulleData(struct mulle_data data);
