// if you change this, also change the GLFW definition in include-private.h
//#define NANOVG_GL3_IMPLEMENTATION	// Use GL2 implementation.
#define NANOVG_GLES2_IMPLEMENTATION	// Use GL2 implementation.

#import "import-private.h"

#import "CGContext.h"
#include "CGGeometry+CString.h"

#import "CGFont.h"
#import "CGGeometry+CString.h"
#import "UIImage.h"
#import "MulleBitmapImage.h"
#import "MulleTextureImage.h"


// #define USE_ANONYMOUS_PRO


#ifdef USE_ANONYMOUS_PRO
# include "anonymous-pro.inc"
# define FONT_DATA   Anonymous_Pro_ttf
#else
# include "Roboto-Regular.inc"
# define FONT_DATA   Roboto_Regular_ttf
#endif
#include "entypo.inc"


#define HAVE_MEM_GRAPH

#define RENDER_DEBUG

@implementation CGContext

- (void) initPerformanceCounters
{
	initGraph( &_perf.fps,      GRAPH_RENDER_FPS, "Frame Time");
	initGraph( &_perf.cpuGraph, GRAPH_RENDER_MS, "CPU Time");
	initGraph( &_perf.gpuGraph, GRAPH_RENDER_MS, "GPU Time");
#ifdef HAVE_MEM_GRAPH
   initGraph( &_perf.memGraph, GRAPH_RENDER_PERCENT, "GPU Memory");
#endif
   _perf.cpuTime = -1.0;
}


- (id) init
{
#ifdef NANOVG_GL3_IMPLEMENTATION
	_vg  = nvgCreateGL3( NVG_ANTIALIAS | NVG_STENCIL_STROKES);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
	_vg  = nvgCreateGLES2( NVG_ANTIALIAS | NVG_STENCIL_STROKES);
#endif
   if( ! _vg)
   {
      [self release];
      return( nil);
   }

   [self initPerformanceCounters];
   return( self);
}


- (struct NVGcontext *) nvgContext
{
   return( _vg);
}

- (void) _freeImages
{
   struct mulle__pointermapenumerator  rover;
   struct mulle_pointerpair            *pair;
   UIImage                             *image;
   int                                 textureId;

   if( ! _images)
      return;

   rover = mulle__pointermap_enumerate( _images);
   while( (pair = _mulle__pointermapenumerator_next( &rover)))
   {
      image     = pair->_key;
      [image autorelease];
      textureId = (int) (intptr_t) pair->_value;
      nvgDeleteImage( _vg, textureId);
   }
   mulle__pointermapenumerator_done( &rover);

   _mulle__pointermap_destroy( _images, MulleObjCObjectGetAllocator( self));
   _images = NULL;
}

- (void) _freeFramebufferImages
{
   struct mulle_pointerarrayenumerator  rover;
   UIImage                             *image;

   rover = mulle_pointerarray_enumerate_nil( _framebufferImages);
   while( (image = _mulle_pointerarrayenumerator_next( &rover)))
      [image autorelease];
   mulle_pointerarrayenumerator_done( &rover);

   mulle_pointerarray_destroy( _framebufferImages);
   _framebufferImages = NULL;
}

- (void) finalize
{
   [self _freeImages];
   [self _freeFramebufferImages];
   [super finalize];
}


- (void) dealloc
{
#ifdef NANOVG_GL3_IMPLEMENTATION
	nvgDeleteGL3( _vg);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
	nvgDeleteGLES2(_vg);
#endif

   [super dealloc];
}

