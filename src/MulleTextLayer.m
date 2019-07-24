#import "MulleTextLayer.h"

#import "CGContext.h"
#import "CGFont.h"


@implementation MulleTextLayer : CALayer


/* MEMO: Font/Glyph scaling
 *
 * Truetype is a font format (we just care about truetype fonts)
 * Freetype is a font library that reads truetype fonts.
 *
 * Freetype has no dependency on opengl. Freetype returns a glyph either as a
 * vector or a bitmap (possibly rasterized from a vector font). We just care
 * about vector fonts though.
 *
 * This bitmap is transferred to a font atlas, basically a mega-texture.
 * This is done in the fons__ stuff. Confusingly, there is also an atlas in
 * nvg. But it does not seem to be used, at least as long as the fons__
 * stuff supplies glyphs ?
 *
 * Size conversion: A freetype/truetye  vector font has a height, that's fixed at 2048.
 * this is distributed to an ascender and a descender. So ascender - descender = 2048.
 * (Actually <= 2048, but we ignore that for now) https://www.freetype.org/freetype2/docs/tutorial/step2.html
 * `fons__tt_getPixelHeightScale` for example is defined as ` size / (font->font->ascender - font->font->descender)`
 * so basically `size / 2048`.
 *
 * The texture you get from freetype is upside down. So a d actually looks like a q (sort of).
 *
 * The pipe glyph has a vertical overshoot of one pixel for Anonymous Pro.
 *
 * Even if you request LCD from a freetype front, you may get monochrome
 * instead. The fontstash library will correct this.
 *
 * By experiment, if running cleartype it makes no use to turn of cleartype
 * for monochrome or grayscale only fonts.
 *
 * Since emojis could be used from a fallback font, it maybe necessary to 
 * split the string for multiple nvgText calls, setting the correct font
 * everytime.
 */

- (void) drawContentsInContext:(CGContext *) context
{
   struct NVGcontext   *vg;
   CGRect              frame;
   CGFont              *font;
   CGFloat             fontPixelSize;
   char                *name;
   float               bounds[ 4];
   CGSize              extents;

   font  = [context fontWithName:_fontName ? _fontName : "sans"];
   name  = [font name];  // get actual name, which could have different address
   frame = [self frame];

   fontPixelSize = [self fontPixelSize];
   if( fontPixelSize == 0.0)
      fontPixelSize = (int) frame.size.height;

   vg = [context nvgContext];
   nvgFontSize( vg, fontPixelSize);
   nvgFontFace( vg, name);
   nvgTextColor( vg, [self textColor], [self backgroundColor]); // TODO: use textColor

   nvgTextAlign( vg, NVG_ALIGN_LEFT|NVG_ALIGN_MIDDLE);
   nvgTextBounds( vg, 0.0, 0.0, _cString, NULL, bounds);

   extents.width  = bounds[ 2] - bounds[ 0];
   extents.height = bounds[ 3] - bounds[ 1];

   nvgText( vg, frame.origin.x + (frame.size.width - extents.width) / 2.0, frame.origin.y + frame.size.height * 0.5f, _cString, NULL);
}

@end
