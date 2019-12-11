#import "UIView+CGGeometry.h"

#import "UIWindow.h"

#import "CGGeometry+CString.h"
#import "CALayer.h"  // for _NVGtransform


@implementation UIView( CGGeometry)


//
// Transform for incoming values of the superview to translate into
// bounds space of the view. For hit tests.
//
- (void) updateTransformWithFrameAndBounds:(float *) transform
{
   CGRect          frame;
   CGRect          bounds;
   CGPoint         scale;
   _NVGtransform   tmp;

   frame  = [self frame];
   bounds = [self bounds];

   nvgTransformTranslate( tmp, -bounds.origin.x, -bounds.origin.y);
   nvgTransformPremultiply( transform, tmp);

   scale.x = bounds.size.width / frame.size.width;
   scale.y = bounds.size.height / frame.size.height;

   nvgTransformScale( tmp, scale.x, scale.y);
   nvgTransformPremultiply( transform, tmp);

   nvgTransformTranslate( tmp, -frame.origin.x, -frame.origin.y);
   nvgTransformPremultiply( transform, tmp);
}


- (CGPoint) translatedPoint:(CGPoint) point
{
   CGPoint         translated;
   _NVGtransform   transform;

   nvgTransformIdentity( transform);
   [self updateTransformWithFrameAndBounds:transform];
   nvgTransformPoint( &translated.x, &translated.y, transform, point.x, point.y);
   return( translated);
}


//
// prefer conversion from window to view, so floating point errors are
// the same as they are when we handle an event
//
- (CGPoint) convertPoint:(CGPoint) point 
                fromView:(UIView *) view
{
   UIView       *space[ 32];
   UIView       **stack;
   UIView       **curr;
   UIView       **sentinel;
   UIView       *subview;
   NSUInteger   n;
   NSUInteger   size;
   CGPoint      translated;

   size     = 32;
   stack    = space;
   curr     = stack;
   sentinel = &curr[size];

   if( view)
      abort();
  
   subview = self;
   while( subview)
   {
      if( stack >= sentinel)
         abort(); // TODO: use mulle-buffer instead
      
      *curr++ = subview;
      subview  = [subview superview];
   }

   //
   // have all subviews in stack, last is UIWindow
   //
   translated = point;
   for(;;)
   {
      if( curr == stack)
         break;

      subview   = *--curr;
      translated = [subview translatedPoint:translated];
   }
   return( translated);
}


- (CGPoint) convertPoint:(CGPoint) point
                  toView:(UIView *) toView
{
   abort();
}


//
// this code works without precomputing the affine tranform and its inverse
//
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

- (CGRect) convertRect:(CGRect) rect
              fromView:(UIView *) fromView
{
   CGRect  rect;

   if( self == fromView)
      return( rect);
   if( fromView)
      rect = [fromView convertRect:rect
                            factor:+1];
   rect = [self convertRect:rect
                     factor:-1];
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
      while( (view = mulle_pointerarrayenumerator_next( &rover)))
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
