#import "_MulleBitmapImage.h"

@class CGContext;
@class MulleBitmapImage;

//
// An image rendered into a texture.
// The texture lives as long as the CGContext is active. But! If the context
// vanishes, the texture is invalid. So that means that when the context
// finalizes it also needs to finalize the texture. There is no reason, why
// a texture image can't be retained. So the lifetime of a MulleTextureImage
// shouldn't exceed that of the CGContext, but that can't be guaranteed.
// The CGContext keeps track of all texture images, but doesn't retain them.
// When the time comes, it calls -finalize on all texture images.
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
