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
- (CGFloat) scrollOffsetToMakeCursorVisible
{
   CGPoint   offset;
   CGRect    bounds;
   CGFloat   min;
   CGFloat   diff;

   if( _cursorPosition > _nGlyphs)
      return( 0.0);

   offset.x = _origin.x + _glyphs[ _cursorPosition].x - 0.5;
   bounds   = [self bounds];
   min      = bounds.size.width * 10.0 / 100.0;

   diff = (CGRectGetMinX( bounds) + min) - offset.x;
   if( diff > 0)
      return( diff);
   diff = offset.x - (CGRectGetMaxX( bounds) - min);
   if( diff > 0)
      return( -diff);
   return( 0.0);
}


- (void) updateRowsAndGlyphsWithContext:(NVGcontext *) vg
{
	_nRows = nvgTextBreakLines( vg, _cString, NULL, INFINITY, &_row, 1);

   // TODO: make this dynamic in size, should cache this and wipe if
   //       string changes
   //       also dependend on text alignment and font changes!
	_nGlyphs = nvgTextGlyphPositions( vg, 0, 0, _row.start, _row.end, _glyphs, 100);
   assert( _nGlyphs < 100 - 1);

   // put in a node at the sentinel position
   _glyphs[ _nGlyphs].x = _nGlyphs ? _glyphs[ _nGlyphs - 1].maxx : 0;

   // ''   nglyphs == 0, _cursorPositon=={ 0 - 0 }
   // 'A'  nglyphs == 1, _cursorPositon=={ 0 - 1 }  |A or A|
   // 'AB' nglyphs == 2, _cursorPositon=={ 0 - 2 }  |AB or A|B or AB|
}


- (void) drawSelectionWithNVGContext:(NVGcontext *) vg
                               range:(NSRange) selectionRange
                            textRange:(NSRange) textRange
{
   NSInteger    leftCharacters;
   float        xyxy[ 4];
   CGRect       frame;


   frame = [self frame];

   // draw background for selection, compute area by removing
   // unselected characters
   // "a[iiii]a"

  
   leftCharacters = selectionRange.location - textRange.location;

   switch( _alignmentMode)
   {
   case CAAlignmentLeft   :
      {
         float   offset;

         // 1) get number of characters to the left of selection
         //    then get the offset in pixels
         nvgTextBounds( vg, frame.origin.x + _origin.x, 
                            frame.origin.y + _origin.y, 
                            _row.start, 
                            &_row.start[ leftCharacters], 
                            xyxy);  
         offset = xyxy[ 2];  
                      
         nvgTextBounds( vg, offset,
                      frame.origin.y + _origin.y, 
                      &_row.start[ leftCharacters], 
                      &_row.start[ leftCharacters + selectionRange.length], 
                      xyxy);
         break;       
      } 

   case CAAlignmentRight  : 
      {
         NSUInteger   rightOffset;
         NSUInteger   rightCharacters;
         float        offset;
            // abcdef   0,5  1,3  > 4, 2 ef
         rightOffset     = selectionRange.location + selectionRange.length;
         rightCharacters = textRange.length - rightOffset;
         nvgTextBounds( vg, frame.origin.x + _origin.x, 
                            0, 
                            &_row.start[ rightOffset], 
                            &_row.start[ rightOffset + rightCharacters], 
                            xyxy);  
         offset = xyxy[ 0];  
           
          // 2) get offset and width of characters of the selection
         nvgTextBounds( vg, offset,
                            frame.origin.y + _origin.y, 
                            &_row.start[ leftCharacters], 
                            &_row.start[ leftCharacters + selectionRange.length], 
                            xyxy);                       
         break;
      } 

   case CAAlignmentCenter : 
      {
         float    offset;
         float    width;

         nvgTextBounds( vg, 0, 
                            0, 
                            _row.start, 
                            &_row.start[ leftCharacters], 
                            xyxy);  
         offset = xyxy[ 2] - xyxy[ 0];
         nvgTextBounds( vg, 0,
                            0, 
                            &_row.start[ leftCharacters], 
                            &_row.start[ leftCharacters + selectionRange.length], 
                            xyxy);
         width = xyxy[ 2] - xyxy[ 0];

         nvgTextBounds( vg, frame.origin.x + _origin.x,
                            frame.origin.y + _origin.y, 
                            _row.start,
                            _row.end,
                            xyxy);
         xyxy[ 0] += offset;
         xyxy[ 2]  = xyxy[ 0] + width;
      }
   }         
            
	nvgFillColor( vg, nvgRGBA(127,255,127,255));
	nvgBeginPath( vg);
   nvgRect( vg, xyxy[ 0], 
                xyxy[ 1], 
                xyxy[ 2] - xyxy[ 0], 
                _lineh); 
	nvgFill( vg);  
}


