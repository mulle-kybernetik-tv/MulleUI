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
