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


// Memo:
// prefer conversion from window to view, so floating point errors are
// the same as they are when we handle an event
//


#if 0
- (CGRect) convertRect:(CGRect) rect
              fromView:(UIView *) fromView
{
   CGRect                                        converted;
   UIView                                        *view;
   CGRect                                        frame;
   UIView                                        *views[ 32];
   struct mulle_pointerarray                     array;
   struct mulle__pointerarrayreverseenumerator   rover;

   _mulle__pointerarray_init_with_static_pointers( array, views, sizeof( views) / sizeof( UIView *));

   converted = rect;
   for( view = fromView; view; view = [view superview])
   {
      if( self == fromView)
         return( converted);

      frame               = [view frame];
      converted.origin.x -= frame.origin.x;
      converted.origin.y -= frame.origin.y;
      converted           = [self convertBoundsRectToFrameRect:converted];
   }

   /*
    *
    */
   for( view = self; view; view = [view superview])
      _mulle__pointerarray_add( views, view, NULL);

   rover = _mulle__pointerarray_reverseenumerator( views);
   while( _mulle__pointerarrayreverseenumerator_next( &rover, (void **) &view))
   {
      converted           = [self convertFrameRectToBoundsRect:converted];
      frame               = [view frame];
      converted.origin.x += frame.origin.x;
      converted.origin.y += frame.origin.y;
   }
   _mulle__pointerarrayreverseenumerator_done( &rover);

   _mulle__pointerarray_done( &views, NULL);

   return( converted);
}
#endif

/**
                     v--- point (src)
   window <- self{ bounds: }
   window -> view1 { bounds: } -> view2 { bounds: }
                                           ^----- point( dst)
*/



/*
 * These routines have been checked vs UIView (sic!) and they are compatible.
 * Replace: NSView -> UIView
 *          NSRect -> CGRect
 *          NSPoint -> CGPoint
 *          NSEqualSizes -> CGSizeEqualToSize
 */

// +--------------------[a frame]---------------------+
// | [a bounds]                                       |
// |          +----+.....[b frame].........+....+     |
// |          |    :     +----------+      |    :     |
// |          |    :     |   rect   |      |    :     |
// |          |    :     +----------+      |    :     |
// |          +--[b bounds}::::::::::::::::+....+     |
// |                                                  |
// +--------------------------------------------------+


//
// frame  = 0.0,0.0,1.0,1.0
// bounds = 0.0,0.0,0.5,0.5
// rect   = 0.5,0.5,0.5,0.5
//
// so rect is in the lower right quarter of bounds
// bounds has half the resolution of frame
//    +-------------frame--------------+
//    |  bounds                        |
//    |                                |
//    |               0.5              |
//    |           0.5 +................+
//    |               :                |
//    |               :      rect      |
//    |               :                |
//    +---------------+----------------+
//
static CGRect   convertFrameRectToBoundsRect( UIView *self, CGRect rect, CGRect frame)
{
   CGRect   bounds;
   CGPoint  scale;

   bounds = [self bounds];

   if( ! CGSizeEqualToSize( frame.size, bounds.size))
   {
      if( frame.size.width == 0.0)
         scale.x = INFINITY;
      else
         scale.x = bounds.size.width / frame.size.width;

      if( frame.size.height == 0.0)
         scale.y = INFINITY;
      else
         scale.y = bounds.size.height / frame.size.height;

      rect.origin.x    *= scale.x;
      rect.origin.y    *= scale.y;
      rect.size.width  *= scale.x;
      rect.size.height *= scale.y;
   }

   rect.origin.x += bounds.origin.x;
   rect.origin.y += bounds.origin.y;

   return( rect);
}


