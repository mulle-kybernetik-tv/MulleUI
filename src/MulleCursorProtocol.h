//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "import.h"



struct MulleIntegerPoint
{
	NSUInteger    x;
	NSUInteger    y;
};

static inline 
   struct MulleIntegerPoint   MulleIntegerPointMake( NSUInteger x, NSUInteger y)
{
   struct MulleIntegerPoint   point;

   point.x = x;
   point.y = y;
   return( point);
}

static inline NSUInteger   MulleIntegerPointGetX( struct MulleIntegerPoint point)
{
   return( point.x);
}

static inline NSUInteger   MulleIntegerPointGetY( struct MulleIntegerPoint point)
{
   return( point.y);
}

static inline NSUInteger   MulleIntegerPointGetColumn( struct MulleIntegerPoint point)
{
   return( point.x);
}


static inline NSUInteger   MulleIntegerPointGetRow( struct MulleIntegerPoint point)
{
   return( point.y);
}


//
// if editable and in focus, will draw a caret/cursor    
// cursor position as row/column                         
//
#define MULLE_CURSOR_PROPERTIES \
   @property( assign, getter=isEditable) BOOL   editable;   \
   @property( assign) struct MulleIntegerPoint  cursorPosition



@protocol MulleCursor

MULLE_CURSOR_PROPERTIES;

- (struct MulleIntegerPoint) cursorPositionForPoint:(CGPoint) mouseLocation;

@end 
