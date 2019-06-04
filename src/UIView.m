#import "import-private.h"

#import "UIView.h"
#import "UIWindow.h"
#import "CALayer.h"
#import "CGContext.h"
#import "CGGeometry+CString.h"
#import "nanovg+CString.h"


//#define RENDER_DEBUG
//#define RENDER_VERBOSE_DEBUG


@implementation UIView

static void  pointerarray_release_all( struct mulle_pointerarray *array)
{
   struct mulle_pointerarrayenumerator   rover;
   id     obj;

   rover = mulle_pointerarray_enumerate( array);
   while( obj = mulle_pointerarrayenumerator_next( &rover))
      [obj release];
}


static void  pointerarray_copy_all( struct mulle_pointerarray *array, id *dst)
{
   struct mulle_pointerarrayenumerator   rover;
   id     obj;

   rover = mulle_pointerarray_enumerate( array);
   while( obj = mulle_pointerarrayenumerator_next( &rover))
      *dst++ = obj;;
}


+ (Class) layerClass
{
   return( [CALayer class]);
}


- (id) initWithFrame:(CGRect) frame
{
   CALayer   *layer;
   Class     cls;

   cls   = [[self class] layerClass];
   layer = [[cls alloc] initWithFrame:frame];
   self  = [self initWithLayer:layer];
   [layer release];
   return( self);
}


- (id) initWithLayer:(CALayer *) layer
{
   assert( ! layer || [layer isKindOfClass:[CALayer class]]);

   if( ! layer)
   {
      [self release];
      return( nil);
   }
   _mainLayer     = [layer retain];
   _clipsSubviews = YES;  // default

   return( self);
}


- (void) dealloc
{
   if( _subviews)
   {
      pointerarray_release_all( _subviews);
      mulle_pointerarray_destroy( _subviews);
   }

   if( _layers)
   {
      pointerarray_release_all( _layers);
      mulle_pointerarray_destroy( _layers);
   }

   [_subviewsArrayProxy release];
   [_yoga release];

   [super dealloc];
}


//
//
//
- (void) addLayer:(CALayer *) layer
{
   assert( layer);
   assert( [layer isKindOfClass:[CALayer class]]);

   if( ! _mainLayer)
   {
      _mainLayer = [layer retain];
      return;
   }
   assert(_mainLayer != layer);

   if( ! _layers)
      _layers = mulle_pointerarray_create( NULL);

   assert( mulle_pointerarray_find( _layers, layer) == -1);
   [layer retain];
   mulle_pointerarray_add( _layers, layer);
}


- (void) addSubview:(UIView *) view
{
   assert( view);
   assert( view != self);
   assert( ! [view superview]);
   assert( [view isKindOfClass:[UIView class]]);

   if( ! _subviews)
      _subviews = mulle_pointerarray_create( NULL);

   assert( mulle_pointerarray_find( _subviews, view) == -1);
   [view retain];
   mulle_pointerarray_add( _subviews, view);

   view->_superview = self;
}


- (NSUInteger) subviewCount
{
   return( _subviews ? mulle_pointerarray_get_count( _subviews) : 0);
}


- (NSInteger) getLayers:(CALayer **) buf
                 length:(NSUInteger) length
{
   NSUInteger  n;

   if( ! _mainLayer)
      return( 0);

   n = 1;
   if( _layers)
      n += mulle_pointerarray_get_count( _layers);

   if( n > length)
      return( n);
   if( ! buf)
      return( -1);

   if( _layers)
      pointerarray_copy_all( _layers, buf);

   buf[ n - 1] = _mainLayer;

   return( n);
}


- (NSInteger) getSubviews:(UIView **) buf
                   length:(NSUInteger) length
{
   NSUInteger  n;

   n = 0;
   if( _subviews)
      n += mulle_pointerarray_get_count( _subviews);

   if( n > length)
      return( n);
   if( ! buf)
      return( -1);
   if( _subviews)
      pointerarray_copy_all( _subviews, buf);

   return( n);
}


- (CALayer *) mainLayer
{
   assert( _mainLayer);
   return( _mainLayer);
}


- (BOOL) isMultiLayer
{
   return( _layers != NULL);
}


- (CGRect) bounds
{
   return( [_mainLayer bounds]);
}


- (void) setBounds:(CGRect) rect;
{
   [_mainLayer setBounds:rect];
}


- (CGRect) frame
{
   return( [_mainLayer frame]);
}


