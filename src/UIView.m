#import "import-private.h"

#import "UIView.h"
#import "UIView+CAAnimation.h"
#import "UIView+Yoga.h"  // move elsewhere ?
#import "UIWindow.h"
#import "UIWindow+UIEvent.h"
#import "CALayer.h"
#import "CALayer+CAAnimation.h"
#import "CGContext.h"
#import "CGGeometry+CString.h"
#import "MulleTextureImage.h"
#import "MulleImageLayer.h"
#import "nanovg+CString.h"
#import "mulle-pointerarray+ObjC.h"


//#define RENDER_DEBUG
// #define RENDER_DEBUG_VERBOSE
//#define HAVE_RENDER_CACHE

@implementation UIView

+ (Class) layerClass
{
   return( [CALayer class]);
}


+ (instancetype) mulleViewWithFrame:(CGRect) frame;
{
   return( [[[self alloc] initWithFrame:frame] autorelease]);
}


- (instancetype) initWithFrame:(CGRect) frame
{
   CALayer   *layer;
   Class     cls;

   cls   = [[self class] layerClass];
   layer = [[cls alloc] initWithFrame:frame];
   self  = [self initWithLayer:layer];
   [layer release];
   return( self);
}

// designated initializer
- (instancetype) initWithLayer:(CALayer *) layer
{
   assert( ! layer || [layer isKindOfClass:[CALayer class]]);

   if( ! layer)
   {
      [self release];
      return( nil);
   }
   _mainLayer              = [layer retain];
   _clipsSubviews          = YES;  // default
   _userInteractionEnabled = YES;  // default
   _alpha                  = 1.0;
   return( self);
}


- (void) dealloc
{
   mulle_pointerarray_release_all( _subviews);
   mulle_pointerarray_destroy( _subviews);

   mulle_pointerarray_release_all( _layers);
   mulle_pointerarray_destroy( _layers);

   [_mainLayer release];

   [_subviewsArrayProxy release];
   [_yoga release];

   [super dealloc];
}

- (CALayer *) layer
{
   return( _mainLayer);
}


//
//
//
- (void) mulleAddRetainedLayer:(CALayer *) layer
{
   assert( layer);
   assert( [layer isKindOfClass:[CALayer class]]);

   if( ! _mainLayer)
   {
      _mainLayer = layer;
      return;
   }
   assert(_mainLayer != layer);

   if( ! _layers)
      _layers = mulle_pointerarray_create_nil( NULL);

   assert( _mulle_pointerarray_find( _layers, layer) == -1);
   _mulle_pointerarray_add( _layers, layer);
}


- (void) addLayer:(CALayer *) layer
{
   [self mulleAddRetainedLayer:[layer retain]];
}


- (struct mulle_pointerarray *) _layers
{
   struct mulle_allocator   *allocator;

   if( ! _layers)
   {
      allocator = MulleObjCInstanceGetAllocator( self);
      _layers = mulle_pointerarray_alloc( allocator);
      _mulle_pointerarray_init( _layers, 4, nil, allocator);
   }
   return( _layers);
}


- (struct mulle_pointerarray *) _subviews 
{
   struct mulle_allocator   *allocator;

   if( ! _subviews)
   {
      allocator = MulleObjCInstanceGetAllocator( self);
      _subviews = mulle_pointerarray_alloc( allocator);
      _mulle_pointerarray_init( _subviews, 4, nil, allocator);
   }
   return( _subviews);
}

- (void) mulleAddRetainedSubview:(UIView *) view
{
   struct mulle_pointerarray  *subviews;
   assert( view);
   assert( view != self);
   assert( ! [view superview]);
   assert( [view isKindOfClass:[UIView class]]);
   
   subviews = [self _subviews];
   assert( _mulle_pointerarray_find( subviews, view) == -1);
   _mulle_pointerarray_add( subviews, view);

   view->_superview = self;
}

- (void) addSubview:(UIView *) view
{
   [self mulleAddRetainedSubview:[view retain]];
}



- (NSUInteger) subviewCount
{
   return( _subviews ? mulle_pointerarray_get_count( _subviews) : 0);
}


- (NSInteger) getLayers:(CALayer **) buf
                 length:(NSUInteger) length
{
   NSUInteger   n;

   if( ! _mainLayer)
      return( 0);

   n = 1;
   if( _layers)
      n += mulle_pointerarray_get_count( _layers);

   if( n > length)
      return( n);
   if( ! buf)
      return( -1);

   mulle_pointerarray_copy_all( _layers, buf);

   buf[ n - 1] = _mainLayer;

   return( n);
}


- (NSInteger) getSubviews:(UIView **) buf
                   length:(NSUInteger) length
{
   NSUInteger   n;

   n = _subviews ? mulle_pointerarray_get_count( _subviews) : 0;
   if( n > length)
      return( n);
   if( ! buf)
      return( -1);

   mulle_pointerarray_copy_all( _subviews, buf);

   return( n);
}

