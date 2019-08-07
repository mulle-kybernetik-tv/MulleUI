#define NANOVG_GLES2_IMPLEMENTATION	// Use GL2 implementation.

#import "import-private.h"

#import "CGContext.h"

#import "CGFont.h"
#import "CGGeometry+CString.h"
#import "MulleBitmapImage.h"


// #define USE_ANONYMOUS_PRO


#ifdef USE_ANONYMOUS_PRO
# include "anonymous-pro.inc"
# define FONT_DATA   Anonymous_Pro_ttf
#else
# include "Roboto-Regular.inc"
# define FONT_DATA   Roboto_Regular_ttf
#endif
#include "entypo.inc"


@implementation CGContext 

- (id) init
{
	_vg  = nvgCreateGLES2( NVG_ANTIALIAS | NVG_STENCIL_STROKES);
   if( ! _vg)
   {  
      [self release];
      return( nil);
   }

	initGraph( &_perf.fps, GRAPH_RENDER_FPS, "Frame Time");
	initGraph( &_perf.cpuGraph, GRAPH_RENDER_MS, "CPU Time");
	initGraph( &_perf.gpuGraph, GRAPH_RENDER_MS, "GPU Time");
   initGraph( &_perf.memGraph, GRAPH_RENDER_PERCENT, "GPU Memory");

   _perf.cpuTime = -1.0;

   return( self);
}


- (struct NVGcontext *) nvgContext
{
   return( _vg);
}


- (void) dealloc
{
	nvgDeleteGLES2( _vg);
   [super dealloc];
}

- (void) clearFramebuffer
{
   glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
   glClear( GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
}


#define GL_GPU_MEM_INFO_TOTAL_AVAILABLE_MEM_NVX   0x9048
#define GL_GPU_MEM_INFO_CURRENT_AVAILABLE_MEM_NVX 0x9049


- (void) startRenderToFrame:(CGRect) frame
                  frameInfo:(struct MulleFrameInfo *) info
{
   double   t;
   GLint    value;

//   assert( info);
   _currentFrameInfo = *info;

   // > performance measurement
   if( _perf.cpuTime == -1.0)
   {
      initGPUTimer( &_perf.gpuTimer);
	   glfwSetTime( 0);
	   _perf.prevt = glfwGetTime();   
   }
   t           = glfwGetTime();
   _perf.dt    = t - _perf.prevt;
   _perf.prevt = t;

   startGPUTimer( &_perf.gpuTimer);

   // < performance measurement  

   if( ! CGSizeEqualToSize( frame.size, info->framebufferSize) ||
       ! CGSizeEqualToSize( frame.size, info->windowSize) ||
       ! CGSizeEqualToSize( info->framebufferSize, info->windowSize))
      fprintf( stderr, "Frame: %s, FB: %s, Window: %s\n",
               CGSizeCStringDescription( frame.size),
               CGSizeCStringDescription( info->framebufferSize),
               CGSizeCStringDescription( info->windowSize));
            
   glViewport(0, 0, frame.size.width, frame.size.height);

   nvgBeginFrame( _vg, frame.size.width, 
                       frame.size.height, 
                       info->pixelRatio);
   nvgResetTransform( _vg);
   nvgScissor( _vg, 0.0, 0.0, frame.size.width, frame.size.height);
}


- (CGFloat) fontScale
{
   return( _currentFrameInfo.UIScale.dx * 1.35); // Still true ????
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
   // render code want sans, so load it
   font  = [self fontWithName:"sans"];

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
   y += 35 + 2;
   renderGraph( _vg, 5,y, &_perf.memGraph);
   // < display performance values for previous frame   
   nvgEndFrame( _vg);

   // > get performance values for current frame
   _perf.cpuTime = glfwGetTime() - _perf.prevt;
   updateGraph(&_perf.fps, _perf.dt);
   updateGraph(&_perf.cpuGraph, _perf.cpuTime);

   total = 0;
   glGetIntegerv(GL_GPU_MEM_INFO_TOTAL_AVAILABLE_MEM_NVX, &total);   
   unused = 0;
   glGetIntegerv(GL_GPU_MEM_INFO_CURRENT_AVAILABLE_MEM_NVX, &unused);   
   if( total)
      updateGraph(&_perf.memGraph, unused * 100.0 / total);

   // We may get multiple results.
   n = stopGPUTimer(&_perf.gpuTimer, gpuTimes, 3);
   for (i = 0; i < n; i++)
	   updateGraph(&_perf.gpuGraph, gpuTimes[i]);

   // < get performance values for prcurrentevious frame
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
- (int) textureIDForImage:(UIImage *) image
{
   int   textureId;

   mulle_int_size   size;

   if( [image isKindOfClass:[MulleBitmapImage class]])
   {
      size      = [(MulleBitmapImage *) image intSize];
      textureId = nvgCreateImageRGBA( _vg, size.width, size.height, 0, [(MulleBitmapImage *) image bytes]);
      // fprintf( stderr, "textureid: %d\n", textureId);
      return( textureId);
   }
   return( -1);
}


@end