- (void) setFrame:(CGRect) rect
{
   [_mainLayer setFrame:rect];
}


- (CGRect) clipRect
{
   return( [_mainLayer clipRect]);
}


- (void) setNeedsLayout
{
	_needsLayout = YES;
}


- (char *) cStringDescription
{
   char        *result;
   char        *s;
   auto char   buf[ 64];
   size_t      len;
   char        *format;
   char        *name;

   s = class_getName( object_getClass( self));
   sprintf( buf, "%p",  self);

   format = "<%s %s>";
   name   = [_mainLayer cStringName];
   len    = name ? strlen( name) : 0;
   if( len)
   {
      format = "<%s %s \"%s\">";
      len   += 3; // < "">\0"
   }
   len    += strlen( s) + strlen( buf) + 4; // < "">\0"
   result  = mulle_malloc( len);
   sprintf( result, format, s, buf, name);
   MulleObjCAutoreleaseAllocation( result, NULL);

   return( result);
}


- (void) renderLayersWithContext:(CGContext *) context
{
   struct mulle_pointerarrayenumerator   rover;
   CALayer                                *layer;
   _NVGtransform                          transform;
   NVGscissor                             scissor;
   NVGcontext                             *vg;

#ifdef RENDER_DEBUG
   fprintf( stderr, "%s %s (f:%s b:%s)\n", 
                        __PRETTY_FUNCTION__, 
                        [self cStringDescription],
                        CGRectCStringDescription( [self frame]),
                        CGRectCStringDescription( [self bounds]));
#endif

   vg = [context nvgContext];
   nvgCurrentTransform( vg, transform);
   nvgGetScissor( vg, &scissor);

   [_mainLayer setTransform:transform
                    scissor:&scissor];
   [_mainLayer drawInContext:context];

   if( _layers)
   {
      rover = mulle_pointerarray_enumerate( _layers);
      while( layer = mulle_pointerarrayenumerator_next( &rover))
      {
         [layer setTransform:transform
                     scissor:&scissor];
         [layer drawInContext:context];
      }
      mulle_pointerarrayenumerator_done( &rover);
   }
}


- (void) renderSubviewsWithContext:(CGContext *) context
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;

#ifdef RENDER_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   rover = mulle_pointerarray_enumerate( _subviews);
   while( view = mulle_pointerarrayenumerator_next( &rover))
      [view renderWithContext:context];
   mulle_pointerarrayenumerator_done( &rover);
}


#if 0
- (void) debugFill:(NVGcontext *) vg
{
   CGPoint  tl;
   CGPoint  br;

   tl.x = 100.0;
   tl.y = 100.0;
   br.x = 200.0;
   br.y = 200.0;

//   tl.x = frame.origin.x;
//   tl.y = frame.origin.y;
//   br.x = tl.x + frame.size.width - 1;
//   br.y = tl.y + frame.size.height - 1;

   nvgBeginPath( vg);
   nvgRoundedRect( vg, tl.x, 
                       tl.y, 
                       br.x - tl.x + 1, 
                       br.y - tl.y + 1, 
                       20);

//   nvgMoveTo( vg, tl.x, tl.y);
//   nvgLineTo( vg, br.x, tl.y);
//   nvgLineTo( vg, br.x, br.y);
//   nvgLineTo( vg, tl.x, br.y);
//   nvgLineTo( vg, tl.x, tl.y);
   nvgFillColor(vg, getNVGColor( 0x00FF00FF));
   nvgFill( vg);
}
#endif


