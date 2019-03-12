#define NANOVG_GLES2_IMPLEMENTATION	// Use GL2 implementation.

#import "import-private.h"

#import "CGContext.h"


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


- (void) startRenderToFrame:(CGRect) frame
{
#ifdef RENDER_DEBUG
   fprintf( stderr, "%s %s (f:%s)\n", 
                        __PRETTY_FUNCTION__, 
                        [self cStringDescription],
                        CGRectCStringDescription( frame));
#endif
//   if( _renderWithNewContext)
//   {
//      nvgDeleteGLES2( _vg);
//      _vg  = nvgCreateGLES2( NVG_ANTIALIAS | NVG_STENCIL_STROKES);
//      _renderWithNewContext = NO;  
//   }
   nvgBeginFrame( _vg, frame.size.width, 
                       frame.size.height, 
                       frame.size.width / frame.size.height);
   nvgResetTransform( _vg);
   nvgScissor( _vg, 0.0, 0.0, frame.size.width, frame.size.height);
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