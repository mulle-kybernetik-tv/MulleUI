#import "import.h"

#import "CGGeometry.h"

@class CGContext;


@interface UIImage : NSObject 

// this is added as a category by the layer to the specific UIImage subclass
- (Class) preferredLayerClass;

- (int) textureIDWithContext:(CGContext *) context;

//
// Textures (images) in NVG can be created with different flags, for example 
// REPEAT_X andREPEAT_Y. When we are asking the CGContext for a textureID 
// for an image this will create such a NVG texture. As the context cashes the
// textureID for each UIImage it's simplest to store the nvgImageFlags here
// (readonly) and to clone UIImages for different flags. The actual image
// data can be shared w/o a problem. The default is 0:
// 
- (int) nvgImageFlags;

//
// Derive an image, that supports the given NVGflags. If the value can not be
// supported by the UIImage subclass, this will return nil.
// May return self!
//
- (UIImage *) imageWithNVGImageFlags:(int) flags;

@end


@interface UIImage( UIImageSubclass)

- (CGSize) size;
- (CGRect) visibleBounds;

@end
