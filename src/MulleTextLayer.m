#import "MulleTextLayer.h"

#import "CGContext.h"
#import "CGFont.h"


@implementation MulleTextLayer : CALayer

- (void) drawContentsInContext:(CGContext *) context
{
   struct NVGcontext   *vg;
   CGRect              frame;
   CGFont              *font;
   CGFloat             fontSize;
   char                *name;

   font = [context fontWithName:_fontName ? _fontName : "sans"];
   name = [font name];  // get actual name, which could have different address

   fontSize = [self fontSize];
   if( fontSize == 0.0)
      fontSize = 10.0;

   vg = [context nvgContext];
	nvgFontSize( vg, fontSize);
	nvgFontFace( vg, name);
	nvgFillColor( vg, nvgRGBA(255,255,255,255)); // TODO: use textColor

   frame = [self frame];
	nvgTextAlign( vg,NVG_ALIGN_LEFT|NVG_ALIGN_MIDDLE);
	nvgText( vg, frame.origin.x, frame.origin.y + frame.size.height *0.5f, _cString, NULL);
}

@end