//
// frame  = 0.0,0.0,1.0,1.0
// bounds = 0.0,0.0,0.5,0.5
// rect   = 0.25,0.25,0.25,0.25
//
// so rect is in the lower right quarter of bounds
// bounds has half the resolution of frame
//    +-------------frame--------------+
//    |  bounds                        |
//    |                                |
//    |               0.25             |
//    |          0.25 +................+
//    |               :                |
//    |               :      rect      |
//    |               :                |
//    +---------------+----------------+
//
static CGRect   convertBoundsRectToFrameRect( UIView *self, CGRect rect, CGRect frame)
{
   CGRect   bounds;
   CGPoint  scale;

   bounds = [self bounds];

   rect.origin.x -= bounds.origin.x;
   rect.origin.y -= bounds.origin.y;

   if( ! CGSizeEqualToSize( frame.size, bounds.size))
   {
      if( bounds.size.width == 0.0)
         scale.x = 0;
      else
         scale.x = frame.size.width / bounds.size.width;

      if( bounds.size.height == 0.0)
         scale.y = 0;
      else
         scale.y = frame.size.height / bounds.size.height;

      rect.origin.x    *= scale.x;
      rect.origin.y    *= scale.y;
      rect.size.width  *= scale.x;
      rect.size.height *= scale.y;
   }

   return( rect);
}


//
// A-----B-----C
//  \
//   ----D
//
//  self  | toView  | down | up
// -------|---------|------|--------------
//   A    |    A    |   -  |  -
//   A    |    B    |   -  |  B
//   A    |    C    |   -  |  BC
//   A    |    D    |   -  |  D
//   B    |    A    |   A  |  -
//   B    |    C    |   A  |  BC
//   B    |    D    |   A  |  D
//   C    |    A    |  BA  |  -
//   C    |    B    |   B  |  -
//   C    |    D    |  BA  |  D
//   D    |    A    |   A  |  -
//   D    |    B    |   A  |  B
//   D    |    C    |   A  |  BC

// if self == B and toView == C, we will hit B, when going down from C
// and stop there. Then convert upwards only.
// if self == C and toView == B, we wont hit C, when going down from B
// so we stop at A. Then move upwards again to B and then C
// if self == B and toView == C, we will hit B, when going down from C

- (CGRect) convertRect:(CGRect) rect
                toView:(UIView *) toView
{
   CGRect                                        converted;
   CGRect                                        frame;
   struct mulle__pointerarrayreverseenumerator   rover;
   struct mulle__pointerarray                    array;
   UIView                                        *view;
   UIView                                        *views[ 32];

   converted = rect;

   _mulle__pointerarray_init_with_static_pointers( &array,
                                                   (void **) views,
                                                   sizeof( views) / sizeof( UIView *));

   for( view = toView; view; view = [view superview])
   {
      if( view == self)
         goto up;

      _mulle__pointerarray_add( &array, view, NULL);
   }

   for( view = self; view; view = [view superview])
   {
      if( view == toView)
         goto done;

      frame               = [view frame];
      converted           = convertBoundsRectToFrameRect( view, converted, frame);
      converted.origin.x += frame.origin.x;
      converted.origin.y += frame.origin.y;
      // convert direction to screen coordinates
   }

up:
   // either start at screen coordinates or at self
   rover = _mulle__pointerarray_reverseenumerate( &array);
   while( _mulle__pointerarrayreverseenumerator_next( &rover, (void **) &view))
   {
      frame               = [view frame];
      converted.origin.x -= frame.origin.x;
      converted.origin.y -= frame.origin.y;
      converted           = convertFrameRectToBoundsRect( view, converted, frame);
   }
   _mulle__pointerarrayreverseenumerator_done( &rover);

done:
   _mulle__pointerarray_done( &array, NULL);

   return( converted);
}