// textOffset in CGPoint
//  1.) figure out how
- (BOOL) drawContentsInContext:(CGContext *) context
{
   struct NVGcontext   *vg;
   CGRect              frame;
   CGFont              *font;
   CGFloat             fontPixelSize;
   char                *name;
   CGColorRef          textBackgroundColor;
	float               lineh;
   CGPoint             cursor;
   CGPoint             offset;
   NSRange             textRange;
   NSRange             selectionRange;
   int                 align;

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

   //
   // The alignment is needed first because it changes the origin
   // and also affects the nvg text calculations
   //
   align = NVG_ALIGN_MIDDLE;
   switch( _alignmentMode)
   {
   case CAAlignmentLeft   : align |= NVG_ALIGN_LEFT; 
                            _origin.x = CGRectGetMinX( frame); 
                            break;
   case CAAlignmentRight  : align |= NVG_ALIGN_RIGHT; 
                            _origin.x = CGRectGetMaxX( frame); 
                            break;
   case CAAlignmentCenter : align |= NVG_ALIGN_CENTER; 
                            _origin.x = CGRectGetMidX( frame); 
                            break;
   }
   nvgTextAlign( vg, align); 
   _origin.x = _origin.x + _textOffset.x - frame.origin.x;
   _origin.y = CGRectGetMidY( frame) +_textOffset.y - frame.origin.y;


	// The text break API can be used to fill a large buffer of rows,
	// or to iterate over the text just few lines (or just one) at a time.
	// The "next" variable of the last returned item tells where to continue.
   [self updateRowsAndGlyphsWithContext:vg];

   // If cursor is visible, keep it always visible
	if( [self isEditable])
   {
      // TODO: could' animate this, not necessarily with CAAnimation
      //       this is not affecting the _textOffset but just the actual
      //       drawing (not sure if this is useful or not)
      _origin.x += [self scrollOffsetToMakeCursorVisible];
   }
   textRange      = NSMakeRange( _row.start - _cString, _row.end - _row.start);
   selectionRange = NSIntersectionRange( textRange, _selection);

   // Draw the first line only
   if( _nRows)
   {
      // don't render outside of myself
      nvgIntersectScissor( vg, frame.origin.x, 
                               frame.origin.y, 
                               frame.size.width, 
                               frame.size.height);
 	   nvgTextMetrics( vg, NULL, NULL, &_lineh);
		nvgFillColor( vg, nvgRGBA(127,127,255,255));

      /*
       * Draw selection
       */
      if( selectionRange.length)
         [self drawSelectionWithNVGContext:vg
                                     range:selectionRange
                                 textRange:textRange];

      /*
       * Draw Text
       */
      textBackgroundColor = [self backgroundColor];
      if( CGColorGetAlpha( textBackgroundColor) < 1.0)
         textBackgroundColor = [self textBackgroundColor];
      nvgTextColor( vg, [self textColor], textBackgroundColor); // TODO: use textColor
      nvgText( vg, frame.origin.x + _origin.x, 
                   frame.origin.y + _origin.y, 
                   _row.start, 
                   _row.end);

      /*
       * Draw Cursor
       */
   	if( [self isEditable])
      {
         // TODO: make sure we don't crash
         if( _cursorPosition <= _nGlyphs)
         {
            offset.x = _glyphs[ _cursorPosition].x;
            offset.y = -(_lineh / 2); // depends on alignment, really, use middle here
               
   			nvgBeginPath( vg);
   			nvgFillColor( vg, nvgRGBA(255,0,0,255));
   			nvgRect( vg, 
                     frame.origin.x + _origin.x + offset.x - 0.5, 
                     frame.origin.y + _origin.y + offset.y, 
                     1, 
                     _lineh);
   			nvgFill( vg);
   		}
      }
	}
   return( NO);
}


- (NSUInteger) characterIndexForPoint:(CGPoint) point
{
   CGRect       rect;
   NSUInteger   i;

   // TODO: binary search anyone ?
   for( i = 0; i < _nGlyphs; i++)
   {
      rect.origin.x    = _glyphs[ i].x + _origin.x;
      rect.origin.y    = _origin.y - (_lineh / 2);
      rect.size.width  = _glyphs[ i + 1].x - _glyphs[ i].x;  // sentinel! node is OK!
      rect.size.height = _lineh;

      fprintf( stderr, "*** %s %s\n",
               CGRectCStringDescription( rect),
               CGPointCStringDescription( point));
      if( CGRectContainsPoint( rect, point))
      {
         rect.size.width  /= 2.0;  // sentinel! node is OK!
         if( ! CGRectContainsPoint( rect, point))
            i++;
         return( i);
      }
   }
   return( NSNotFound);
}



- (void) setCursorPositionToPoint:(CGPoint) point 
{
   NSUInteger   i;

   i = [self characterIndexForPoint:point];
   if( i == NSNotFound)
      return;

   [self setCursorPosition:i];
   _selection      = NSMakeRange( i, 0);  // memorize start
   _startSelection = i;
}


// #1 When selecting left, one on the right of the actual 
//    cursor is being selected
// #2 When selecting right, there is no way to deselect all
// 

- (void) adjustSelectionToPoint:(CGPoint) point 
{
   NSUInteger   i;
   
   i = [self characterIndexForPoint:point];
   if( i == NSNotFound)
      return;

   // is cursor to the left ?
   if( i <= _startSelection)  
      _selection = NSMakeRange( i, _startSelection - i);
   else
      _selection = NSMakeRange( _startSelection, i - _startSelection);

   fprintf( stderr, "Selection: %.*s (%ld, %ld)\n", 
         (int) _selection.length, &_cString[ _selection.location],
         (long) _selection.location,
         (long) _selection.length);

   [self setCursorPosition:i];
}

@end
