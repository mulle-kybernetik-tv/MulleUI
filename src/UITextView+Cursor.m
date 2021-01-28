//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UITextView+Cursor.h"

#import "import-private.h"

#import "CGGeometry.h"
#import "CALayer.h"
#import "MulleTextLayer+Cursor.h"


@implementation UITextView ( Cursor)

- (void) getCursorPosition:(struct MulleIntegerPoint *) p_cursor
{
   *p_cursor = _cursorPosition;
}


- (CALayer *) layerAtCursor
{
   CALayer < MulleCursor>     *layer;
   struct MulleIntegerPoint   cursor;

   [self getCursorPosition:&cursor];
   layer  = [self layerAtRow:cursor.y];
   return( layer);
}


- (CGFloat) offsetNeededToMakeCursorVisible
{
   CALayer <MulleCursor>   *layer;
   CGFloat                  offset;

   layer  = [self layerAtCursor];
   if(! layer)
      return( 0.0);

   offset = [layer offsetNeededToMakeCursorVisible];
   return( offset);
}


- (NSUInteger) characterIndexForCursor:(struct MulleIntegerPoint) cursor
{
   CALayer < MulleCursor>           *layer;
   struct MulleTextLayerRowGlyphs   *p;
   NVGglyphPosition                 *glyph;
   struct MulleIntegerPoint         max;
   NSUInteger                       index;
   NSUInteger                       i;

   index = 0;
   for( i = 0; i < cursor.y; i++)
   {
      layer = (id) [self layerAtRow:i];
      if( ! layer)
         return( NSNotFound);

      // TODO: can likely be written much much better
      max    = [layer maxCursorPosition];
      max.y  = 0;
      index += [layer characterIndexForCursor:max];
   }

   layer = [self layerAtRow:cursor.y];
   if( ! layer)
      return( NSNotFound);

   cursor.y = 0;
   index += [layer characterIndexForCursor:cursor];
   return( index);
}


- (struct MulleIntegerPoint) cursorPositionForPoint:(CGPoint) mouseLocation
{
   CALayer <MulleCursor>      *layer;
   NSUInteger                 row;
   struct MulleIntegerPoint   cursor;
   CGRect                     frame;
   CGRect                     layerFrame;
   CGPoint                    point;

   layer = (id) [self layerAtPoint:mouseLocation];
   if( ! layer)
      return( MulleIntegerPointMake( -1, -1));

   frame      = [self frame];
   layerFrame = [layer frame];
   point.x    = mouseLocation.x;
   point.y    = mouseLocation.y - (layerFrame.origin.y - frame.origin.y);

   cursor   = [layer cursorPositionForPoint:point];
   if( cursor.x == -1)
      return( MulleIntegerPointMake( -1, -1));

   row      = [self rowOfLayer:layer];
   cursor.y += row;

   return( cursor);
}


- (void) setCursorPositionToPoint:(CGPoint) mouseLocation
{
   struct MulleIntegerPoint   cursor;

   cursor = [self cursorPositionForPoint:mouseLocation];
   if( cursor.x == -1)
      return;

   [self setCursorPosition:cursor];
}


- (struct MulleIntegerPoint) maxCursorPosition
{
   CALayer <MulleCursor>     *layer;
   CGFloat                    offset;
   struct MulleIntegerPoint   cursor;
   struct MulleIntegerPoint   max;
   NSUInteger                 n;

   n = mulle_pointerarray_get_count( _layers);
   if( ! n)
      return( MulleIntegerPointMake( NSNotFound, NSNotFound));

   cursor.y = n - 1;

   // finde momentanen textLayer und ruf dann
   // offsetNeededToMakeCursorVisible darauf auf
   layer = [self layerAtRow:cursor.y];
   if( ! layer)
      return( MulleIntegerPointMake( NSNotFound, NSNotFound));

   max      = [layer maxCursorPosition];
   cursor.x = max.x;
   return( cursor);
}


- (void) insertCharacter:(unichar) c
{
   CALayer <MulleCursor>      *layer;
   char                       *s;
   struct MulleIntegerPoint   cursor;
   struct MulleIntegerPoint   next;
   NSUInteger                 pos;

   layer  = (id) [self layerAtCursor];

   [self getCursorPosition:&cursor];
   [layer insertCharacter:c];
   [layer getCursorPosition:&next];

   cursor.x = next.x;
   [self setCursorPosition:cursor];
}




// cursor position is in Unicode characters...
- (void) backspaceCharacter
{
   CALayer <MulleCursor>      *layer;
   char                       *s;
   struct MulleIntegerPoint   cursor;
   struct MulleIntegerPoint   next;
   NSUInteger                 pos;

   layer  = (id) [self layerAtCursor];

   [self getCursorPosition:&cursor];
   [layer backspaceCharacter];
   [layer getCursorPosition:&next];

   cursor.x = next.x;
   [self setCursorPosition:cursor];
}


