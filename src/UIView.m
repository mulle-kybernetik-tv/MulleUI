#import "import-private.h"

#import "UIView.h"
#import "UIView+CAAnimation.h"
#import "UIWindow.h"
#import "CALayer.h"
#import "CGContext.h"
#import "CGGeometry+CString.h"
#import "MulleTextureImage.h"
#import "MulleImageLayer.h"
#import "nanovg+CString.h"
#import "mulle-pointerarray+ObjC.h"


//#define RENDER_DEBUG
//#define HAVE_RENDER_CACHE

@implementation UIView

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
   mulle_pointerarray_release_all( _subviews);
   mulle_pointerarray_destroy( _subviews);

   mulle_pointerarray_release_all( _layers);
   mulle_pointerarray_destroy( _layers);

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

   n = 0;
   if( _subviews)
      n += mulle_pointerarray_get_count( _subviews);

   if( n > length)
      return( n);
   if( ! buf)
      return( -1);

   mulle_pointerarray_copy_all( _subviews, buf);

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

#ifdef RENDER_DEBUG
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
   while( layer = mulle_pointerarrayenumerator_next( &rover))
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

#ifdef RENDER_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   rover = mulle_pointerarray_enumerate_nil( _subviews);
   while( view = mulle_pointerarrayenumerator_next( &rover))
      [view renderWithContext:context];
   mulle_pointerarrayenumerator_done( &rover);
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
   if( [self renderLayersWithContext:context])
      return;

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


- (void) animateLayersWithAbsoluteTime:(CAAbsoluteTime) renderTime
{
   struct mulle_pointerarrayenumerator   rover;
   CALayer                               *layer;

#ifdef RENDER_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   [_mainLayer animateWithAbsoluteTime:renderTime];
   
   rover = mulle_pointerarray_enumerate_nil( _layers);
   while( layer = mulle_pointerarrayenumerator_next( &rover))
      [layer animateWithAbsoluteTime:renderTime];
   mulle_pointerarrayenumerator_done( &rover);
}


- (void) animateSubviewsWithAbsoluteTime:(CAAbsoluteTime) renderTime
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;

#ifdef RENDER_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   rover = mulle_pointerarray_enumerate_nil( _subviews);
   while( view = mulle_pointerarrayenumerator_next( &rover))
      [view animateWithAbsoluteTime:renderTime];
   mulle_pointerarrayenumerator_done( &rover);
}


- (void) animateWithAbsoluteTime:(CAAbsoluteTime) renderTime
{
   [self animateLayersWithAbsoluteTime:renderTime];
   [self animateSubviewsWithAbsoluteTime:renderTime];
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
      //fprintf( stderr, "window found\n");
      return( (UIWindow *) view);
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

   image = [context textureImageWithSize:renderInfo.framebufferSize
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
                                              userInfo:(id) userInfo 
{
   struct MulleTrackingArea   *tracking;
   UIWindow                  *window;

   if( MulleTrackingAreaArrayGetCount( &_trackingAreas) == 0)
   {
      // if window does not exist, then a late add would not be noticed
      // and tracking fails... 
      window = [self window];
      assert( window);
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



// https://developer.apple.com/documentation/uikit/uiview/1622625-sizethatfits?language=objc
- (CGSize) sizeThatFits:(CGSize) size
{
   return( [_mainLayer frame].size);
}

# pragma mark - 

- (void) startLayoutWithFrameInfo:(struct MulleFrameInfo *) info
{
   [UIView beginAnimations:NULL
                   context:NULL];

   // linear is better for animations that are restarted often,
   // like during a resize
   [UIView setAnimationCurve:UIViewAnimationCurveLinear];

   // if this is too small, it looks more like a glitch than a wanted effect
   // e.g. 0.05 too small
   [UIView setAnimationDuration:0.20];
}


- (void) endLayout
{
   [UIView commitAnimations];
}

- (void) layoutIfNeeded 
{
   // run layout if necessary (right place here ?)
   if( [self needsLayout])
   {
      [self setNeedsLayout:NO];
      [self layoutSubviews];
      assert( ! [self needsLayout]);
   }
}


- (void) layoutSubviewsIfNeeded
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;

   [self layoutIfNeeded];

   rover = mulle_pointerarray_enumerate_nil( _subviews);
   while( view = mulle_pointerarrayenumerator_next( &rover))
      [view layoutSubviewsIfNeeded];
   mulle_pointerarrayenumerator_done( &rover);
}


@end
