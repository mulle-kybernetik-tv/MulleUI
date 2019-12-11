#import "UIStepper.h"

#import "MulleStepperLayer.h"
#import "UIEvent.h"


@implementation UIStepper : UIView

- (id) initWithFrame:(CGRect) frame
{
   MulleStepperLayer  *stepperLayer;

   stepperLayer = [[[MulleStepperLayer alloc] initWithFrame:frame] autorelease];
   if( self)
      self->_maximumValue = 1.0;
   return( [self initWithLayer:stepperLayer]);
}


- (void) setValue:(float) value
{
   if( value > _maximumValue)
      value = _maximumValue;
   if( value < _minimumValue)
      value = _minimumValue;
 
   _value = value; // use property setter to get future goodness ??
}


- (void) setMinimumValue:(float) value
{
   _minimumValue = value; // use property setter to get future goodness ??

   if( value > _maximumValue)
      _maximumValue = value;
   if( value > _value)
      _value = value;
}


- (void) setMaximumValue:(float) value
{
   _maximumValue = value; // use property setter to get future goodness ??

   if( value < _minimumValue)
      _minimumValue = value;
   if( value < _value)
      _value = value;
}

- (void) setValueFromEvent:(UIEvent *) event
{
   [self setValue:0.0];
 // TODO!!
 }


- (UIEvent *) consumeMouseDown:(UIEvent *) event
{
   [self setValueFromEvent:event];
   if( [self isContinuous])
   {
      event = [self performClickAndTargetActionCallbacks:event];
      return( event);
   }
   return( nil);
}

@end