//
// TODO: use some other data structure, not pointerarray ?
//
- (void) setSubviews:(struct mulle_pointerarray *) array
{
   struct mulle_allocator   *allocator;

   if( array == self->_subviews)
      return;

   if( ! array)
   {
      mulle_pointerarray_release_all( _subviews);
      mulle_pointerarray_destroy( _subviews);
      _subviews = NULL;
      return;       
   }

   allocator = MulleObjCInstanceGetAllocator( self);
   assert( _mulle_pointerarray_get_allocator( array) == allocator);

   /* retain/release */
   mulle_pointerarray_retain_all( array);

   if( ! _subviews)
      _subviews = mulle_pointerarray_alloc( allocator);
   else
   {
      mulle_pointerarray_release_all( _subviews);
      _mulle_pointerarray_done( _subviews);   // but don't free
   }

   // transfer objects
   memcpy( _subviews, array, sizeof( struct mulle_pointerarray));
   // make sure these aren't reused by array anymore
   _mulle_pointerarray_init( array, 0, nil, allocator); 
}


- (void) addSubviewsIntersectingRect:(CGRect) rect 
                      toPointerArray:(struct mulle_pointerarray *) array
              invertIntersectionTest:(BOOL) flag
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;

   flag = ! flag;
   rover = mulle_pointerarray_enumerate_nil( _subviews);
   while( view = _mulle_pointerarrayenumerator_next( &rover))
      if( CGRectIntersectsRect( [view frame], rect) == flag)
         mulle_pointerarray_add( array, view);
   mulle_pointerarrayenumerator_done( &rover);
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


- (void) setNeedsDisplay
{
   _needsDisplay = YES;
}


- (void *) forward:(void *) param
{
   assert( _mainLayer); // window should not forward...
   return( mulle_objc_object_inlinecall_variablemethodid( _mainLayer,
                                                          (mulle_objc_methodid_t) _cmd,
                                                          param));
}


//// conveniences
//- (void) setBackgroundColor:(CGColorRef) color 
//{
//   [_mainLayer setBackgroundColor:color];
//}
//
//- (void) setBorderColor:(CGColorRef) color 
//{
//   return( [_mainLayer setBorderColor:color]);
//}
//
//- (void) setBorderWidth:(CGFloat) value 
//{
//   [_mainLayer setBorderWidth:value];
//}
//
//- (void) setCornerRadius:(CGFloat) value 
//{
//   return( [_mainLayer setCornerRadius:value]);
//}
//
//
//- (CGColorRef) backgroundColor
//{
//   return( [_mainLayer backgroundColor]);
//}
//
//- (CGColorRef) borderColor 
//{
//   return( [_mainLayer borderColor]);
//}
//
//- (CGFloat) borderWidth 
//{
//   return( [_mainLayer borderWidth]);
//}
//
//- (CGFloat) cornerRadius 
//{
//   return( [_mainLayer cornerRadius]);
//}
//

// Done by Yoga
// - (void) setNeedsLayout
// {
//    _needsLayout = YES;
// }

