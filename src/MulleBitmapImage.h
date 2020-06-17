#import "UIImage.h"

#import "CGGeometry.h"


//
// A bitmap image is not yet a texture, when loaded. So you can use it 
// without a NVG context
//
@interface MulleBitmapImage : UIImage
{
   MulleBitmapImage   *_parent;
   void               *_image;
   unsigned char      _shouldFree;
}

@property( readonly) struct mulle_bitmap_size   bitmapSize;
@property( readonly) int                        nvgImageFlags;


- (instancetype) initWithBytes:(void *) bytes 
                        length:(NSUInteger) length
                      nvgImageFlags:(int) flags;
                     
// const meaning readonly memory 
- (instancetype) initWithConstBytes:(const void *) bytes 
                         bitmapSize:(mulle_bitmap_size) bitmapSize
                      nvgImageFlags:(int) flags;
- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) s
                      nvgImageFlags:(int) flags;

// const meaning readonly memory 
- (instancetype) initWithBytes:(void *) bytes 
                        length:(NSUInteger) length;
- (instancetype) initWithConstBytes:(const void *) bytes 
                         bitmapSize:(mulle_bitmap_size) bitmapSize;
- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) s;

- (BOOL) writeToBMPFileWithSystemRepresentation:(char *) filename;


- (mulle_int_size) intSize;

- (void *) bytes;
- (NSUInteger) length;

// derive and image with different flags for NVG
- (UIImage *) imageWithNVGImageFlags:(int) flags;

@end
