//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local MulleTextLayer over one in import.h
#ifdef __has_include
# if __has_include( "MulleTextLayer.h")
#  import "MulleTextLayer.h"
# endif
#endif

// we wan't "import.h" always anyway
#import "import.h"

/*
 * The cursor is moving along the row information in 
 * and _rowGlyphs[ y].glyphs[ x]. Each _rowGlyphs has a sentinel glyph,
 * for the end of line.
 */
@interface MulleTextLayer( Cursor)

- (CGFloat) scrollOffsetToMakeCursorVisible;
- (void) drawCursorWithNVGContext:(NVGcontext *) vg
                              row:(NSUInteger) i;

// point is within bounds
- (struct MulleIntegerPoint) cursorPositionForPoint:(CGPoint) point;
- (NSUInteger) characterIndexForCursor:(struct MulleIntegerPoint) cursor;

// point is within bounds
- (void) setCursorPositionToPoint:(CGPoint) point;

- (struct MulleIntegerPoint) maxCursorPosition;

/*
 * keyboard support here for now
 */
- (void) insertCharacter:(unichar) c;
- (void) backspaceCharacter;

@end

