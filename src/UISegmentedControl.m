#import "UISegmentedControl.h"

#import "MulleSegmentedControlLayer.h"
#import "UIEvent.h"


@implementation UISegmentedControl : UIView

- (id) initWithFrame:(CGRect) frame
{
   MulleSegmentedControlLayer  *segmentedControlLayer;

   segmentedControlLayer = [[[MulleSegmentedControlLayer alloc] initWithFrame:frame] autorelease];
   return( [self initWithLayer:segmentedControlLayer]);
}


//
// works as long as the return value is no struct or double
//
- (void *) forward:(void *) param
{
   MulleSegmentedControlLayer  *layer;

   layer = (MulleSegmentedControlLayer *) _mainLayer;
   return( MulleObjCPerformSelector( layer, _cmd, param));
}


- (UIEvent *) consumeMouseDown:(UIEvent *) event
{
   if( [self isContinuous])
   {
      event = [self performClickAndTargetActionCallbacks:event];
      return( event);
   }
   return( nil);
}

@end
