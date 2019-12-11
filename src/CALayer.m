#import "import-private.h"

#import "CALayer.h"

#import "CGGeometry.h"
#import "CGGeometry+CString.h"
#import "CGContext.h"
#import "nanovg+CString.h"
#import "UIView+CAAnimation.h"

#pragma clang diagnostic ignored "-Wparentheses"
// #define RENDER_DEBUG
// #define CALAYER_DEBUG

@implementation CALayer

- (id) init
{
   self = [super init];
   if( ! self)
      return( self);

   _bounds.origin.x = INFINITY;
   _opacity         = 1.0;
   return( self);
}


- (instancetype) initWithFrame:(CGRect) frame
{
   self = [self init];
   if( self)
      _frame = frame;
   return( self);
}


- (void) dealloc
{
   struct mulle_allocator               *allocator;
   struct mulle_pointerarrayenumerator   rover;
   CAAnimation                           *animation;

   allocator = MulleObjCObjectGetAllocator( self);
   mulle_allocator_free( allocator, _cStringName);

   rover = mulle_pointerarray_enumerate_nil( &_animations);
   while( animation = mulle_pointerarrayenumerator_next( &rover))
      [animation release];
   mulle_pointerarrayenumerator_done( &rover); 

   mulle_pointerarray_done( &_animations);

   [_snapshot release];
   
   [super dealloc];
}


- (void) setTransform:(_NVGtransform) transform
              scissor:(NVGscissor *) scissor
{
   memcpy( _transform, transform, sizeof( _NVGtransform));
   memcpy( &_scissor, scissor, sizeof( NVGscissor));
}


- (void) drawContentsInContext:(CGContext *) context
{
   if( _drawContentsCallback)
      (*_drawContentsCallback)( [context nvgContext], [self frame], [context currentFrameInfo]);
}


