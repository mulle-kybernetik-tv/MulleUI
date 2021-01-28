//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// we want "import.h" always anyway
#import "import.h"

@class UIEvent;

#ifdef __has_include
# if __has_include( "MulleCursorProtocol.h")
#  import "MulleCursorProtocol.h"
# endif
#endif

// The MulleKeyboardEventConsumer manages keyboard events, 
// like copy/paste and cursor movement. It's pretty much the same for 
// UITextField or UITextView in an abstract kind of way.
//
PROTOCOLCLASS_INTERFACE( MulleKeyboardEventConsumer, NSObject)

- (struct MulleIntegerPoint) maxCursorPosition;

// could also be a property with a respective #define, but its tricky as 
// the implementor might also get it from MulleCursor

- (void) setCursorPosition:(struct MulleIntegerPoint) pos;
- (struct MulleIntegerPoint) cursorPosition;
- (void) getCursorPosition:(struct MulleIntegerPoint *) pos;

- (void) backspaceCharacter;
- (void) cut;
- (void) copy;
- (void) paste;
- (void) enterOrReturn;

// the protocolclass implements this. Forward your keyDown: event to it if
// your view isn't a "subclass" of UIControl
@optional
- (UIEvent *) consumeKeyDown:(UIEvent *) event;


- (void) cursorUp;
- (void) cursorDown;
- (void) cursorLeft;
- (void) cursorRight;

PROTOCOLCLASS_END();

