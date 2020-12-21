//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MulleTextLayer+Cursor.h"

#import "import-private.h"

#import "CGGeometry.h"


@implementation MulleTextLayer ( Cursor)

- (void) getCursorPosition:(struct MulleIntegerPoint *) p_cursor 
{
   *p_cursor = _cursorPosition;
}


- (void) drawCursorWithNVGContext:(NVGcontext *) vg
                              row:(NSUInteger) i
{
   CGRect                           frame;
   struct MulleTextLayerRowGlyphs   *p;
   NSUInteger                       x;
   CGPoint                          offset;

   if( MulleIntegerPointGetRow( _cursorPosition) != i)
      return;

   frame = [self frame];
         
   // get glyphs
   p = &_rowGlyphs[ i];
   x = MulleIntegerPointGetColumn( _cursorPosition);
   if( x <= p->nGlyphs)
   {
      offset.x = p->glyphs[ x].x;
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

- (CGFloat) offsetNeededToMakeCursorVisible
{
   CGPoint                          offset;
   CGRect                           bounds;
   CGFloat                          min;
   CGFloat                          diff;
   NVGglyphPosition                 *glyph;
   struct MulleTextLayerRowGlyphs   *p;

   if( _cursorPosition.y >= _nRows)
      return( 0.0);

   p = &_rowGlyphs[ _cursorPosition.y];
   if( _cursorPosition.x > p->nGlyphs)
      return( 0.0);   

   // get glyphs
   glyph    = &p->glyphs[ _cursorPosition.x];

   offset.x = _origin.x + glyph->x - 0.5;
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


- (NSUInteger) characterIndexForCursor:(struct MulleIntegerPoint) cursor 
{
   struct MulleTextLayerRowGlyphs   *p;
   NVGglyphPosition                 *glyph;

   if( cursor.y >= _nRows)
      return( NSNotFound);

   p = &_rowGlyphs[ cursor.y];
   if( cursor.x > p->nGlyphs)
      return( NSNotFound);   
   glyph = &p->glyphs[ cursor.x];
   return( glyph->str - (char *) _data.characters);
}


- (CGPoint) pointOverCursorPosition:(struct MulleIntegerPoint) cursor
{
   struct MulleTextLayerRowGlyphs   *p;

   if( cursor.y < 0 || cursor.y >= _nRows)
      return( CGPointMake( -1, -1));

   p = &_rowGlyphs[ cursor.y];
   if( cursor.x < 0 || cursor.x > p->nGlyphs)
      return( CGPointMake( -1, -1));

   return( CGPointMake( _origin.x + p->glyphs[ cursor.x].x, 
                        _origin.y - 1.0));
}


- (CGPoint) pointUnderCursorPosition:(struct MulleIntegerPoint) cursor
{
   struct MulleTextLayerRowGlyphs   *p;
   CGFloat                          h;

   if( cursor.y < 0 || cursor.y >= _nRows)
      return( CGPointMake( -1, -1));

   p = &_rowGlyphs[ cursor.y];
   if( cursor.x < 0 || cursor.x > p->nGlyphs)
      return( CGPointMake( -1, -1));

   return( CGPointMake( _origin.x + p->glyphs[ cursor.x].x, 
                        _origin.y + 0.0));
}



- (struct MulleIntegerPoint) cursorPositionForPoint:(CGPoint) point
{
   CGFloat                          search;
   CGRect                           rect;
   NSInteger                        x;
   NSInteger                        y;
   struct MulleIntegerPoint         cursor;
   struct MulleTextLayerRowGlyphs   *p;

   // figure out the row that was hit, a row is _lineh and 
   // drawn at frame.origin.y + _origin.y  + i *_lineh
   y = (NSInteger) round( (point.y -_origin.y) / _lineh);
   if( y < 0 || y >= _nRows)
   {
      y = NSNotFound;
      return( MulleIntegerPointMake( NSNotFound, NSNotFound));
   }

   p = &_rowGlyphs[ y];
   // calculate characters up till till this

   // TODO: binary search anyone ?
   search = point.x - _origin.x;
   for( x = 0; x < p->nGlyphs; x++)
   {
      if( search >= p->glyphs[ x].x && search < p->glyphs[ x + 1].x)
      {
         // check if hitting left or right side
         if( search >= p->glyphs[ x].x + (p->glyphs[ x + 1].x - p->glyphs[ x].x) / 2)
            x++;
         cursor.x = x;           
         cursor.y = y;
         return( cursor);
      }
   }
   return( MulleIntegerPointMake( NSNotFound, NSNotFound));
}


// point is within bounds
- (void) setCursorPositionToPoint:(CGPoint) point 
{
   NSUInteger                 i;
   struct MulleIntegerPoint   cursor;

   cursor = [self cursorPositionForPoint:point];
   if( cursor.x == NSNotFound)
      return;

   [self setCursorPosition:cursor];
}


- (void) setCursorPosition:(struct MulleIntegerPoint) point
{
   NSLog( @"cursor: %lu/%lu", (long) point.x, (long) point.y);
   _cursorPosition = point;
}


- (struct MulleIntegerPoint) maxCursorPosition
{
   unsigned char  *p;
   NSUInteger     x;
   NSUInteger     y;

   if( ! _nRows)
      return( MulleIntegerPointMake( NSNotFound, NSNotFound));

   y = _nRows - 1;
   x = _rowGlyphs[ y].nGlyphs;
   if( ! x)
      return( MulleIntegerPointMake( NSNotFound, NSNotFound));
   return( MulleIntegerPointMake( x, y));
}


- (void) insertCharacter:(unichar) c
{
   char                       *s;
   struct MulleIntegerPoint   cursorPosition;
   NSUInteger                 pos;

   [self getCursorPosition:&cursorPosition];
   pos = [self characterIndexForCursor:cursorPosition];
   if( pos == NSNotFound)
      return;

   s = [self cString];
   s = MulleObjC_asprintf( "%.*s%C%s", 
               (int) pos, 
               s, 
               c, 
               &s[ pos]);
   [self setCString:s];

   // naive!! need to consider line breaks
   cursorPosition.x++;
   [self setCursorPosition:cursorPosition];
}

- (void) enterOrReturn 
{
   // don't talk to a delegate, you are a layer!
}

// cursor position is in Unicode characters...
- (void) backspaceCharacter
{
   char                       *s;
   struct MulleIntegerPoint   cursorPosition;
   NSUInteger                 pos1;
   NSUInteger                 pos2;

   [self getCursorPosition:&cursorPosition];
   if( cursorPosition.x == NSNotFound)
      return;

   pos2           = [self characterIndexForCursor:cursorPosition];
   --cursorPosition.x; // need to move line up if hitting 0
   pos1           = [self characterIndexForCursor:cursorPosition];

   s              = [self cString];
   s = MulleObjC_asprintf( "%.*s%s", (int) pos1, s, &s[ pos2]);
   [self setCString:s];
   [self setCursorPosition:cursorPosition];
}


- (struct MulleCursorUTF8Data) cursorUTF8Data
{
   struct MulleCursorUTF8Data  info;
   NSUInteger                  offset;
   struct MulleIntegerPoint    cursorPosition;

   [self getCursorPosition:&cursorPosition];
   offset = [self characterIndexForCursor:cursorPosition]; 

   info.dataUpToCursor  = mulle_utf8data_make( _data.characters, offset);
   info.dataAfterCursor = mulle_utf8data_make( &_data.characters[ offset], _data.length);
   return( info);
}


@end