- (BOOL) drawInContext:(CGContext *) context
{
   CGPoint      scale;
   CGRect       frame;
   CGRect       bounds;
   CGFloat      halfBorderWidth;
   CGFloat      halfBorderHeight;
   CGFloat      obscured;
   CGFloat      borderHeight;
   CGPoint      tl;
   CGPoint      br;
   CGSize       sz;
   int          radius;
   NVGcontext   *vg;
   struct NVGpaint   paint; // todo convert to CG ??

#ifdef RENDER_DEBUG
   fprintf( stderr, "%s %s (f:%s b:%s)\n", 
                        __PRETTY_FUNCTION__, 
                        [self cStringDescription],
                        CGRectCStringDescription( [self frame]),
                        CGRectCStringDescription( [self bounds]));
#endif

   frame  = [self frame];
   if( frame.size.width == 0.0 || frame.size.height == 0.0)
      return( NO);

   vg = [context nvgContext];

   //
   // these are the "inherited" transforms
   //
   nvgResetTransform( vg);
   nvgTransform( vg, _transform[ 0], _transform[ 1], _transform[ 2],
                     _transform[ 3], _transform[ 4], _transform[ 5]);
#ifdef CALAYER_DEBUG   
   fprintf( stderr, "%s: set to local transform %s\n", 
                     [self cStringDescription],
                     _NVGtransformCStringDescription( _transform));                     
#endif   
   nvgSetScissor( vg, &_scissor);

#ifdef CALAYER_DEBUG   
   fprintf( stderr, "%s: set to local scissor %s\n", 
                     [self cStringDescription],
                     NVGscissorCStringDescription( &_scissor));                     

   fprintf( stderr, "%s: transform %s\n", 
                     [self cStringDescription],
                     _NVGtransformCStringDescription( _transform));
   fprintf( stderr, "%s: scissor %s\n", 
                     [self cStringDescription],
                     NVGscissorCStringDescription( &_scissor));
#endif

   //
   // fill and border are drawn as frame
   // contents in bounds of superview
   //

   //
   // if the stroke is alpha, it will have to render over pixels
   // otherwise reduce the size of the shape we draw
   //
   tl.x = frame.origin.x;
   tl.y = frame.origin.y;
   br.x = tl.x + frame.size.width;
   br.y = tl.y + frame.size.height;

   if( tl.x <= br.x || tl.y <= br.y)
   {
      // fill 
      nvgBeginPath( vg);
      nvgRoundedRect( vg, frame.origin.x, 
                          frame.origin.y, 
                          frame.size.width, 
                          frame.size.height, 
                          _cornerRadius);

   //   nvgMoveTo( vg, tl.x, tl.y);
   //   nvgLineTo( vg, br.x, tl.y);
   //   nvgLineTo( vg, br.x, br.y);
   //   nvgLineTo( vg, tl.x, br.y);
   //   nvgLineTo( vg, tl.x, tl.y);
      nvgFillColor(vg, _backgroundColor);
      nvgFill( vg);
   }

   [self drawContentsInContext:context];

   //
   // the strokeWidth isn't scaled in nvg, so we do this now ourselves
   //
   if( _borderWidth)
   {
      halfBorderWidth = _borderWidth / 2.0;

      tl.x = halfBorderWidth + frame.origin.x ;
      tl.y = halfBorderWidth + frame.origin.y;
      br.x = tl.x + frame.size.width - halfBorderWidth * 2;
      br.y = tl.y + frame.size.height - halfBorderWidth * 2;

      if( tl.x <= br.x || tl.y <= br.y)
      {
         //
         // the _cornerRadius is computed for a stroke of width 1 (or 0 ?)
         // the strokeWidth is just scaling it out
         //
         nvgBeginPath( vg);
         nvgStrokeWidth( vg, (int) _borderWidth);
         nvgRoundedRect( vg, tl.x, 
                             tl.y, 
                             br.x - tl.x, 
                             br.y - tl.y, 
                             _cornerRadius / _borderWidth);

         nvgStrokeColor( vg, _borderColor);
         nvgStroke( vg);

//      nvgMoveTo( vg, tl.x, tl.y);
//      nvgLineTo( vg, br.x, tl.y);
//      nvgLineTo( vg, br.x, br.y);
//      nvgLineTo( vg, tl.x, br.y);
//      nvgLineTo( vg, tl.x, tl.y);
      }
   }

   bounds = [self bounds];
   if( bounds.size.width <= 0.0 || bounds.size.height <= 0.0)
      return( NO);

#ifdef CALAYER_DEBUG   
   fprintf( stderr, "%s: frame %s\n", 
            [self cStringDescription],
            CGRectCStringDescription( frame));
   fprintf( stderr, "%s: bounds %s\n", 
            [self cStringDescription],
            CGRectCStringDescription( bounds));
#endif

   nvgTranslate( vg, frame.origin.x, frame.origin.y);
#if 1
   nvgIntersectScissor( vg, 0.0, 
                            0.0, 
                            frame.size.width, 
                            frame.size.height);
#endif

   //
   // now translate bounds for context
   //
   scale.x = frame.size.width / bounds.size.width;
   scale.y = frame.size.height / bounds.size.height;

   nvgScale( vg, scale.x, scale.y);
   nvgTranslate( vg, bounds.origin.x, bounds.origin.y);

   {
      CGPoint         point;
      _NVGtransform   transform;
      NVGscissor      scissor;

      nvgCurrentTransform( vg, transform);
#ifdef CALAYER_DEBUG   
      fprintf( stderr, "%s: modified transform %s\n", 
                        [self cStringDescription],
                        _NVGtransformCStringDescription( transform));
#endif
      nvgTransformPoint( &point.x, &point.y, transform, 0.0, 0.0);
#ifdef CALAYER_DEBUG   
      fprintf( stderr, "%s: transform 0.0/0.0 -> %s\n",
               [self cStringDescription],
               CGPointCStringDescription( point));
#endif
      nvgGetScissor( vg, &scissor);
#ifdef CALAYER_DEBUG   
      fprintf( stderr, "%s: modified scissor %s\n", 
                        [self cStringDescription],
                        NVGscissorCStringDescription( &scissor));
#endif
      nvgTransformPoint( &point.x, &point.y, transform, 0.0, 0.0);
#ifdef CALAYER_DEBUG   
      fprintf( stderr, "%s: scissor transform 0.0/0.0 -> %s\n",
               [self cStringDescription],
               CGPointCStringDescription( point));
#endif
   }

   return( YES);
}



// possibly rename to layerWillChange
- (void) willChange
{
   if( ! [UIView areAnimationsEnabled])
      return;
   if( _snapshot)
      return;
  
   [UIView addAnimatedLayer:self];
   _snapshot = [self copy];
}


