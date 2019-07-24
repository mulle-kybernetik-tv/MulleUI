#define NANOVG_GLES2_IMPLEMENTATION	// Use GL2 implementation.

#import "import-private.h"

#import "CGContext.h"

#import "CGFont.h"


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
                  fontScale:(CGFloat) fontScale
{
   _fontScale = fontScale * 1.35;  // for Linux 1.35 is required

   nvgBeginFrame( _vg, frame.size.width, 
                       frame.size.height, 
                       1.0);
   nvgResetTransform( _vg);
   nvgScissor( _vg, 0.0, 0.0, frame.size.width, frame.size.height);
}

- (CGFloat) fontScale
{
   return( _fontScale);
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

@end