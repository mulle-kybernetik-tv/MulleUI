#import "import-private.h"

#import "CALayer.h"

#import "CGGeometry.h"
#import "CGGeometry+CString.h"
#import "CGContext.h"
#import "nanovg+CString.h"
#import "UIView+CAAnimation.h"
#import "MulleEdgeInsets.h"


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

   allocator = MulleObjCInstanceGetAllocator( self);
   mulle_allocator_free( allocator, _cStringName);

   rover = mulle_pointerarray_enumerate_nil( &_animations);
   while( (animation = _mulle_pointerarrayenumerator_next( &rover)))
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
      (*_drawContentsCallback)( self, [context nvgContext], [self frame], [context currentFrameInfo]);
}


- (void) drawBackgroundInContext:(CGContext *) context 
{
   NVGcontext     *vg;
   CGPoint        tl;
   CGPoint        br;
   CGRect         frame;
   CGFloat        borderWidth;
   MulleEdgeInsets   insets;

   // if transparent, just don't draw anything
   if( _backgroundColor.a <= 0.0)
      return;

   // if there is a border to be drawn, then we use antialias
   // otherwise we don't and only draw to the middle of the border

   vg = [context nvgContext];

   //
   // fill and border are drawn as frame
   // contents in bounds of superview
   //
   frame  = [self frame];

   borderWidth = [self borderWidth];
   if( borderWidth > 0.1)
   {
      insets = MulleEdgeInsetsMake( borderWidth / 2, borderWidth / 2,  borderWidth / 2, borderWidth / 2);
      frame  = MulleEdgeInsetsInsetRect( frame, insets);
      nvgShapeAntiAlias( vg, 0);  
   }

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
      nvgFillColor(vg, _backgroundColor);
      nvgFill( vg);
   } 
   nvgShapeAntiAlias( vg, 1);  
}


- (void) drawBorderInContext:(CGContext *) context
{
   NVGcontext  *vg;
   CGRect      frame;
   CGFloat     halfBorderWidth;
   CGPoint     tl;
   CGPoint     br;   

   //
   // the strokeWidth isn't scaled in nvg, so we do this now ourselves
   //
   if( _borderWidth <= 0.1)
      return;

   // if transparent, just don't draw anything
   if( _backgroundColor.a <= 0.0)
      return;
 
   vg = [context nvgContext];

   //
   // fill and border are drawn as frame
   // contents in bounds of superview
   //

   frame  = [self frame];

   //
   // if the stroke is alpha, it will have to render over pixels
   // otherwise reduce the size of the shape we draw
   //

   halfBorderWidth = _borderWidth / 2.0;

   tl.x = halfBorderWidth + frame.origin.x ;
   tl.y = halfBorderWidth + frame.origin.y;
   br.x = tl.x + frame.size.width - halfBorderWidth * 2;
   br.y = tl.y + frame.size.height - halfBorderWidth * 2;

   if( ! (tl.x <= br.x || tl.y <= br.y))
      return;
   //
   // the _cornerRadius is computed for a stroke of width 1 (or 0 ?)
   // the strokeWidth is just scaling it out
   //
   nvgBeginPath( vg);
   nvgRoundedRect( vg, tl.x, 
                       tl.y, 
                       br.x - tl.x, 
                       br.y - tl.y, 
                       _cornerRadius);
   nvgStrokeWidth( vg, (int) _borderWidth);
   nvgStrokeWidth( vg, (int) _borderWidth);
   nvgStrokeColor( vg, _borderColor);
   nvgStroke( vg);

//      nvgMoveTo( vg, tl.x, tl.y);
//      nvgLineTo( vg, br.x, tl.y);
//      nvgLineTo( vg, br.x, br.y);
//      nvgLineTo( vg, tl.x, br.y);
//      nvgLineTo( vg, tl.x, tl.y);
} 


- (BOOL) drawInContext:(CGContext *) context
{
   CGPoint           scale;
   CGRect            frame;
   CGRect            bounds;
   CGFloat           halfBorderWidth;
   CGFloat           halfBorderHeight;
   CGFloat           obscured;
   CGFloat           borderHeight;
   CGPoint           tl;
   CGPoint           br;
   CGSize            sz;
   int               radius;
   NVGcontext        *vg;
   struct NVGpaint   paint; // todo convert to CG ??

#ifdef RENDER_DEBUG
   fprintf( stderr, "%s %s (f:%s b:%s)\n", 
                        __PRETTY_FUNCTION__, 
                        [self cStringDescription],
                        CGRectCStringDescription( [self frame]),
                        CGRectCStringDescription( [self bounds]));
#endif

   frame = [self frame];
   if( frame.size.width == 0.0 || frame.size.height == 0.0)
      return( NO);

   if( _opacity < 0.001 || _hidden == YES)
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

   [self drawBackgroundInContext:context];

   [self drawContentsInContext:context];

   [self drawBorderInContext:context];

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



//
// This is called very often during animation, it would be good if the
// animation code could use a different setter that does not call
// will change..
//
- (void) willChange
{
   // this is called frequently so use C
   if( ! UIViewAreAnimationsEnabled())
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
   _mulle_pointerarray_init( &copy->_animations, 0, 0, NULL);
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

   allocator = MulleObjCInstanceGetAllocator( self);
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



@end

