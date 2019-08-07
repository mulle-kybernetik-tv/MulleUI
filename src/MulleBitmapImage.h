#import "UIImage.h"

#import "CGGeometry.h"


@interface MulleBitmapImage : UIImage
{
   void                      *_image;
   struct mulle_bitmap_size  _bitmapSize;
   unsigned char             _shouldFree;
}

- (instancetype) initWithBytes:(void *) bytes 
                        length:(NSUInteger) length;
                     
// const meaning readonly memory 
- (instancetype) initWithConstBytes:(const void *) bytes 
                         bitmapSize:(mulle_bitmap_size) bitmapSize;
- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) s;

- (mulle_int_size) intSize;
- (mulle_bitmap_size) bitmapSize;

- (void *) bytes;
- (NSUInteger) length;

@end
