//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MulleKeyboardEventConsumer.h"

#import "import-private.h"

#ifdef __has_include
# if __has_include( "UIEvent.h")
#  import "UIEvent.h"
# endif
#endif
#ifdef __has_include
# if __has_include( "MulleIntegerPoint.h")
#  import "MulleIntegerPoint.h"
# endif
#endif

PROTOCOLCLASS_IMPLEMENTATION( MulleKeyboardEventConsumer)

- (void) cursorUp
{
}

- (void) cursorDown
{
}


- (void) cursorLeft
{
   struct MulleIntegerPoint   pos;
   struct MulleIntegerPoint   max;   

   [self getCursorPosition:&pos];

   fprintf( stderr, "read cursor: %lu/%lu\n", (long) pos.x, (long) pos.y);

   --pos.x;
   if( (NSInteger) pos.x < 0)
      pos.x = 0;

   [self setCursorPosition:pos];
}


- (void) cursorRight
{
   struct MulleIntegerPoint   pos;
   struct MulleIntegerPoint   max;

   [self getCursorPosition:&pos];

   fprintf( stderr, "read cursor: %lu/%lu\n", (long) pos.x, (long) pos.y);

   pos.x++;
   max = [self maxCursorPosition];
   if( pos.x > max.x)
      pos.x = max.x;
   [self setCursorPosition:pos];
}


//
// The key events are checked for special keys only, like backspace or
// cursor keys. (Or CTRL-A / CTRL-E). Actual text input is being taken
// though Unicode events
//
- (UIEvent *) consumeKeyDown:(UIEvent *) event
{
   UIKeyboardEvent   *keyEvent = (UIKeyboardEvent *) event;
   NSUInteger        key;
   NSUInteger        modifiers;

   fprintf( stderr, "key: %ld scanCode: %ld modifiers: %ld\n", 
                        (long) [keyEvent key], 
                        (long) [keyEvent scanCode],
                        (long) [keyEvent modifiers]);

   key       = [keyEvent key];
   modifiers = [keyEvent modifiers];
   switch( key)
   {
   default   :
      return( nil);

   // TODO: these should be global (MENU ?) events!!
   //       so actually pass the event back up
   case 'V'  :
      if( modifiers == 2) // 2  is CONTROL (linux)
         [self paste];
      return( nil);
   case 'C'  :
      if( modifiers == 2)
         [self copy];
      return( nil);
   case 'X'  :
      if( modifiers == 2)
         [self cut];
      return( nil);

   case 335  : // ENTER
   case 257  : // RETURN
      [self enterOrReturn];
      return( nil);

   case 259  :  
      [self backspaceCharacter]; 
      return( nil);

   case 262 : 
      [self cursorRight];
      return( nil);
   case 263 : 
      [self cursorLeft];
      return( nil);
   case 264 : 
      [self cursorDown];
      return( nil);
   case 265 : 
      [self cursorUp];
      return( nil);
   }
   return( nil);
}

PROTOCOLCLASS_END();
