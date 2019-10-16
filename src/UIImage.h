#import "import.h"

#import "CGGeometry.h"

@class CGContext;


@interface UIImage : NSObject 

// this is added as a category by the layer to the specific UIImage subclass
- (Class) preferredLayerClass;

- (int) textureIDWithContext:(CGContext *) context;

@end


@interface UIImage( UIImageSubclass)

- (CGSize) size;
- (CGRect) visibleBounds;

@end
