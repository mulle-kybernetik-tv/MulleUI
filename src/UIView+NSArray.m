#import "UIView+NSArray.h"


#import "MulleObjectArray.h"


@implementation UIView( NSArray)

- (id <NSArray>) subviews
{
   if( ! self->_subviews)
      return( nil);

   if( ! _subviewsArrayProxy)
      _subviewsArrayProxy = [[MulleObjectArray alloc] initWithPointerarray:self->_subviews
                                                              freeWhenDone:NO];
   return( _subviewsArrayProxy);
}

@end

