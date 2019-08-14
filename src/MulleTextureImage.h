#import "UIImage.h"

@class CGContext;

//
// An image rendered into a texture.
// it's unclear how long a texture lives ? Is it just for the duration of
// a frame ? As long as the GPU sees fit ?
//
@interface MulleTextureImage : UIImage

@property( readonly, assign) CGContext   *context;
@property( readonly, assign) void        *framebuffer;
@property( readonly, assign) CGSize      size;

- (instancetype) initWithSize:(CGSize) size
                      options:(NSUInteger) options
                      context:(CGContext *) context; 

- (int) textureIDWithContext:(CGContext *) context;
                      
@end
