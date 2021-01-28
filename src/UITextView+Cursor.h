//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local MulleTextLayer over one in import.h
#ifdef __has_include
# if __has_include( "UITextView.h")
#  import "UITextView.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

/*
 * The cursor is moving along the row information in 
 * and _rowGlyphs[ y].glyphs[ x]. Each _rowGlyphs has a sentinel glyph,
 * for the end of line.
 */
@interface UITextView( Cursor) < MulleCursor>

- (CGFloat) offsetNeededToMakeCursorVisible;

// point is within bounds (cursorPositionOfPoint ?)
- (struct MulleIntegerPoint) cursorPositionForPoint:(CGPoint) point;
- (NSUInteger) characterIndexForCursor:(struct MulleIntegerPoint) cursor;

// point is within bounds
- (CGPoint) pointForCursorPosition:(struct MulleIntegerPoint) cursor;
- (void) setCursorPositionToPoint:(CGPoint) point;

- (struct MulleIntegerPoint) maxCursorPosition;

/*
 * keyboard support here for now
 */
- (void) insertCharacter:(unichar) c;
- (void) backspaceCharacter;

@end

