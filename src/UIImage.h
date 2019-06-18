#import "import.h"

#import "CGGeometry.h"


@interface UIImage : NSObject 

// this is added as a category by the layer to the specific UIImage subclass
- (Class) preferredLayerClass;

@end


@interface UIImage( UIImageSubclass)

- (CGSize) size;
- (CGRect) visibleBounds;

@end
