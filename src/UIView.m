#import "import-private.h"

#import "UIView.h"
#import "UIWindow.h"
#import "CALayer.h"
#import "CGContext.h"


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

- (void) renderSubviewsWithContext:(CGContext *) context
{
   UIView      *subviews[ 32];
   NSInteger    n;
   NSInteger    available;
   NSInteger    i;

   available = sizeof( subviews) / sizeof( UIView *);
   n         = [self getSubviews:subviews
                          length:available];
   if( n > available)
      abort();

   for( i = 0; i < n; i++)
      [subviews[ i] renderWithContext:context];
}


- (void) renderLayersWithContext:(CGContext *) context
{
   struct mulle_pointerarray_enumerator   rover;
   CALayer                                *layer;

   [context resetTransform];
   [_mainLayer drawInContext:context]; 

   if( _layers)
   {
      rover = mulle_pointerarray_enumerate( _layers);
      while( layer = mulle_pointerarray_enumerator_next( &rover))
      {
         [context resetTransform];
         [layer drawInContext:context]; 
      }
   }
}


- (void) renderWithContext:(CGContext *) context
{
   [self renderLayersWithContext:context];
   [self renderSubviewsWithContext:context];
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
