#import "UIView.h"
#import "YGLayout.h"
#import "YogaProtocol.h"


@implementation UIView( Yoga)

- (YGLayout *) yoga
{
   if( ! _yoga)
      _yoga = [[YGLayout alloc] initWithView:self];   
   return( _yoga);
}


@end