- (id) copy
{
   CALayer   *copy;

   // this does a memcpy
   copy = NSCopyObject( self, 0, NULL);

   // nil out references to outside memory
   copy->_snapshot    = nil;
   mulle_pointerarray_init( &copy->_animations, 0, 0, NULL);
   copy->_cStringName = NULL;
   return( copy);
}


- (CGRect) bounds
{
   CGRect  bounds;

   // not tied to frame anymore ? 
   if( _bounds.origin.x != INFINITY)
      return( _bounds);

   bounds.origin = CGPointMake( 0.0f, 0.0f);
   bounds.size   = _frame.size;
   return( bounds);
}


- (void) setCStringName:(char *) s
{
   struct mulle_allocator  *allocator;

   allocator = MulleObjCObjectGetAllocator( self);
   if( s)
      s = mulle_allocator_strdup( allocator, s);
   
   mulle_allocator_free( allocator, _cStringName);
   _cStringName = s;
}


- (char *) cStringDescription
{
   char        *result;
   char        *s;
   auto char   buf[ 64];
   size_t      len;
   char        *format;

   s = class_getName( object_getClass( self));  
   sprintf( buf, "%p",  self);

   format = "<%s %s>";
   len    = _cStringName ? strlen( _cStringName) : 0;
   if( len)
   {
      format = "<%s %s \"%s\">";
      len   += 3; // < "">\0"
   }
   len    += strlen( s) + strlen( buf) + 4; // < "">\0"
   result  = mulle_malloc( len);
   sprintf( result, format, s, buf, _cStringName);
   MulleObjCAutoreleaseAllocation( result, NULL);

   return( result);
}


# pragma mark - Animation


- (void) addAnimation:(CAAnimation *) animation
{
   assert( animation);

   assert( mulle_pointerarray_find( &_animations, animation) == -1);
   mulle_pointerarray_add( &_animations, animation);
}


- (void) removeAllAnimations
{
   struct mulle_pointerarrayenumerator   rover;
   CAAnimation                           *animation;

   rover = mulle_pointerarray_enumerate_nil( &_animations);
   while( animation = mulle_pointerarrayenumerator_next( &rover))
      [animation autorelease];
   mulle_pointerarrayenumerator_done( &rover); 

   mulle_pointerarray_done( &_animations);
   mulle_pointerarray_init( &_animations, 16, 0, NULL);
}


- (NSUInteger) numberOfAnimations
{
   return( mulle_pointerarray_get_count( &_animations));
}


- (void) animateWithAbsoluteTime:(CAAbsoluteTime) renderTime
{
   struct mulle_pointerarrayenumerator   rover;
   CAAnimation                           *animation;

#ifdef RENDER_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   rover = mulle_pointerarray_enumerate_nil( &_animations);
   while( animation = mulle_pointerarrayenumerator_next( &rover))
      [animation animateLayer:self
                 absoluteTime:renderTime];
   mulle_pointerarrayenumerator_done( &rover);   
}



