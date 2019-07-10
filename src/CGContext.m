#define NANOVG_GLES2_IMPLEMENTATION	// Use GL2 implementation.

#import "import-private.h"

#import "CGContext.h"
#include "CGGeometry+CString.h"


#define RENDER_DEBUG

@implementation CGContext 

- (id) init
{
	_vg  = nvgCreateGLES2( NVG_ANTIALIAS | NVG_STENCIL_STROKES);
   if( ! _vg)
   {  
      [self release];
      return( nil);
   }

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


- (void) startRenderToFramebufferSize:(CGSize) framebufferSize
                           windowSize:(CGSize) windowSize
                                scale:(CGVector) scale

{
#ifdef RENDER_DEBUG
   fprintf( stderr, "%s %s (f:%s w:%s s:%s)\n", 
                        __PRETTY_FUNCTION__, 
                        [self cStringDescription],
                        CGSizeCStringDescription( framebufferSize),
                        CGSizeCStringDescription( windowSize),
                        CGVectorCStringDescription( scale));
#endif
//   if( _renderWithNewContext)
//   {
//      nvgDeleteGLES2( _vg);
//      _vg  = nvgCreateGLES2( NVG_ANTIALIAS | NVG_STENCIL_STROKES);
//      _renderWithNewContext = NO;  
//   }

   glViewport( 0, 0, framebufferSize.width, framebufferSize.height); // important, otherwise the resize is wonky

   nvgBeginFrame( _vg, framebufferSize.width, 
                       framebufferSize.height, 
                       framebufferSize.width / windowSize.width * scale.dx);  
   nvgResetTransform( _vg);
   nvgScissor( _vg, 0.0, 0.0, framebufferSize.width, framebufferSize.height);
}


- (void) resetTransform
{
   nvgResetTransform( _vg);
}


- (void) endRender
{
   nvgEndFrame( _vg);
}

@end