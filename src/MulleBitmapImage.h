#import "UIImage.h"

#import "CGGeometry.h"


//
// A bitmap image is not yet a texture, when loaded. So you can use it 
// without a NVG context. By default we keep the original incoming data
// so when asked for it, we do not suffer back and forth compression lossage
//
@interface MulleBitmapImage : UIImage < NSCopying>
{
   id         _imageSharingObject;
   void      *_image;
   BOOL       _dontFreeImage;
}

@property( readonly) struct mulle_bitmap_size   bitmapSize;
// NVGImageFlags are use for repetitive patterns
@property( readonly) int                        nvgImageFlags;

- (instancetype) initWithBytes:(void *) bytes 
                        length:(NSUInteger) length
                     allocator:(struct mulle_allocator *) allocator
                 nvgImageFlags:(int) flags;
                     
// const meaning readonly memory 
- (instancetype) initWithConstBitmapBytes:(const void *) bytes 
                         bitmapSize:(mulle_bitmap_size) bitmapSize
                      nvgImageFlags:(int) flags;
- (instancetype) initWithConstBitmapBytes:(const void *) bytes 
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
