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


- (void) setValueFromEvent:(UIEvent *) event
{
   CGPoint  point;
   float    value;
   CGRect   rect;

	point = [event mouseLocationInView:self];
   // fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, CGPointCStringDescription( point));

   rect = [(MulleSliderLayer *) _mainLayer controlRectWithFrame:[self bounds]];
   if( rect.size.width >= rect.size.height)
   {
      if( point.x >= rect.origin.x)
         point.x -= rect.origin.x;
      else 
         point.x = 0;
      if( point.x >= CGRectGetMaxX( rect))
         point.x = CGRectGetMaxX( rect);
      value = point.x / rect.size.width;
   }
   else
   {
      if( point.y >= rect.origin.y)
         point.y -= rect.origin.y;
      else 
         point.y = 0;
      if( point.y >= CGRectGetMaxY( rect))
         point.y = CGRectGetMaxY( rect);
      value = point.y / rect.size.height;
   }
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
