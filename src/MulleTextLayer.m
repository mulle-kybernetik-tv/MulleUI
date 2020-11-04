#import "MulleTextLayer.h"

#import "MulleTextLayer+Cursor.h"
#import "MulleTextLayer+Selection.h"

#import "CGContext.h"
#import "CGContext+CGFont.h"
#import "CGGeometry+CString.h"
#import "CGFont.h"


@implementation MulleTextLayer : CALayer

- (void) setFontName:(char *) s
{
   MulleObjCObjectSetDuplicatedCString( self, &_fontName, s);
}

- (enum MulleTextLayerVerticalAlignmentMode)  mulleVerticalAlignmentMode
{
   return( _verticalAlignmentMode);
}

- (void) mulleSetVerticalAlignmentMode:(enum MulleTextLayerVerticalAlignmentMode) mode
{
   _verticalAlignmentMode = mode;
}

#if 0
static NSUInteger  count_newlines( mulle_utf8_t *s)
{
   mulle_utf32_t    c;
   mulle_utf32_t    d;
   NSUInteger       lf;

   // use code from nvg
   c  = 0;
   lf = 0;
   for(;*s;)
   {
      d = c;
      c = mulle_utf8_next_utf32character( &s);
      switch( c) 
      {
      case '\n':		
          if( d != '\r')
            ++lf;
         break;

      case 0x85:		
      case '\r':		
         ++lf;
         break;
      }
   } 
   return( lf);
}
#endif

- (void) setCString:(char *) s
{
   if( ! s)
      s = "";

#if 0
#ifdef NDEBUG   
   struct mulle_utf_information   info;   
   // must be valid UTF8
   mulle_utf8_information( s, -1, &info);
   if( ! mulle_utf_information_is_valid( info))
      abort();
#endif
   _newlinesInCString = count_newlines( s);
#endif
   MulleObjCObjectSetDuplicatedCString( self, &_cString, s);
   _cStringEnd = &_cString[ strlen( _cString)];
}


- (id) init
{
   [super init];

   _mulle_structarray_init( &_rowArray, sizeof( NVGtextRow),
                                        alignof( NVGtextRow),
                                        0,
                                        MulleObjCInstanceGetAllocator( self));
   _mulle_structarray_init( &_rowGlyphArray, sizeof( struct MulleTextLayerRowGlyphs),
                                             alignof( struct MulleTextLayerRowGlyphs),
                                             0,
                                             MulleObjCInstanceGetAllocator( self));
   return( self);
}


- (void) dealloc 
{
   _mulle_structarray_done( &_rowGlyphArray);
   _mulle_structarray_done( &_rowArray);

   MulleObjCObjectDeallocateMemory( self, _fontName);
   MulleObjCObjectDeallocateMemory( self, _cString);

   [super dealloc]; 
}

