#import <MulleObjC/MulleObjC.h>

#import "CGGeometry.h"


typedef struct mulle_int_size
{
   int   width;
   int   height;
} mulle_int_size;

typedef struct mulle_bitmap_size
{
   struct mulle_int_size   size;
   unsigned char           colorComponents;
} mulle_bitmap_size;


@interface MulleBitmapImage : NSObject
{
   void                      *_image;
   struct mulle_bitmap_size  _bitmapSize;
}

- (instancetype) initWithBytes:(void *) bytes 
                        length:(NSUInteger) length;
- (instancetype) initWithBytes:(void *) bytes 
                    bitmapSize:(mulle_bitmap_size) bitmapSize;
- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) s;

- (CGSize) size;
- (mulle_int_size) intSize;
- (mulle_bitmap_size) bitmapSize;
- (CGRect) visibleBounds;
- (void *) bytes;
- (NSUInteger) length;

@end
