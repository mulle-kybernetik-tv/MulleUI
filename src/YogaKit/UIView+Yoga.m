#import "UIView.h"
#import "YGLayout.h"
#import "YogaProtocol.h"


@implementation UIView( Yoga)

MULLE_OBJC_DEPENDS_ON_CATEGORY( UIView, Layout);

- (YGLayout *) yoga
{
   if( ! _yoga)
      _yoga = [[YGLayout alloc] initWithView:self];   
   return( _yoga);
}


- (void) setNeedsLayout
{
   [_yoga markDirty];
   [self _setNeedsLayout];
}


- (enum UILayoutStrategy) layoutStrategy
{
   if( ! _yoga)
      return( UILayoutStrategyDefault);

   [_yoga applyLayoutPreservingOrigin:NO];
   return( UILayoutStrategyStop);
}


@end