- (void) getCursorPosition:(struct MulleIntegerPoint *) cursor_p
{
   *cursor_p = _cursorPosition;
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
- (void) resizeRowsTo:(NSUInteger) max
{
   NSUInteger   n;
   NSUInteger   diff;
   NSUInteger   size;

   size  = _mulle_structarray_get_size( &_rowArray);
   if( max > size)
   {
      diff = max - size;
      _mulle_structarray_advance( &_rowArray, max);
   }
   // 
   _rows  = _mulle_structarray_get( &_rowArray, 0);
   _nRows = 0;
}


- (void) resizeRowGlyphsArrayTo:(NSUInteger) max
{
   NSUInteger                       size;
   NSUInteger                       diff;
   struct MulleTextLayerRowGlyphs   *p;
   struct MulleTextLayerRowGlyphs   *sentinel;

   //
   // The contents of _rowGlyphArray will be reused, as they contain
   // other mulle_structarrays.
   //
   size = _mulle_structarray_get_size( &_rowGlyphArray);
   if( max > size)
   {
      diff     = max - size;
      p        = _mulle_structarray_advance( &_rowGlyphArray, diff);
      sentinel = &p[ diff];
      while( p < sentinel)
      {
         _MulleTextLayerRowGlyphsInit( p, MulleObjCInstanceGetAllocator( self));
         ++p;
      }
   }
   _rowGlyphs = _mulle_structarray_get( &_rowGlyphArray, 0);
}


NSUInteger  
   MulleNVGglyphPositionSearch( NVGglyphPosition *glyphs,
                                NSUInteger nGlyphs, 
                                CGFloat x)
{
   NSInteger          first;
   NSInteger          last;
   NSInteger          middle;
   NVGglyphPosition   *p;

   first  = 0;
   last   = (NSInteger) nGlyphs - 1;   // unsigned not good (need extra if)
   middle = (first + last) / 2;

   while( first <= last)
   {
      p = &glyphs[ middle];
      if( x >= p->minx && x <= p->maxx)
         return( middle);
        
      if( x > p->minx)
      {
         first = middle + 1;
      }
      else
         last = middle - 1;

      middle = (first + last) / 2;
   }

   return( NSNotFound);
}


- (void) updateRowGlyphsAtIndex:(NSUInteger) i
                        context:(NVGcontext *) vg
{
   NSUInteger                       nGlyphs;
   NSUInteger                       newSize;
   NSUInteger                       diff;
   NSUInteger                       sGlyphs;
   NSUInteger                       n;
   struct MulleTextLayerRowGlyphs   *p;

   p       = &_rowGlyphs[ i];
   nGlyphs = 100 / 2; // start with assumed 100 glyphs for each row

   // our assumed size, the buffer should be larger than this, so we can
   // figure out if we get truncated due to small a buffer also we need
   // one extra space for the sentinel node
   do
   {
      sGlyphs = _mulle_structarray_get_size( &p->glyphArray);
      if( sGlyphs <= nGlyphs + 1) // add sentinel node
      {
         newSize = nGlyphs + nGlyphs;
         if( newSize < 100)
            newSize = 100;
         diff     = newSize - sGlyphs;
         _mulle_structarray_advance( &p->glyphArray, diff);
         p->glyphs = _mulle_structarray_get( &p->glyphArray, 0);
         sGlyphs   = newSize;
      }

      p->nGlyphs = nvgTextGlyphPositions( vg, 0, 0, 
                                              _rows[ i].start, _rows[ i].end, 
                                              p->glyphs, sGlyphs);
   }
   while( p->nGlyphs >= sGlyphs - 1);  // subtract sentinel node

   // put in a node at the sentinel position
   if( p->nGlyphs)
      p->glyphs[ p->nGlyphs].x = p->glyphs[ p->nGlyphs - 1].maxx;
   else
      p->glyphs[ p->nGlyphs].x = 0;

   p->glyphs[ p->nGlyphs].minx = 0;
   p->glyphs[ p->nGlyphs].maxx = 0;
   p->glyphs[ p->nGlyphs].str  = _rows[ i].end;
   // ''   nglyphs == 0, _cursorPositon=={ 0 - 0 }
   // 'A'  nglyphs == 1, _cursorPositon=={ 0 - 1 }  |A or A|
   // 'AB' nglyphs == 2, _cursorPositon=={ 0 - 2 }  |AB or A|B or AB|
}


- (void) updateRowsAndGlyphsWithContext:(NVGcontext *) vg
{
   NSUInteger   max;
   NSUInteger   i;
   CGFloat      width;
   CGFloat      extent;
   float        bounds[ 4];

   // calculate max visible rows, which is frame.size.height / _lineh , but 
   // because of partials we add + 2

   max = (NSUInteger) ceil( _frame.size.height / _lineh) + 2;

   // produce row information 
   switch( _lineBreakMode)
   {
   case NSLineBreakByWordWrapping :
      // the width can produce more lines, we assume worst case
      // we have a string of "max" number of linefeeds, followed by
      // a last line as one large string without linefeed
      // We will have to divide this by width to get the extra lengths
      // also when word wrapping how big can the biggest word be ?

      width   = _frame.size.width;
      extent  = nvgTextBounds( vg, 0, 0, _cString, _cStringEnd, bounds);
      // TODO check this is true, probably need to fuzz it
      max    += ceil( extent / width) + 1;
      break;

   default :
      width = INFINITY;
      break;
   }

   [self resizeRowsTo:max];
   [self resizeRowGlyphsArrayTo:max];

   //
   // Calculate actual amount of rows available
   // Here the problem is, that we always calculate from the start though
   // which doesn't work well for middle/bottom...
   //
   _nRows = nvgTextBreakLines( vg, _cString, _cStringEnd, width, _rows, max);
   // produce glyph information for each row
   for( i = 0; i < _nRows; i++)
      [self updateRowGlyphsAtIndex:i
                           context:vg];
}


// textOffset in CGPoint
//  1.) figure out how
- (BOOL) drawContentsInContext:(CGContext *) context
{
   struct NVGcontext   *vg;
   float               lineh;
   CGColorRef          textBackgroundColor;
   CGFloat             fontPixelSize;
   CGFloat             rowsHeight;
   CGFont              *font;
   CGPoint             cursor;
   CGPoint             offset;
   CGRect              frame;
   char                *name;
   int                 align;
   NSRange             selectionRange;
   NSRange             textRange;
   NSUInteger          i;

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
   nvgTextMetrics( vg, NULL, NULL, &_lineh);

   [self updateRowsAndGlyphsWithContext:vg];

   // now we know the number of rows,
   // calculate the height of all rows
   rowsHeight = _lineh * _nRows;

   _origin.x = _origin.x + _textOffset.x - frame.origin.x;

   // If cursor is visible, keep it always visible
   if( [self isEditable])
      _origin.x += [self scrollOffsetToMakeCursorVisible];
 
   // set as top aligned
   switch( _verticalAlignmentMode)
   {
   case MulleTextVerticalAlignmentTop :
      _origin.y = _lineh / 2 + _textOffset.y;
      break;
      // set as bottom aligned
   case MulleTextVerticalAlignmentBottom :
      _origin.y = frame.size.height - rowsHeight + _lineh / 2.0  + _textOffset.y;
      break;
      // set as center aligned
   case MulleTextVerticalAlignmentMiddle :
      _origin.y = (frame.size.height - rowsHeight) / 2.0 + (_lineh / 2.0) + _textOffset.y;
      break; 
   }

   for( i = 0; i < _nRows; i++)
   {
      textRange = NSMakeRange( _rows[ i].start - _cString, 
                               _rows[ i].end - _rows[ i].start);

      // Draw the first line only
      // don't render outside of myself
      nvgIntersectScissor( vg, frame.origin.x, 
                               frame.origin.y, 
                               frame.size.width, 
                               frame.size.height);
      nvgFillColor( vg, nvgRGBA(127,127,255,255));

      /*
       * Draw selection
       */
      [self drawSelectionWithNVGContext:vg
                              textRange:textRange
                                    row:i];
      /*
       * Draw Text
       * Bug: textBackgroundColor should be selection color if selected
       */
      textBackgroundColor = [self backgroundColor];
      if( CGColorGetAlpha( textBackgroundColor) < 1.0)
         textBackgroundColor = [self textBackgroundColor];
      nvgTextColor( vg, [self textColor], textBackgroundColor); // TODO: use textColor
      nvgText( vg, frame.origin.x + _origin.x, 
                   frame.origin.y + _origin.y + (i * _lineh), 
                   _rows[ i].start, 
                   _rows[ i].end);
      /*
       * Draw Cursor
       */
      if( [self isEditable])
         [self drawCursorWithNVGContext:vg
                                    row:i];
   }
   return( NO);
}


static size_t   mulle_utf8_utf32length( mulle_utf8_t *s, size_t len)
{
   mulle_utf8_t   *start;
   mulle_utf8_t   *sentinel;
   size_t          n;

   start    = s;
   sentinel = &s[ len];

   n = 0;
   while( s < sentinel)
   {
      mulle_utf8_next_utf32character( &s);
      ++n;
   }
   return( n);
}


// point is within bounds
// we find the range in the cstring 8bit characters we do not
// interpret UTF8
//
- (NSUInteger) characterIndexForPoint:(CGPoint) point
{
   CGRect                           rect;
   NSInteger                        y;
   NSUInteger                       x;
   CGFloat                          search;
   struct MulleTextLayerRowGlyphs   *p;

   if( ! _nRows)
      return( NSNotFound);

   // figure out the row that was hit, a row is _lineh and 
   // drawn at frame.origin.y + _origin.y  + i *_lineh
   y = (NSInteger) round( (point.y -_origin.y) / _lineh);
   if( y < 0)
      y = 0;
   else
      if( y >= _nRows)
         y = _nRows - 1;

   p = &_rowGlyphs[ y];
   // calculate characters up till till this


   search  = point.x;
   search -= _origin.x;

   x = MulleNVGglyphPositionSearch( p->glyphs, p->nGlyphs, search);
   if( x == NSNotFound)
   {
      if( search >= p->glyphs[ p->nGlyphs].x - 0.5)
         x = p->nGlyphs;
      else
         x = 0;
   }
   else
   {
      // left side/right side (use third, matter of taste)
      if( search >= p->glyphs[ x].minx + (p->glyphs[ x].maxx - p->glyphs[ x].minx) / 3.0)
         x++;
   }
   return( p->glyphs[ x].str - _cString);  
}


@end