// maybe wrong name ?
- (void) setNeedsCaching  // wipes the _backinglayer and asks for a new one to be drawn
{
#ifdef HAVE_RENDER_CACHE
   // might have to do this atomically later on 
   _needsCaching = YES;
   [_cacheLayer autorelease];
   _cacheLayer = nil;
#endif   
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

- (void) _createRenderCacheIfNeededWithContext:(CGContext *) context
                                     frameInfo:(struct MulleFrameInfo *) info
{
#ifdef HAVE_RENDER_CACHE
   UIImage   *image;

   if( ! _needsCaching)
      return;

   _needsCaching = NO;
   image = [self textureImageWithContext:context
                              frameInfo:info
                                 options:0];
   if( image)
   {
      _cacheLayer = [[MulleImageLayer alloc] initWithFrame:[_mainLayer frame]];
      [_cacheLayer setImage:image];
   }
#endif   
}

- (void) updateRenderCachesWithContext:(CGContext *) context
                             frameInfo:(struct MulleFrameInfo *) info
{
#ifdef HAVE_RENDER_CACHE
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;

#ifdef RENDER_DEBUG_VERBOSE
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   rover = mulle_pointerarray_enumerate_nil( _subviews);
   while( view = mulle_pointerarrayenumerator_next( &rover))
      [view updateRenderCachesWithContext:context
                                frameInfo:info];
   mulle_pointerarrayenumerator_done( &rover);

   [self _createRenderCacheIfNeededWithContext:context
                                     frameInfo:info];
#endif                                     
}


- (BOOL) renderLayersWithContext:(CGContext *) context
{
   struct mulle_pointerarrayenumerator   rover;
   CALayer                               *layer;
   _NVGtransform                         transform;
   NVGscissor                            scissor;
   NVGcontext                            *vg;
   CGFloat                               oldAlpha;
   CGFloat                               alpha;

#ifdef RENDER_DEBUG_VERBOSE
   fprintf( stderr, "%s %s (f:%s b:%s)\n", 
                        __PRETTY_FUNCTION__, 
                        [self cStringDescription],
                        CGRectCStringDescription( [self frame]),
                        CGRectCStringDescription( [self bounds]));
#endif

   vg = [context nvgContext];

   nvgCurrentTransform( vg, transform);
   nvgGetScissor( vg, &scissor);

#ifdef HAVE_RENDER_CACHE
   if( _cacheLayer)
   {
      [_cacheLayer setTransform:transform
                        scissor:&scissor];
      [_cacheLayer drawInContext:context];
      return( YES);
   }
#endif

   [_mainLayer setTransform:transform
                    scissor:&scissor];
   [_mainLayer drawInContext:context];

   rover = mulle_pointerarray_enumerate_nil( _layers);
   while( (layer = _mulle_pointerarrayenumerator_next( &rover)))
   {
      [layer setTransform:transform
                  scissor:&scissor];
      [layer drawInContext:context];
   }
   mulle_pointerarrayenumerator_done( &rover);

   return( NO);
}


- (void) renderSubviewsWithContext:(CGContext *) context
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;
   CGRect                                bounds;
   CGRect                                frame;

#ifdef RENDER_DEBUG_VERBOSE
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   bounds = [self bounds];
   rover  = mulle_pointerarray_enumerate_nil( _subviews);
   while( (view = _mulle_pointerarrayenumerator_next( &rover)))
   {
      frame = [view frame];
      // TODO: this intersection code doesn't work for UIScrollView,
      // because the UIScrollContentView uses bounds.origin to shift its
      // contents. The intersection code will mistaken ly notice for larger 
      // scrolls, that the contentView is displaying nothing and will cull it.
      //
      // TODO: REALLY figure out what to do with bounds and frame. Can bounds
      //       be used in scrollview ?
      
    //  if( CGRectIntersectsRect( bounds, frame))
         [view renderWithContext:context];
   }
   mulle_pointerarrayenumerator_done( &rover);
}

- (void) _renderWithContext:(CGContext *) context
{
   _NVGtransform   transform;
   NVGscissor      scissor;
   NVGcontext      *vg;
   CGPoint         scale;
   CGRect          frame;
   CGRect          bounds;
   CGRect          contextClipRect;
   CGRect          clipRect;
   CGFloat         alpha;

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
   
   vg = [context nvgContext];

// DEBUG CODE JUST TO SEE SOMETHING IN RENDERDOC
//   nvgBeginPath( vg);
//   nvgCircle(vg, CGRectGetMidX( frame), CGRectGetMidY( frame), 10.0);
//   nvgStrokeColor( vg, nvgRGBA(0, 32, 0, 32));
//   nvgStroke( vg);
// 
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
   // clip to our frame

   if( [self renderLayersWithContext:context])
   {

#ifdef RENDER_VERBOSE
      fprintf( stderr, "%s: renderLayersWithContext preempts subview drawing\n",
                     [self cStringDescription]);
#endif

      return;
   }

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


- (void) renderWithContext:(CGContext *) context
{
   CGFloat  alpha;
   CGFloat  oldAlpha;

#ifdef RENDER_DEBUG_VERBOSE
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   alpha = [self alpha];
   if( alpha < 0.01)
      return;
   if( [self isHidden])
      return;
     
   //
   // set alpha, if needed 
   // layers need to read this and multiply with their opacity and
   // colors (or texture operations)
   //
   if( alpha != 1.0)
   {
      oldAlpha = [context alpha];
      [context setAlpha:oldAlpha * alpha];
   }

   [self _renderWithContext:context];

   // reset alpha, if needed
   if( alpha != 1.0)
      [context setAlpha:oldAlpha];
}


- (void) makeLayersPerformSelector:(SEL) sel
                  withAbsoluteTime:(CAAbsoluteTime) renderTime
{
   struct mulle_pointerarrayenumerator   rover;
   CALayer                               *layer;

#ifdef RENDER_DEBUG_VERBOSE
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   MulleObjCObjectPerformSelectorDoubleArgument( _mainLayer, sel, renderTime);
   
   rover = mulle_pointerarray_enumerate_nil( _layers);
   while( (layer = _mulle_pointerarrayenumerator_next( &rover)))
      MulleObjCObjectPerformSelectorDoubleArgument( layer, sel, renderTime);
   mulle_pointerarrayenumerator_done( &rover);
}


- (void) makeSubviewsPerformSelector:(SEL) sel
                    withAbsoluteTime:(CAAbsoluteTime) renderTime
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;

#ifdef RENDER_DEBUG_VERBOSE
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   rover = mulle_pointerarray_enumerate_nil( _subviews);
   while( (view = _mulle_pointerarrayenumerator_next( &rover)))
      MulleObjCObjectPerformSelectorDoubleArgument( view, sel, renderTime);
   mulle_pointerarrayenumerator_done( &rover);
}


