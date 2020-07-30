#import "MulleTextLayer.h"

#import "CGContext.h"
#import "CGFont.h"


@implementation MulleTextLayer : CALayer

- (void) setFontName:(char *) s
{
   MulleObjCObjectSetDuplicatedCString( self, &_fontName, s);
}


- (void) setCString:(char *) s
{
   MulleObjCObjectSetDuplicatedCString( self, &_cString, s);
}


- (void) dealloc 
{
   MulleObjCObjectDeallocateMemory( self, _fontName);
   MulleObjCObjectDeallocateMemory( self, _cString);

   [super dealloc]; 
}


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
 * The texture you get from freetype is upside down. So a d actually looks
 * like a q (sort of).
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

- (BOOL) drawContentsInContext:(CGContext *) context
{
   struct NVGcontext   *vg;
   CGRect              frame;
   CGFont              *font;
   CGFloat             fontPixelSize;
   char                *name;
   float               bounds[ 4];
   CGSize              extents;
   CGColorRef          color;
	float               lineh;
   CGPoint             cursor;
   CGPoint             offset;

   // nothing to draw ? then bail
   if( ! _cString || ! *_cString)
      return( NO);

   font  = [context fontWithName:_fontName ? _fontName : "sans"];
   name  = [font name];  // get actual name, which could have different address
   frame = [self frame];

   fontPixelSize = [self fontPixelSize];
   if( fontPixelSize == 0.0)
      fontPixelSize = (int) frame.size.height;

   vg = [context nvgContext];

   nvgFontSize( vg, fontPixelSize);
   nvgFontFace( vg, name);

   color = [self backgroundColor];
   if( CGColorGetAlpha( color) < 1.0)
      color = [self textBackgroundColor];
   nvgTextColor( vg, [self textColor], color); // TODO: use textColor

   // TODO: use textalign property
   nvgTextAlign( vg, NVG_ALIGN_LEFT|NVG_ALIGN_MIDDLE);

   // don't render outside of myself
   //   nvgIntersectScissor( vg, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

	// The text break API can be used to fill a large buffer of rows,
	// or to iterate over the text just few lines (or just one) at a time.
	// The "next" variable of the last returned item tells where to continue.

	_nRows = nvgTextBreakLines( vg, _cString, NULL, frame.size.width, &_row, 1);
   if( _nRows)
   {
	   nvgTextMetrics(vg, NULL, NULL, &_lineh);

      nvgTextBounds( vg, 0.0, 0.0, _row.start, _row.end, bounds);

      extents.width  = bounds[ 2] - bounds[ 0];
      extents.height = bounds[ 3] - bounds[ 1];

      _cursor.x = (frame.size.width - extents.width) / 2.0;
      _cursor.y = frame.size.height * 0.5f;

      nvgText( vg, frame.origin.x + _cursor.x, frame.origin.y + _cursor.y, _row.start, _row.end);
		if( [self isEditable])
      {
         // TODO: make this dynamic in size
			_nGlyphs = nvgTextGlyphPositions( vg, 0, 0, _row.start, _row.end, _glyphs, 100);
         assert( _nGlyphs < 100 - 1);
         // put in a node at the sentinel position
         _glyphs[ _nGlyphs].x = _row.width;

         // ''   nglyphs == 0, _cursorPositon=={ 0 - 0 }
         // 'A'  nglyphs == 1, _cursorPositon=={ 0 - 1 }  |A or A|
         // 'AB' nglyphs == 2, _cursorPositon=={ 0 - 2 }  |AB or A|B or AB|

         if( _cursorPosition > _nGlyphs)
            _cursorPosition = _nGlyphs;

         offset.x = _glyphs[ _cursorPosition].x;
         offset.y = -(_lineh / 2); // depends on alignment, really, use middle here
            
			nvgBeginPath( vg);
			nvgFillColor( vg, nvgRGBA(255,0,0,255));
			nvgRect( vg, 
                  frame.origin.x + _cursor.x + offset.x - 0.5, 
                  frame.origin.y + _cursor.y + offset.y, 1, 
                  _lineh);
			nvgFill( vg);
		}
	}
   return( NO);
}


- (void) setCursorPositionToPoint:(CGPoint) point 
{
   CGRect       rect;
   NSUInteger   i;

   for( i = 0; i < _nGlyphs; i++)
   {
      rect.origin.x    = _glyphs[ i].x + _cursor.x;
      rect.origin.y    = _cursor.y - (_lineh / 2);
      rect.size.width  = _glyphs[ i + 1].x - _glyphs[ i].x;  // sentinel! node is OK!
      rect.size.height = _lineh;

      if( CGRectContainsPoint( rect, point))
      {
         _cursorPosition = i;
         rect.size.width  /= 2.0;  // sentinel! node is OK!
         if( ! CGRectContainsPoint( rect, point))
            _cursorPosition++;
         break;
      }
   }
}

@end