- (void) enterOrReturn
{
   CALayer <MulleCursor>      *layer;
   char                       *s;
   struct MulleIntegerPoint   cursor;
   struct MulleIntegerPoint   max;
   struct MulleCursorUTF8Data split;
   NSData                     *data1;
   NSData                     *data2;

   [self getCursorPosition:&cursor];
   //
   // split line if in middle
   //
   if( cursor.x == 0)
   {
      // TODO: wrong! need to add internal scroll offset
      [_textStorage insertObject:[NSData data]
                         atIndex:cursor.y];
      cursor.y++;
   }
   else
   {
      layer = (id) [self layerAtCursor];
      max   = [layer maxCursorPosition];
      if( cursor.x >= max.x)
      {
         cursor.x = 0;
         cursor.y++;
         [_textStorage insertObject:[NSData data]
                            atIndex:cursor.y];
      }
      else
      {
         // split lines
         split = [(MulleTextLayer *) layer cursorUTF8Data];
         data1 = [NSData dataWithCData:mulle_utf8data_as_data( split.dataUpToCursor)];
         data2 = [NSData dataWithCData:mulle_utf8data_as_data( split.dataAfterCursor)];
         [_textStorage replaceObjectAtIndex:cursor.y
                                 withObject:data1];
         [_textStorage insertObject:data2
                            atIndex:cursor.y + 1];
         cursor.x = 0;
         cursor.y++;
      }
   }

   [self reflectTextStorage];
   [self setCursorPosition:cursor];
}



// For fonts that are not mono-spaced, the expected user experience is
// to have the cursor hit the nearest character in terms of pixels
// e.g. assume 'X' is twice the width of 'i'
//    iiiiiii         iiiiii|i
//    XXX|XXX  -> UP  XXXXXXXX


- (void) cursorUp
{
   struct MulleIntegerPoint   pos;
   struct MulleIntegerPoint   max;
   CALayer <MulleCursor>      *layer;
   CALayer <MulleCursor>      *other;
   NSUInteger                 row;
   CGPoint                    point;

   [self getCursorPosition:&pos];

   fprintf( stderr, "read cursor: %lu/%lu\n", (long) pos.x, (long) pos.y);

   layer    = [self layerAtCursor];
   row      = [self rowOfLayer:layer];
   pos.y   -= row;
   point    = [(MulleTextLayer *) layer pointOverCursorPosition:pos];
   other    = [self layerAtRow:row - 1];
   if( other)
   {
      pos   = [other cursorPositionForPoint:point];
      pos.y = row - 1;
      [self setCursorPosition:pos];
   }
}


- (void) cursorDown
{
   struct MulleIntegerPoint   pos;
   struct MulleIntegerPoint   max;
   CALayer <MulleCursor>      *layer;
   CALayer <MulleCursor>      *other;
   NSUInteger                 row;
   CGPoint                    point;

   [self getCursorPosition:&pos];

   fprintf( stderr, "read cursor: %lu/%lu\n", (long) pos.x, (long) pos.y);

   layer    = [self layerAtCursor];
   row      = [self rowOfLayer:layer];
   pos.y   -= row;
   point    = [(MulleTextLayer *) layer pointUnderCursorPosition:pos];
   other    = [self layerAtRow:row + 1];
   if( other)
   {
      pos   = [other cursorPositionForPoint:point];
      pos.y = row + 1;
      [self setCursorPosition:pos];
   }
}


- (void) cursorLeft
{
   struct MulleIntegerPoint   pos;
   struct MulleIntegerPoint   max;
   CALayer <MulleCursor>      *layer;

   [self getCursorPosition:&pos];

   fprintf( stderr, "read cursor: %lu/%lu\n", (long) pos.x, (long) pos.y);

   --pos.x;
   if( (NSInteger) pos.x < 0)
   {
      // move to end of previous line
      layer = [self layerAtRow:pos.y - 1];
      if( ! layer)
         pos.x = 0;
      else
      {
         max = [layer maxCursorPosition];
         pos.x = max.x;
         --pos.y;
      }
   }

   [self setCursorPosition:pos];
}


- (void) cursorRight
{
   struct MulleIntegerPoint   pos;
   struct MulleIntegerPoint   max;
   CALayer <MulleCursor>      *layer;

   [self getCursorPosition:&pos];

   fprintf( stderr, "read cursor: %lu/%lu\n", (long) pos.x, (long) pos.y);

   pos.x++;
   max = [self maxCursorPosition];
   if( pos.x > max.x)
   {
      // move to beginning of next line
      layer = [self layerAtRow:pos.y + 1];
      if( ! layer)
         pos.x = max.x;
      else
      {
         pos.x = 0;
         ++pos.y;
      }
   }
   [self setCursorPosition:pos];
}

@end
