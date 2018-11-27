#define NANOVG_GLES2_IMPLEMENTATION	// Use GL2 implementation.

#import "import-private.h"

#import "CGContext.h"


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
   nvgBeginFrame( _vg, frame.size.width, 
                       frame.size.height, 
                       frame.size.width / frame.size.height);
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