- (void) animateWithAbsoluteTime:(CAAbsoluteTime) renderTime
{
   [self makeLayersPerformSelector:_cmd   
                 withAbsoluteTime:renderTime];
   [self makeSubviewsPerformSelector:_cmd
                    withAbsoluteTime:renderTime];
}


- (void) willAnimateWithAbsoluteTime:(CAAbsoluteTime) renderTime
{
   [self makeLayersPerformSelector:_cmd   
                  withAbsoluteTime:renderTime];
   [self makeSubviewsPerformSelector:_cmd
                    withAbsoluteTime:renderTime];
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
   while( (parent = [view superview]))
      view = parent;

   if( [view isKindOfClass:[UIWindow class]])
   {
      //fprintf( stderr, "window found\n");
      return( (UIWindow *) view);
   }
   return( nil);
}

//
// look for the plance, the view is part of (if any)
// a plane will say nil
//
- (UIView *) mulleWindowPlane
{
   UIView   *view;
   UIView   *plane;
   UIView   *parent;

   plane = nil;
   view  = self;
   while( (parent = [view superview]))
   {
      plane = view;
      view  = parent;
   }

   if( [view isKindOfClass:[UIWindow class]])
   {
      //fprintf( stderr, "window found\n");
      return( plane);
   }
   return( nil);
}



- (UIImage *) textureImageWithContext:(CGContext *) context
                            frameInfo:(struct MulleFrameInfo *) info
                              options:(NSUInteger) options
{
   struct MulleFrameInfo   renderInfo;
   MulleTextureImage       *image;
   CGRect                  frame;

   frame = [self frame];

   renderInfo.frame                  = frame;
   renderInfo.windowSize             = frame.size;
   renderInfo.framebufferSize.width  = frame.size.width / info->pixelRatio;
   renderInfo.framebufferSize.height = frame.size.height / info->pixelRatio;
   renderInfo.UIScale                = info->UIScale;
   renderInfo.pixelRatio             = info->pixelRatio;
   renderInfo.isPerfEnabled          = NO;

   image = [context framebufferImageWithSize:renderInfo.framebufferSize
                                     options:options];
   if( image)
   {
      // Draw some stuff to an FBO as a test
      nvgluBindFramebuffer( [image framebuffer]);
      @autoreleasepool
      {
         [context startRenderWithFrameInfo:&renderInfo];
         [context clearFramebuffer];
         // translate to 0.0 ? scale to fit ?
         nvgTranslate( [context nvgContext], -frame.origin.x, -frame.origin.y);
         [self renderWithContext:context];
         [context endRender];
      }
      nvgluBindFramebuffer( NULL);
   }
   return( image);
}

# pragma mark - tracking rectangles

- (struct MulleTrackingArea *) addTrackingAreaWithRect:(CGRect) rect
                                              toWindow:(UIWindow *) window
                                              userInfo:(id) userInfo 
{
   struct MulleTrackingArea   *tracking;
   UIWindow                  *window;

   if( ! window)
      window = [self window];

   assert( window);

   if( MulleTrackingAreaArrayGetCount( &_trackingAreas) == 0)
   {
      // if window does not exist, then a late add would not be noticed
      // and tracking fails... 
      [window addTrackingView:self];
   }

   tracking = MulleTrackingAreaArrayNewItem( &_trackingAreas);
   MulleTrackingAreaInit( tracking, rect, userInfo);
   return( tracking);
}

- (void) removeTrackingArea:(struct MulleTrackingArea *) item
{
   UIWindow   *window;

   MulleTrackingAreaArrayRemoveItem( &_trackingAreas, item);
   if( MulleTrackingAreaArrayGetCount( &_trackingAreas) == 0)
   {
      window = [self window];
      assert( window);
      [window removeTrackingView:self];
   }
}

- (NSUInteger) numberOfTrackingAreas
{
   return( MulleTrackingAreaArrayGetCount( &_trackingAreas));
}


- (struct MulleTrackingArea *) trackingAreaAtIndex:(NSUInteger) i
{
   struct MulleTrackingArea   *item;

   item = MulleTrackingAreaArrayGetItemAtIndex( &_trackingAreas, i);
   return( item);
}


- (BOOL) mulleIsEffectivelyHidden  // recursive test the hierarchy up
{
   UIView   *p;

   p = self;
   for(;;)
   {
      if( p->_hidden)
         return( YES);
      p = p->_superview;
      if( ! p)
         return( NO);
   }
}

@end
