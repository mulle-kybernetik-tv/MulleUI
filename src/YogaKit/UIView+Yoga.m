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


- (void) setNeedsLayout
{
   [_yoga markDirty];
   [self setNeedsLayout:YES];
}


- (void) layoutSubviews
{
   if( ! _yoga)
   {
      // [super layoutSubviews];
      return;
   }

   [_yoga applyLayoutPreservingOrigin:NO];
}


- (void) setAutoresizingMask:(NSUInteger) mask
{
   // TODO:   
}

@end
