#import "UISlider.h"

#import "MulleSliderLayer.h"
#import "UIEvent.h"


@implementation UISlider : UIView

- (id) initWithFrame:(CGRect) frame
{
   MulleSliderLayer  *sliderLayer;

   sliderLayer = [[[MulleSliderLayer alloc] initWithFrame:frame] autorelease];
   return( [self initWithLayer:sliderLayer]);
}


//
// works as long as the return value is no struct or double
//
- (void *) forward:(void *) param
{
   MulleSliderLayer  *layer;

   layer = (MulleSliderLayer *) _mainLayer;
   return( MulleObjCPerformSelector( layer, _cmd, param));
}

- (void) setValueFromEvent:(UIEvent *) event
{
   CGPoint  point;
   float    value;

	point = [event mousePositionInView:self];
   // fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, CGPointCStringDescription( point));

   value = point.x / [self bounds].size.width;
   [(MulleSliderLayer *) self setValue:value];
}


- (UIEvent *) consumeMouseEvent:(UIEvent *) event
{
   
   [self setValueFromEvent:event];
   if( [self isContinuous])
   {
      event = [self performClickAndTargetActionCallbacks:event];
      return( event);
   }
   return( nil);
}


- (UIEvent *) consumeMouseDown:(UIEvent *) event
{
   return( [self consumeMouseEvent:event]);
}


- (UIEvent *) consumeMouseDragged:(UIEvent *) event
{
   return( [self consumeMouseEvent:event]);
}


@end
