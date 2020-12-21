//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local MulleTextLayer over one in import.h
#ifdef __has_include
# if __has_include( "MulleTextLayer.h")
#  import "MulleTextLayer.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

/*
 * The cursor is moving along the row information in 
 * and _rowGlyphs[ y].glyphs[ x]. Each _rowGlyphs has a sentinel glyph,
 * for the end of line.
 */
struct MulleCursorUTF8Data
{
   struct mulle_utf8data    dataUpToCursor;
   struct mulle_utf8data    dataAfterCursor;
};


@interface MulleTextLayer( Cursor)

- (CGFloat) offsetNeededToMakeCursorVisible;
- (void) drawCursorWithNVGContext:(NVGcontext *) vg
                              row:(NSUInteger) i;

// point is within bounds
- (struct MulleIntegerPoint) cursorPositionForPoint:(CGPoint) point;
- (NSUInteger) characterIndexForCursor:(struct MulleIntegerPoint) cursor;

// point is in pixels starting from 0,0
- (CGPoint) pointOverCursorPosition:(struct MulleIntegerPoint) cursor;
- (CGPoint) pointUnderCursorPosition:(struct MulleIntegerPoint) cursor;

// point is within bounds
- (void) setCursorPositionToPoint:(CGPoint) point;

- (struct MulleIntegerPoint) maxCursorPosition;

/*
 * keyboard support here for now
 */
- (void) insertCharacter:(unichar) c;
- (void) backspaceCharacter;

- (struct MulleCursorUTF8Data) cursorUTF8Data;

@end

