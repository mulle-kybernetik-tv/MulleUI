#define NANOVG_GLES2_IMPLEMENTATION	// Use GL2 implementation.

#import "import-private.h"

#import "CGContext.h"

#import "CGFont.h"

#include "Roboto-Regular.inc"
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


//
// TODO: use hash table to keep track of names and avoid duplicate loads of
//       fonts
//
- (CGFont *) fontWithName:(char *) s
{
   if( ! strcmp( s, "sans"))
      return( [CGFont fontWithName:s
                             bytes:Roboto_Regular_ttf
                            length:sizeof( Roboto_Regular_ttf)
                           context:self]);
   if( ! strcmp( s, "icons"))
      return( [CGFont fontWithName:s
                             bytes:entypo_ttf
                            length:sizeof( entypo_ttf)
                           context:self]);
   abort();
}

@end