- (void) animatePropertiesWithSnapshotlayer:(CALayer *) snapshot
                          animationDelegate:(MulleAnimationDelegate *) animationDelegate
                           animationOptions:(struct CAAnimationOptions *) options
{
   CGColorRef    startColor;
   CGColorRef    endColor;
   CGRect        startRect;
   CGRect        endRect;
   CAAnimation   *animation;
   CGFloat       startValue;
   CGFloat       endValue;

   /*
    * Border
    */
   startColor = snapshot->_borderColor;
   endColor   = _borderColor;
   if( ! CGColorEqualToColor( startColor,  endColor))
   {
      animation = [[[CAAnimation alloc] initWithPropertySetter:@selector( setBorderColor:) 
                                                    startColor:startColor
                                                      endColor:endColor
                                                       options:options] autorelease];
      [animation setAnimationDelegate:animationDelegate];
      [self addAnimation:animation];

      // reset to start position 
      _borderColor = snapshot->_borderColor;
   }

   /*
    * BackgroundColor
    */
   startColor = snapshot->_backgroundColor;
   endColor   = _backgroundColor;
   if( ! CGColorEqualToColor( startColor,  endColor))
   {
      animation = [[[CAAnimation alloc] initWithPropertySetter:@selector( setBackgroundColor:) 
                                                    startColor:startColor
                                                      endColor:endColor
                                                       options:options] autorelease];
      [animation setAnimationDelegate:animationDelegate];
      [self addAnimation:animation];

      // reset to start position 
      _backgroundColor = snapshot->_backgroundColor;
   }

   /*
    * BorderWidth
    */
   startValue = snapshot->_borderWidth;
   endValue   = _borderWidth;
   if( startValue != endValue)
   {
      animation = [[[CAAnimation alloc] initWithPropertySetter:@selector( setBorderWidth:) 
                                               startFloatValue:startValue
                                                 endFloatValue:endValue
                                                       options:options] autorelease];
      [animation setAnimationDelegate:animationDelegate];
      [self addAnimation:animation];

      // reset to start position 
      _borderWidth = snapshot->_borderWidth;
   }

   /*
    * CornerRadius
    */
   startValue = snapshot->_cornerRadius;
   endValue   = _cornerRadius;
   if( startValue != endValue)
   {
      animation = [[[CAAnimation alloc] initWithPropertySetter:@selector( setCornerRadius:) 
                                               startFloatValue:startValue
                                                 endFloatValue:endValue
                                                       options:options] autorelease];
      [animation setAnimationDelegate:animationDelegate];
      [self addAnimation:animation];

      // reset to start position 
      _cornerRadius = snapshot->_cornerRadius;
   }

   /*
    * Frame
    */
   startRect = snapshot->_frame;
   endRect   = _frame;    
   if( ! CGRectEqualToRect( startRect, endRect))
   {
      animation = [[[CAAnimation alloc] initWithPropertySetter:@selector( setFrame:) 
                                                     startRect:startRect
                                                       endRect:endRect
                                                       options:options] autorelease];
      [animation setAnimationDelegate:animationDelegate];
      [self addAnimation:animation];

      // reset to start position 
      _frame = snapshot->_frame;
   }  

   /*
    * Bounds
    */
   startRect = snapshot->_bounds;
   endRect   = _bounds;    
   if( ! CGRectEqualToRect( startRect, endRect))
   {
      animation = [[[CAAnimation alloc] initWithPropertySetter:@selector( setBounds:) 
                                                     startRect:startRect
                                                       endRect:endRect
                                                       options:options] autorelease];
      [animation setAnimationDelegate:animationDelegate];
      [self addAnimation:animation];

      // reset to start position 
      _bounds = snapshot->_bounds;
   }    
}


MulleQuadratic   CALayerQuadraticForCurveType( NSUInteger curvetype)
{
   MulleQuadratic   quadratic;

   switch( [UIView animationCurve])
   {
   case UIViewAnimationCurveEaseInOut: 
      MulleQuadraticInit( &quadratic, 0.0, 0.025, 1.0 - 0.025, 1.0);
      break;
      
   case UIViewAnimationCurveEaseOut: 
      MulleQuadraticInit( &quadratic, 0.0, 0.9, 0.9, 1.0);
      break;

   case UIViewAnimationCurveEaseIn: 
      MulleQuadraticInit( &quadratic, 0.0, 0.0, 0.1, 1.0);
      break;

   default :
      MulleQuadraticInit( &quadratic, 0.0, 0.333, 0.666, 1.0);
      break;
   }   

   return( quadratic);
}


- (void) commitImplicitAnimationsWithAnimationID:(char *) animationsID
                               animationDelegate:(MulleAnimationDelegate *) animationDelegate
{
   CAAnimation                  *animation;
   CGColorRef                   endColor;
   CGColorRef                   startColor;
   CGRect                       endRect;
   CGRect                       startRect;
   float                        repeatCount;
   struct CAAnimationOptions    options;
   struct CARelativeTimeRange   timeRange;

   if( ! _snapshot)
      return;

   [self removeAllAnimations];

   options.timeRange   = CARelativeTimeRangeMake( [UIView animationDelay], [UIView animationDuration]);
   options.repeatCount = [UIView animationRepeatCount];
   options.bits        = [UIView animationRepeatAutoreverses] ? CAAnimationReverses : 0;
   options.curve       = CALayerQuadraticForCurveType( [UIView animationCurve]);

   /** Our animatable properties
       subclasses might want to add more
    **/
   [self animatePropertiesWithSnapshotlayer:_snapshot
                          animationDelegate:animationDelegate
                           animationOptions:&options];

   [_snapshot autorelease];
   _snapshot = nil;  
}

@end

