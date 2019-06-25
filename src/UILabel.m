#import "UILabel.h"

#import "MulleTextLayer.h"
#import "CGFont.h"


@implementation UILabel : UIView

- (id) initWithFrame:(CGRect) frame
{
   MulleTextLayer  *textLayer;

   textLayer = [[[MulleTextLayer alloc] initWithFrame:frame] autorelease];
   return( [self initWithLayer:textLayer]);
}


//
// works as long as the return value is no struct or double
//
- (void *) forward:(void *) param
{
   MulleTextLayer  *layer;

   layer = (MulleTextLayer *) _mainLayer;
   return( MulleObjCPerformSelector( layer, _cmd, param));
}


- (void) setCStringName:(char *) s 
{
   // ignore
}


@end

