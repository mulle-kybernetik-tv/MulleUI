#import "UIControl.h"


@implementation UIControl

@dynamic action;
@dynamic click;
@dynamic state;
@dynamic target;


- (UIEvent *) mouseUp:(UIEvent *) event
{
	UIControlClickHandler   *click;

	click = [self click];   
   if( click)
      event = (*click)( self, event);
   else
      event = [[self target] performSelector:[self action]
                                  withObject:self];
   return( event);
}

@end
