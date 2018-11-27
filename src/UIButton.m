#import "UIButton.h"


@implementation UIButton

- (UIEvent *) mouseUp:(UIEvent *) event
{
   if( self->_click)
      event = (*self->_click)( self, event);
   else
      event = [self->_target performSelector:self->_action
                                  withObject:self];
   return( event);
}

@end