- (CGRect) convertRect:(CGRect) rect
              fromView:(UIView *) fromView
{
   CGRect                                        converted;
   CGRect                                        frame;
   struct mulle__pointerarrayreverseenumerator   rover;
   struct mulle__pointerarray                    array;
   UIView                                        *view;
   UIView                                        *views[ 32];

   converted = rect;

   _mulle__pointerarray_init_with_static_pointers( &array,
                                                   (void **) views,
                                                   sizeof( views) / sizeof( UIView *));
   for( view = self; view; view = [view superview])
   {
      if( view == fromView)
         goto up;
      _mulle__pointerarray_add( &array, view, NULL);
   }

   for( view = fromView; view; view = [view superview])
   {
      if( view == self)
         goto done;

      frame               = [view frame];
      converted           = convertBoundsRectToFrameRect( view, converted, frame);
      converted.origin.x += frame.origin.x;
      converted.origin.y += frame.origin.y;
      // convert direction to screen coordinates
   }

up:
   // either start at screen coordinates or at self
   rover = _mulle__pointerarray_reverseenumerate( &array);
   while( _mulle__pointerarrayreverseenumerator_next( &rover, (void **) &view))
   {
      frame               = [view frame];
      converted.origin.x -= frame.origin.x;
      converted.origin.y -= frame.origin.y;
      converted           = convertFrameRectToBoundsRect( view, converted, frame);

   }
   _mulle__pointerarrayreverseenumerator_done( &rover);

done:
   _mulle__pointerarray_done( &array, NULL);

   return( converted);
}


#if 0
static CGPoint   convertFramePointToBoundsPoint( UIView *self, CGPoint point, CGRect frame)
{
   CGRect   bounds;
   CGPoint  scale;

   bounds = [self bounds];

   if( ! CGSizeEqualToSize( frame.size, bounds.size))
   {
      if( frame.size.width == 0.0)
         scale.x = INFINITY;
      else
         scale.x = bounds.size.width / frame.size.width;

      if( frame.size.height == 0.0)
         scale.y = INFINITY;
      else
         scale.y = bounds.size.height / frame.size.height;

      point.x *= scale.x;
      point.y *= scale.y;
   }

   point.x += bounds.origin.x;
   point.y += bounds.origin.y;

   return( point);
}


static CGPoint   convertBoundsPointToFramePoint( UIView *self, CGPoint point, CGRect frame)
{
   CGRect   bounds;
   CGPoint  scale;

   bounds   = [self bounds];

   point.x -= bounds.origin.x;
   point.y -= bounds.origin.y;

   if( ! CGSizeEqualToSize( frame.size, bounds.size))
   {
      if( bounds.size.width == 0.0)
         scale.x = 0;
      else
         scale.x = frame.size.width / bounds.size.width;

      if( bounds.size.height == 0.0)
         scale.y = 0;
      else
         scale.y = frame.size.height / bounds.size.height;

      point.x *= scale.x;
      point.y *= scale.y;
   }

   return( point);
}
#endif

// Reusing the rect code instead of a dedicated point routine,
// we "lose" two fp multiplications per conversion step
// for size/width, if bounds.size and frame.size differ, which
// they rarely do. It saves a lot of code
//
- (CGPoint) convertPoint:(CGPoint) point
                  toView:(UIView *) toView
{
   CGRect      rect;
   CGRect      converted;

   rect.origin      = point;
   rect.size.width  = 0.0;
   rect.size.height = 0.0;

   converted = [self convertRect:rect
                          toView:toView];
   return( converted.origin);
}


- (CGPoint) convertPoint:(CGPoint) point
                fromView:(UIView *) toView
{
   CGRect   rect;
   CGRect   converted;

   rect.origin      = point;
   rect.size.width  = 0.0;
   rect.size.height = 0.0;

   converted = [self convertRect:rect
                        fromView:toView];
   return( converted.origin);
}


- (void) dumpSubviewsWithIndent:(NSUInteger) indent
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                 *view;

   if( _subviews)
   {
      rover = mulle_pointerarray_enumerate( _subviews);
      while( _mulle_pointerarrayenumerator_next( &rover, (void **) &view))
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
//   if( _yoga)
//   {
//      fprintf( stderr, "%s\n", [[_yoga debugDescription] cStringDescription]);
//   }
   [self dumpSubviewsWithIndent:indent + 3];
}


- (void) dump
{
   [self dumpWithIndent:0];
}

@end
