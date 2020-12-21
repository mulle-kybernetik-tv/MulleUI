#import "_MulleBitmapImage.h"

@class CGContext;
@class MulleBitmapImage;

//
// An image rendered into a texture.
// it's unclear how long a texture lives ? Is it just for the duration of
// a frame ? As long as the GPU sees fit ?
//
@interface MulleTextureImage : _MulleBitmapImage

@property( readonly, assign) CGContext   *context;

- (void *) framebuffer;
//
// options is nvgImageFlags currently
//
- (instancetype) initWithBitmapSize:(struct mulle_bitmap_size) size
                            context:(CGContext *) context 
                            options:(NSUInteger) options;

- (int) textureIDWithContext:(CGContext *) context;

- (MulleBitmapImage *) bitmapImage;
            
@end
