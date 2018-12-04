#include "UIView+CGGeometry.h"

#include "UIWindow.h"

//
// this code works without precomputing the affine tranform and its inverse
//
@implementation UIView( CGGeometry)

- (CGRect) convertRect:(CGRect) rect 
                factor:(CGFloat) oneOrMinusOne
{
   CGRect   bounds;
   CGRect   frame;
   UIView   *superview;

   frame  = [self frame];
   bounds = [self bounds];

   rect.origin.x += bounds.origin.x * oneOrMinusOne;
   rect.origin.y += bounds.origin.y * oneOrMinusOne;
   rect.origin.x += frame.origin.x * oneOrMinusOne;
   rect.origin.y += frame.origin.y * oneOrMinusOne;

   superview = [self superview];
   if( superview)
      return( [superview convertRect:rect
                              factor:oneOrMinusOne]);
   return( rect);
}


- (CGRect) convertRect:(CGRect) rect 
                toView:(UIView *) toView
{
   CGRect  rect;

   if( self == toView)
      return( rect);

   rect = [self convertRect:rect 
                     factor:-1];
   if( toView)
      rect = [toView convertRect:rect
                          factor:1];
   return( rect);
}

/**
                     v--- point (src)
   window <- self{ bounds: }
   window -> view1 { bounds: } -> view2 { bounds: }
                                           ^----- point( dst)
*/

@end
