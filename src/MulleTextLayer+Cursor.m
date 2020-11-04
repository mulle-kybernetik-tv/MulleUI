//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MulleTextLayer+Cursor.h"

#import "import-private.h"

#import "CGGeometry.h"


@implementation MulleTextLayer ( Cursor)

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

- (CGFloat) scrollOffsetToMakeCursorVisible
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
   return( glyph->str - _cString);
}


- (struct MulleIntegerPoint) cursorPositionForPoint:(CGPoint) point
{
   CGRect                           rect;
   struct MulleIntegerPoint         cursor;
   NSInteger                        x;
   NSInteger                        y;
   struct MulleTextLayerRowGlyphs   *p;
   CGFloat                          search;

   // figure out the row that was hit, a row is _lineh and 
   // drawn at frame.origin.y + _origin.y  + i *_lineh
   y = (NSInteger) round( (point.y -_origin.y) / _lineh);
   if( y < 0 || y > _nRows)
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

   cursorPosition = [self cursorPosition];
   pos            = [self characterIndexForCursor:cursorPosition];
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


// cursor position is in Unicode characters...
- (void) backspaceCharacter
{
   char                       *s;
   struct MulleIntegerPoint   cursorPosition;
   NSUInteger                 pos1;
   NSUInteger                 pos2;

   cursorPosition = [self cursorPosition];
   if( cursorPosition.x == NSNotFound)
      return;

   cursorPosition = [self cursorPosition];
   pos2           = [self characterIndexForCursor:cursorPosition];
   --cursorPosition.x; // need to move line up if hitting 0
   pos1           = [self characterIndexForCursor:cursorPosition];

   s              = [self cString];
   s = MulleObjC_asprintf( "%.*s%s", (int) pos1, s, &s[ pos2]);
   [self setCString:s];
   [self setCursorPosition:cursorPosition];
}

@end