- (void) renderWithContext:(CGContext *) context
{
   _NVGtransform   transform;
   NVGscissor      scissor;
   NVGcontext      *vg;
   CGPoint         scale;
   CGRect          frame;
   CGRect          bounds;
   CGRect          contextClipRect;
   CGRect          clipRect;

#ifdef RENDER_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   frame = [self frame];
   if( frame.size.width <= 0.0 || frame.size.height <= 0.0)
   {
#ifdef RENDER_DEBUG
      fprintf( stderr, "%s has no 2D frame\n", [self cStringDescription]);
#endif
      return;
   }

   bounds = [self bounds];
   if( bounds.size.width <= 0.0 || bounds.size.height <= 0.0)
   {
#ifdef RENDER_DEBUG
      fprintf( stderr, "%s has no 2D bounds\n", [self cStringDescription]);
#endif
      return;
   }

   // run layout if necessary (right place here ?)
   if( [self needsLayout])
   {
   	[self setNeedsLayout:NO];
   	[self layoutSubviews];
   	assert( ! [self needsLayout]);
   }

   vg = [context nvgContext];


   // remember for later
   nvgCurrentTransform( vg, transform);
   nvgGetScissor( vg, &scissor);

#ifdef RENDER_VERBOSE_DEBUG
   fprintf( stderr, "%s: inherited transform %s\n",
                        [self cStringDescription],
                        _NVGtransformCStringDescription( transform));
   fprintf( stderr, "%s: inherited scissorTransform %s\n",
                        [self cStringDescription],
                        NVGscissorCStringDescription( &scissor));
#endif

   //
   // layers do not "suffer" from translation and scaling as these
   // values are derived from the "masterLayer"
   //
   // The masterLayer also sets up the scissors for the following renders
   //
   [self renderLayersWithContext:context];

   //
   // transform for subview though, which are inside our bounds
   // don't do this if we are the window top level
   //
   nvgResetTransform( vg);
   nvgTransform( vg, transform[ 0], transform[ 1], transform[ 2],
                     transform[ 3], transform[ 4], transform[ 5]);
#ifdef RENDER_VERBOSE_DEBUG
   fprintf( stderr, "%s: reset1 to inherited transform %s\n",
                     [self cStringDescription],
                     _NVGtransformCStringDescription( transform));
#endif
   nvgSetScissor( vg, &scissor);
#ifdef RENDER_VERBOSE_DEBUG
   fprintf( stderr, "%s: reset1 to inherited scissorTransform %s\n",
                     [self cStringDescription],
                     NVGscissorCStringDescription( &scissor));
#endif

   if( [self superview])
   {
      // clip to our frame
      if( self->_clipsSubviews)
         nvgIntersectScissor( vg, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

#ifdef RENDER_VERBOSE_DEBUG
      fprintf( stderr, "Set transform for subviews of %s (not a window)\n", [self cStringDescription]);
#endif
      nvgTranslate( vg, frame.origin.x, frame.origin.y);
#ifdef RENDER_VERBOSE_DEBUG
      fprintf( stderr, "%s translate %.1f %.1f\n",
                        [self cStringDescription],
                        frame.origin.x, frame.origin.y);
#endif
      //
      // now translate bounds for context
      //
      scale.x = frame.size.width / bounds.size.width;
      scale.y = frame.size.height / bounds.size.height;

      nvgScale( vg, scale.x, scale.y);
#ifdef RENDER_VERBOSE_DEBUG
      fprintf( stderr, "%s scale %.1f %.1f\n",
                        [self cStringDescription],
                        scale.x, scale.y);
#endif
      nvgTranslate( vg, bounds.origin.x, bounds.origin.y);
#ifdef RENDER_VERBOSE_DEBUG
      fprintf( stderr, "%s translate %.1f %.1f\n",
                        [self cStringDescription],
                         bounds.origin.x, bounds.origin.y);
#endif
   }

   [self renderSubviewsWithContext:context];

   nvgResetTransform( vg);
   nvgTransform( vg, transform[ 0], transform[ 1], transform[ 2],
                     transform[ 3], transform[ 4], transform[ 5]);
#ifdef RENDER_VERBOSE_DEBUG
   fprintf( stderr, "%s: reset2 to inherited transform %s\n",
                     [self cStringDescription],
                     _NVGtransformCStringDescription( transform));
#endif
   nvgSetScissor( vg, &scissor);
#ifdef RENDER_VERBOSE_DEBUG
   fprintf( stderr, "%s: reset2 to inherited scissorTransform %s\n",
                    [self cStringDescription],
                    NVGscissorCStringDescription( &scissor));
#endif
}


- (void) layoutSubviews
{
	// does nothing or will it ?
}


- (UIView *) superview
{
   return( _superview);
}


- (UIWindow *) window
{
   UIView   *view;
   UIView   *parent;

   view = self;
   while( parent = [view superview])
      view = parent;

   if( [view isKindOfClass:[UIWindow class]])
   {
      fprintf( stderr, "window found\n");
      return( (UIWindow *) view);
   }
   return( nil);
}


// https://developer.apple.com/documentation/uikit/uiview/1622625-sizethatfits?language=objc
- (CGSize) sizeThatFits:(CGSize) size
{
   return( [_mainLayer frame].size);
}

@end