- (void) clearFramebuffer
{
   glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
   glClear( GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
}


#define GL_GPU_MEM_INFO_TOTAL_AVAILABLE_MEM_NVX   0x9048
#define GL_GPU_MEM_INFO_CURRENT_AVAILABLE_MEM_NVX 0x9049


- (void) startRenderWithFrameInfo:(struct MulleFrameInfo *) info
{
   double   t;
   GLint    value;

   assert( ! _isRendering);

   _currentFrameInfo = *info;

   // > performance measurement
   if( _currentFrameInfo.isPerfEnabled)
   {
      if( _perf.cpuTime == -1.0)
      {
         _perf.cpuTime = 0.0;

         initGPUTimer( &_perf.gpuTimer);
   	   glfwSetTime( 0);
   	   _perf.prevt = glfwGetTime();

         // render code want sans, so load it (now once)
         [self fontWithName:"sans"];
      }

      t           = glfwGetTime();
      _perf.dt    = t - _perf.prevt;
      _perf.prevt = t;

      startGPUTimer( &_perf.gpuTimer);
   }
   // < performance measurement

   if( ! CGSizeEqualToSize( info->frame.size, info->framebufferSize) ||
       ! CGSizeEqualToSize( info->frame.size, info->windowSize) ||
       ! CGSizeEqualToSize( info->framebufferSize, info->windowSize))
      fprintf( stderr, "Frame: %s, FB: %s, Window: %s\n",
               CGSizeCStringDescription( info->frame.size),
               CGSizeCStringDescription( info->framebufferSize),
               CGSizeCStringDescription( info->windowSize));

   _renderStartTimestamp = CAAbsoluteTimeNow();

   glViewport( 0, 0, info->frame.size.width, info->frame.size.height);
   nvgBeginFrame( _vg, info->frame.size.width,
                       info->frame.size.height,
                       info->pixelRatio);
   _isRendering = YES;
   _alpha       = 1.0;

   nvgResetTransform( _vg);
   nvgScissor( _vg, 0.0, 0.0, info->frame.size.width, info->frame.size.height);
}


- (CAAbsoluteTime) renderStartTimestamp
{
   return(_renderStartTimestamp);
}


- (CGFloat) fontScale
{
   return( _currentFrameInfo.UIScale.dx * 1.35); // Still true ????
}

- (struct MulleFrameInfo *) currentFrameInfo
{
   return( &_currentFrameInfo);
}


- (void) getCurrentFrameInfo:(struct MulleFrameInfo *) info
{
   assert( info);
   assert( _currentFrameInfo.pixelRatio);  // not yet initialized!!
   *info = _currentFrameInfo;
}


- (void) resetTransform
{
   nvgResetTransform( _vg);
}


- (void) endRender
{
	float   gpuTimes[3];
   int     i;
   int     n;
   CGFont  *font;
   GLint   total;
   GLint   unused;
   int     y;
   BOOL    perfEnabled;

   assert( _isRendering);
   perfEnabled = _currentFrameInfo.isPerfEnabled;
   if( perfEnabled)
   {
      // > display performance values for previous frame
      y = 5;
      renderGraph( _vg, 5,y, &_perf.fps);
      y += 35 + 2;
      renderGraph( _vg, 5, y, &_perf.cpuGraph);
      if( _perf.gpuTimer.supported)
      {
         y += 35 + 2;
         renderGraph( _vg, 5,y, &_perf.gpuGraph);
      }
#ifdef HAVE_MEM_GRAPH
      y += 35 + 2;
      renderGraph( _vg, 5,y, &_perf.memGraph);
#endif
      // < display performance values for previous frame
   }

   _isRendering = NO;
   nvgEndFrame( _vg);

   if( perfEnabled)
   {
      // > get performance values for current frame
      _perf.cpuTime = glfwGetTime() - _perf.prevt;
      updateGraph(&_perf.fps, _perf.dt);
      updateGraph(&_perf.cpuGraph, _perf.cpuTime);

#ifdef HAVE_MEM_GRAPH
      total = 0;
      glGetIntegerv(GL_GPU_MEM_INFO_TOTAL_AVAILABLE_MEM_NVX, &total);
      unused = 0;
      glGetIntegerv(GL_GPU_MEM_INFO_CURRENT_AVAILABLE_MEM_NVX, &unused);
      if( total)
         updateGraph(&_perf.memGraph, unused * 100.0 / total);
#endif

      // We may get multiple results.
      n = stopGPUTimer(&_perf.gpuTimer, gpuTimes, 3);
      for (i = 0; i < n; i++)
   	   updateGraph(&_perf.gpuGraph, gpuTimes[i]);

      // < get performance values for prcurrentevious frame
   }
}


//
// TODO: use hash table to keep track of names and avoid duplicate loads of
//       fonts
//
- (CGFont *) fontWithName:(char *) s
{
   if( ! strcmp( s, "sans"))
      return( [CGFont fontWithName:s
                             bytes:FONT_DATA
                            length:sizeof( FONT_DATA)
                           context:self]);
   if( ! strcmp( s, "icons"))
      return( [CGFont fontWithName:s
                             bytes:entypo_ttf
                            length:sizeof( entypo_ttf)
                           context:self]);
   abort();
}


// future, rasterize vector images to bitmaps here
- (int) registerTextureIDForImage:(UIImage *) image
{
   int                      textureId;
   mulle_int_size           size;
   void                     *value;
   struct mulle_allocator   *allocator;

   if( _images)
   {
      value = _mulle__pointermap_get( _images, image);
      if( value)
      {
         textureId = (int) (intptr_t) value;
   //      fprintf( stderr, "textureid: %d\n", textureId);
         return( textureId);
      }
   }

   if( ! [image isKindOfClass:[MulleBitmapImage class]])
   {
      abort();
      return( -1);
   }

   allocator = MulleObjCObjectGetAllocator( self);
   if( ! _images)
      _images = mulle__pointermap_create( 16, 0, allocator);

   size      = [(MulleBitmapImage *) image intSize];
   textureId = nvgCreateImageRGBA( _vg, size.width, size.height, 0, [(MulleBitmapImage *) image bytes]);
//   fprintf( stderr, "textureid: %d\n", textureId);

   [image retain];
   _mulle__pointermap_set( _images, image, (void *) (intptr_t) textureId, allocator);
   return( textureId);
}


- (void) unregisterTextureIDForImage:(UIImage *) image
{
   void   *value;
   int    textureId;

   assert( _images);

   value = _mulle__pointermap_get( _images, image);
   if( ! value)
      return;

   textureId = (int) (intptr_t) value;
   nvgDeleteImage( _vg, textureId);

   [image autorelease];
   _mulle__pointermap_remove( _images, image, MulleObjCObjectGetAllocator( self));
}


- (MulleTextureImage *) framebufferImageWithSize:(CGSize) size
                                         options:(NSUInteger) options
{
   MulleTextureImage   *image;

   image = [[[MulleTextureImage alloc] initWithSize:size
                                            options:options
                                            context:self] autorelease];
   if( ! image)
      return( nil);

   if( ! _framebufferImages)
      _framebufferImages = mulle_pointerarray_create_nil( NULL);

   [image retain];
   _mulle_pointerarray_add( _framebufferImages, image);
   return( image);
}


- (void) removeFramebufferImage:(UIImage *) image
{
   intptr_t   index;

   if( ! _framebufferImages)
      return;

   index = _mulle_pointerarray_find( _framebufferImages, image);
   if( index == -1)
      return;

   [image autorelease];
   _mulle_pointerarray_set( _framebufferImages, index, NULL);
}

@end
