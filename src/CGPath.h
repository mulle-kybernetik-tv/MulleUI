//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifndef cgpath_h__
#define cgpath_h__

#include "include.h"

#include <mulle-buffer/mulle-buffer.h>  // TODO: why not get for free ?
#include <mulle-container/mulle-container.h>  // TODO: why not get for free ?

#include "CGBase.h"


enum CGPathCommand
{
   CGPathMoveToPointCommand,
   CGPathAddLineCommand,
   CGPathCloseSubpathCommand
};


typedef struct CGAffineTransform   CGAffineTransform;

//
// this is always mutable, but CGMutablePathRef is kept in the API for
// somewhat better compatiblity
//
typedef struct CGPath 
{
  struct mulle_buffer        _commands;
  struct mulle_structarray   _floats;
  unsigned char              _initialStorage[ 8];
} CGPath;


typedef struct CGPath   *CGPathRef;
typedef CGPathRef        CGMutablePathRef;


// mulle additions
struct CGPath     *CGPathCreate( struct mulle_allocator *allocator);
void   _CGPathInit( struct CGPath *path, struct mulle_allocator *allocator);
void   _CGPathDone( struct CGPath *path);
void   CGPathDestroy( struct CGPath *path);


// standard API...
static void inline  CGPathMoveToPoint( CGMutablePathRef path, 
                                       const CGAffineTransform *m, 
                                       CGFloat x, 
                                       CGFloat y)
{
   if( ! path)
      return;
   assert( ! m);

   mulle_buffer_add_byte( &path->_commands, CGPathMoveToPointCommand);
   _mulle_structarray_add( &path->_floats, &x);
   _mulle_structarray_add( &path->_floats, &y);
}

static void inline  CGPathAddLineToPoint( CGMutablePathRef path, 
                                          const CGAffineTransform *m, 
                                          CGFloat x, 
                                          CGFloat y)
{
   if( ! path)
      return;
   assert( ! m);

   mulle_buffer_add_byte( &path->_commands, CGPathAddLineCommand);
   _mulle_structarray_add( &path->_floats, &x);
   _mulle_structarray_add( &path->_floats, &y);
}


static void inline  CGPathCloseSubpath( CGMutablePathRef path)
{
   if( ! path)
      return;

   mulle_buffer_add_byte( &path->_commands, CGPathCloseSubpathCommand);
}


#endif
