#import "UIView+CGGeometry.h"

#import "UIWindow.h"

#import "CGGeometry+CString.h"


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



- (void) dumpSubviewsWithIndent:(NSUInteger) indent
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                 *view;

   if( _subviews)
   {
      rover = mulle_pointerarray_enumerate( _subviews);
      while( view = mulle_pointerarrayenumerator_next( &rover))
         [view dumpWithIndent:indent];
      mulle_pointerarrayenumerator_done( &rover);
   }
}


- (void) dumpWithIndent:(NSUInteger) indent
{
   int   i;

   for( i = 0; i < indent; i++)
      fputc( ' ', stderr);

   fprintf( stderr, "%s: frame=%s bounds=%s\n",
               [self cStringDescription],
               CGRectCStringDescription( [self frame]),
               CGRectCStringDescription( [self bounds]));
   [self dumpSubviewsWithIndent:indent + 3];
}


- (void) dump
{
   [self dumpWithIndent:0];
}


@end
