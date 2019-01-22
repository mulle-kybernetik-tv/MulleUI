#import "import-private.h"

#import "UIView.h"
#import "UIWindow.h"
#import "CALayer.h"
#import "CGContext.h"
#import "CGGeometry+CString.h"
#import "nanovg+CString.h"


@implementation UIView

static void  pointerarray_release_all( struct mulle_pointerarray *array)
{
   struct mulle_pointerarray_enumerator   rover;
   id     obj;

   rover = mulle_pointerarray_enumerate( array);
   while( obj = mulle_pointerarray_enumerator_next( &rover))
      [obj release];
}


static void  pointerarray_copy_all( struct mulle_pointerarray *array, id *dst)
{
   struct mulle_pointerarray_enumerator   rover;
   id     obj;

   rover = mulle_pointerarray_enumerate( array);
   while( obj = mulle_pointerarray_enumerator_next( &rover))
      *dst++ = obj;;
}


- (id) initWithFrame:(CGRect) frame
{
   CALayer   *layer;

   layer = [[CALayer alloc] initWithFrame:frame];
   self = [self initWithLayer:layer];
   [layer release];
   return( self);
}


- (id) initWithLayer:(CALayer *) layer
{
   if( ! layer)
   {
      [self release];
      return( nil);
   }
   _mainLayer = [layer retain];

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
   [super dealloc];
}


//
//
//
- (void) addLayer:(CALayer *) layer
{
   assert( layer);

   if( ! _mainLayer)
   {
      _mainLayer = [layer retain];
      return;
   }
   assert(_mainLayer != layer);

   if( ! _layers)
      _layers = mulle_pointerarray_alloc( NULL, NULL);

   assert( mulle_pointerarray_find( _layers, layer) == -1);
   [layer retain];
   mulle_pointerarray_add( _layers, layer);
}


- (void) addSubview:(UIView *) view
{
   assert( view);
   assert( view != self);
   assert( ! [view superview]);

   if( ! _subviews)
      _subviews = mulle_pointerarray_alloc( NULL, NULL);

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
   [_mainLayer setFrame:rect];
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
   struct mulle_pointerarray_enumerator   rover;
   CALayer                                *layer;
   _NVGtransform                          transform;
   NVGscissor                             scissor;
   NVGcontext                             *vg;
   CGRect                                 bounds;

   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);

   vg     = [context nvgContext];
   bounds = [self bounds];

   fprintf( stderr, "%s: bounds: %s\n", 
                  [self cStringDescription],
                  CGRectCStringDescription( bounds));

   nvgCurrentTransform( vg, transform);
   nvgGetScissor( vg, &scissor);

   [_mainLayer setTransform:transform
                   scissor:&scissor];
   [_mainLayer drawInContext:context];

   if( _layers)
   {
#if 0      
      nvgIntersectScissor( vg, bounds.origin.x, bounds.origin.y, 
                               bounds.size.width, bounds.size.height);
      nvgGetScissor( vg, &scissor);
#endif                   
      rover = mulle_pointerarray_enumerate( _layers);
      while( layer = mulle_pointerarray_enumerator_next( &rover))
      {
         [layer setTransform:transform
                     scissor:&scissor];
         [layer drawInContext:context]; 
      }
   }
}


- (void) renderSubviewsWithContext:(CGContext *) context
{
   UIView      *subviews[ 32];
   NSInteger    n;
   NSInteger    available;
   NSInteger    i;

   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);

   available = sizeof( subviews) / sizeof( UIView *);
   n         = [self getSubviews:subviews
                          length:available];
   if( n > available)
      abort();

   for( i = 0; i < n; i++)
      [subviews[ i] renderWithContext:context];
}


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

   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);

   frame = [self frame];
   if( frame.size.width <= 0.0 || frame.size.height <= 0.0)
   {
      fprintf( stderr, "%s has no 2D frame\n", [self cStringDescription]);
      return;
   }

   bounds = [self bounds];
   if( bounds.size.width <= 0.0 || bounds.size.height <= 0.0)
   {
      fprintf( stderr, "%s has no 2D bounds\n", [self cStringDescription]);
      return;
   }

   vg = [context nvgContext];

   // remember for later
   nvgCurrentTransform( vg, transform);
   nvgGetScissor( vg, &scissor);

   fprintf( stderr, "%s: inherited transform %s\n",
                        [self cStringDescription],
                        _NVGtransformCStringDescription( transform));
   fprintf( stderr, "%s: inherited scissorTransform %s\n",
                        [self cStringDescription],
                        NVGscissorCStringDescription( &scissor));

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
   fprintf( stderr, "%s: reset1 to inherited transform %s\n", 
                     [self cStringDescription],
                     _NVGtransformCStringDescription( transform));                     
   nvgSetScissor( vg, &scissor);
   fprintf( stderr, "%s: reset1 to inherited scissorTransform %s\n", 
                     [self cStringDescription],
                     NVGscissorCStringDescription( &scissor));                     


   if( [self subviewCount] == 0)
      return;

   if( [self superview])
   {
      fprintf( stderr, "Set transform for subviews of %s (not a window)\n", [self cStringDescription]);

      nvgTranslate( vg, frame.origin.x, frame.origin.y);
      fprintf( stderr, "%s translate %.1f %.1f\n", 
                        [self cStringDescription], 
                        frame.origin.x, frame.origin.y);
      //
      // TODO: move this code to UIView (gut feeling)
      //
      // now translate bounds for context
      //
      scale.x = frame.size.width / bounds.size.width;
      scale.y = frame.size.height / bounds.size.height;

      nvgScale( vg, scale.x, scale.y);
      fprintf( stderr, "%s scale %.1f %.1f\n", 
                        [self cStringDescription], 
                        scale.x, scale.y);

      nvgTranslate( vg, bounds.origin.x, bounds.origin.y);
      fprintf( stderr, "%s translate %.1f %.1f\n", 
                        [self cStringDescription], 
                         bounds.origin.x, bounds.origin.y);

      nvgIntersectScissor( vg, 0.0, 0.0, bounds.size.width, bounds.size.height);
   }

   [self renderSubviewsWithContext:context];

   nvgResetTransform( vg);
   nvgTransform( vg, transform[ 0], transform[ 1], transform[ 2],
                     transform[ 3], transform[ 4], transform[ 5]);
   fprintf( stderr, "%s: reset2 to inherited transform %s\n", 
                     [self cStringDescription],
                     _NVGtransformCStringDescription( transform));     
   nvgSetScissor( vg, &scissor);
   fprintf( stderr, "%s: reset2 to inherited scissorTransform %s\n", 
                     [self cStringDescription],
                     NVGscissorCStringDescription( &scissor));                     
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

@end
