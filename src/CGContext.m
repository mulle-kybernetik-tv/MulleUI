#define DEFINE_NANOVG_GL_IMPLEMENTATION

#import "import-private.h"

#import "CGContext.h"
#import "CGContext+CGFont.h"
#import "CGGeometry+CString.h"
#import "UIImage.h"
#import "MulleBitmapImage.h"
#import "MulleTextureImage.h"
#include <stdio.h>



#define HAVE_MEM_GRAPH

// #define RENDER_DEBUG

@implementation CGContext

- (void) _initPerformanceCounters
{
	initGraph( &_perf.fps,      GRAPH_RENDER_FPS, "Frame Time");
	initGraph( &_perf.cpuGraph, GRAPH_RENDER_MS, "CPU Time");
	initGraph( &_perf.gpuGraph, GRAPH_RENDER_MS, "GPU Time");
#ifdef HAVE_MEM_GRAPH
   initGraph( &_perf.memGraph, GRAPH_RENDER_PERCENT, "GPU Memory");
#endif
   _perf.cpuTime = -1.0;
}

/*
static void   assert_shader_compiler_errors( GLuint shader)
{
   GLint    success;
   GLchar   infoLog[1024];

   glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
   if( ! success)
   {
      glGetShaderInfoLog( shader, 1024, NULL, infoLog);
      fprintf( stderr, "ERROR::SHADER_COMPILATION_ERROR: %s\n", infoLog);
      abort();
   }
}

// stolen from : https://learnopengl.com/code_viewer_gh.php?code=src/4.advanced_opengl/9.2.geometry_shader_exploding/9.2.geometry_shader.gs
static char  geometryShaderSource[] =
"#version 330 core\n"
"layout (triangles) in;\n"
"layout (triangle_strip, max_vertices = 3) out;\n"
"\n"
"in VS_OUT {\n"
"    vec2 texCoords;\n"
"} gs_in[];\n"
"\n"
"out vec2 TexCoords;\n"
"\n"
"uniform float time;\n"
"\n"
"vec4 explode(vec4 position, vec3 normal)\n"
"{\n"
"    float magnitude = 2.0;\n"
"    vec3 direction = normal * ((sin(time) + 1.0) / 2.0) * magnitude;\n"
"    return position + vec4(direction, 0.0);\n"
"}\n"
"\n"
"vec3 GetNormal()\n"
"{\n"
"    vec3 a = vec3(gl_in[0].gl_Position) - vec3(gl_in[1].gl_Position);\n"
"    vec3 b = vec3(gl_in[2].gl_Position) - vec3(gl_in[1].gl_Position);\n"
"    return normalize(cross(a, b));\n"
"}\n"
"\n"
"void main() {\n"
"    vec3 normal = GetNormal();\n"
"\n"
"    gl_Position = explode(gl_in[0].gl_Position, normal);\n"
"    TexCoords = gs_in[0].texCoords;\n"
"    EmitVertex();\n"
"    gl_Position = explode(gl_in[1].gl_Position, normal);\n"
"    TexCoords = gs_in[1].texCoords;\n"
"    EmitVertex();\n"
"    gl_Position = explode(gl_in[2].gl_Position, normal);\n"
"    TexCoords = gs_in[2].texCoords;\n"
"    EmitVertex();\n"
"    EndPrimitive();\n"
"}\n"
;
*/

- (id) init
{
#ifdef NANOVG_GL3_IMPLEMENTATION
	_vg  = nvgCreateGL3( NVG_ANTIALIAS | NVG_STENCIL_STROKES
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
	_vg  = nvgCreateGLES2( NVG_ANTIALIAS | NVG_STENCIL_STROKES
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
	_vg  = nvgCreateGLES3( NVG_ANTIALIAS | NVG_STENCIL_STROKES
#endif
#if DEBUG
   | NVG_DEBUG
#endif
   );

   if( ! _vg)
   {
      [self release];
      return( nil);
   }

/*
#if MULLE_UI_GLVERSION != MULLE_GLES2
   {
      struct GLNVGcontext   *vgl = (struct GLNVGcontext *) _vg;
      unsigned int          program;
      unsigned int          geometryShader;
      char                  *str[ 2];
	   static char           *shaderHeader = ""
#ifdef NANOVG_GL2_IMPLEMENTATION
#elif defined( NANOVG_GL3_IMPLEMENTATION)
		"#version 330 core\n"
#elif defined( NANOVG_GLES2_IMPLEMENTATION)
		"#version 100\n"
#elif defined( NANOVG_GLES3_IMPLEMENTATION)
		"#version 300 es\n"
#endif
      ;

      program        = vgl->shader.prog;
      geometryShader = glCreateShader (GL_GEOMETRY_SHADER);
      str[ 0] = shaderHeader;
      str[ 1] = geometryShaderSource;
      glShaderSource( geometryShader, 1, str, NULL);
      glCompileShader( geometryShader);
      assert_shader_compiler_errors( geometryShader);
      glAttachShader( program, geometryShader);
      glLinkProgram( program);
      glDeleteShader( geometryShader);     // release basically
   }
#endif
*/
   [self _initPerformanceCounters];
   [self _initFontCache];

   return( self);
}


- (struct NVGcontext *) nvgContext
{
   return( _vg);
}


- (void) dealloc
{
   [self _doneFontCache];

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
   CGFloat   rgba[ 4];

   MulleColorGetComponents( _backgroundColor, rgba);
   glClearColor( rgba[ 0], rgba[ 1], rgba[ 2], rgba[ 3]);
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

#if RENDER_DEBUG
   if( ! CGSizeEqualToSize( info->frame.size, info->framebufferSize) ||
       ! CGSizeEqualToSize( info->frame.size, info->windowSize) ||
       ! CGSizeEqualToSize( info->framebufferSize, info->windowSize))
      fprintf( stderr, "Frame: %s, FB: %s, Window: %s\n",
               CGSizeCStringDescription( info->frame.size),
               CGSizeCStringDescription( info->framebufferSize),
               CGSizeCStringDescription( info->windowSize));
#endif
   _renderStartTimestamp = CAAbsoluteTimeNow();
   if( _renderStartTimestamp == 0.0)
      _firstRenderStartTimestamp = _renderStartTimestamp;

   // > performance measurement
   if( _currentFrameInfo.isPerfEnabled)
   {
      if( _perf.cpuTime == -1.0)
      {
         _perf.cpuTime = 0.0;

         initGPUTimer( &_perf.gpuTimer);
   	   _perf.prevt = _renderStartTimestamp;

         // render code want sans, so load it (now once)
         [self fontWithNameCString:"sans"];
      }

      t           = _renderStartTimestamp;
      _perf.dt    = t - _perf.prevt;
      _perf.prevt = t;

      startGPUTimer( &_perf.gpuTimer);
   }
   // < performance measurement
   glViewport( 0, 0, info->frame.size.width, info->frame.size.height);
   nvgBeginFrame( _vg, info->frame.size.width,
                       info->frame.size.height,
                       info->pixelRatio);
   _isRendering = YES;
   _alpha       = 1.0;

   nvgResetTransform( _vg);
   nvgScissor( _vg, 0.0, 0.0, info->frame.size.width, info->frame.size.height);

/*
#if MULLE_UI_GLVERSION != MULLE_GLES2
   {
      struct GLNVGcontext   *vgl = (struct GLNVGcontext *) _vg;
      unsigned int          program;
      GLfloat               matrix[ 4][ 4];

      program = vgl->shader.prog;
      glUniform1f( glGetUniformLocation( program, "time", glfwGetTime());
   }
#endif
*/
}


- (CAAbsoluteTime) renderStartTimestamp
{
   return(_renderStartTimestamp);
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
	float            gpuTimes[3];
   int              i;
   int              n;
   GLint            total;
   GLint            unused;
   int              y;
   BOOL             perfEnabled;
   CAAbsoluteTime   now;

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
      now = CAAbsoluteTimeNow();

      // > get performance values for current frame
      _perf.cpuTime = now - _perf.prevt;
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

   allocator = MulleObjCInstanceGetAllocator( self);
   if( ! _images)
      _images = mulle__pointermap_create( 16, 0, allocator);

   size      = [(MulleBitmapImage *) image intSize];
   textureId = nvgCreateImageRGBA( _vg,
                                   size.width,
                                   size.height,
                                   [image nvgImageFlags],
                                   [(MulleBitmapImage *) image bytes]);
//   fprintf( stderr, "textureid: %d\n", textureId);

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

   _mulle__pointermap_remove( _images, image, MulleObjCInstanceGetAllocator( self));
}


- (MulleTextureImage *) framebufferImageWithBitmapSize:(struct mulle_bitmap_size) size
                                               options:(NSUInteger) options
{
   MulleTextureImage   *image;

   image = [[[MulleTextureImage alloc] initWithBitmapSize:size
                                                  context:self
                                                  options:options] autorelease];
   if( ! image)
      return( nil);

   // images are not retained!
   if( ! _framebufferImages)
      _framebufferImages = mulle_pointerarray_create( NULL);
   _mulle_pointerarray_add( _framebufferImages, image);

   return( image);
}


- (void) removeFramebufferImage:(UIImage *) image
{
   intptr_t   index;

   if( ! _framebufferImages)
      return;

   index = _mulle_pointerarray_find( _framebufferImages, image);
   if( index == mulle_not_found_e)
      return;

   _mulle_pointerarray_set( _framebufferImages, index, NULL);
}


- (void) _unmapImages
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
      // we just remove the textureIDs and wipeout the mapping
      textureId = (int) (intptr_t) pair->value;
      nvgDeleteImage( _vg, textureId);
   }
   mulle__pointermapenumerator_done( &rover);

   _mulle__pointermap_destroy( _images, MulleObjCInstanceGetAllocator( self));
   _images = NULL;
}


- (void) _finalizeFramebufferImages
{
   struct mulle_pointerarrayenumerator  rover;
   UIImage                             *image;

   if( ! _framebufferImages)
      return;

   rover = mulle_pointerarray_enumerate( _framebufferImages);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &image))
   {
      // call finalize on these as they are effectively dead now
      [image finalize];
   }
   mulle_pointerarrayenumerator_done( &rover);

   mulle_pointerarray_destroy( _framebufferImages);
   _framebufferImages = NULL;
}


- (void) finalize
{
   assert( ! _isRendering);

   [self _resetFontCache];
   [self _unmapImages];
   [self _finalizeFramebufferImages];

   [super finalize];
}

@end
