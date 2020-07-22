//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#include "CGPath.h"

#include "include-private.h"

void   _CGPathInit( struct CGPath *path, struct mulle_allocator *allocator)
{
   mulle_buffer_init_with_static_bytes(&path->_commands,
                                       path->_initialStorage,
                                       sizeof(path->_initialStorage),
                                       allocator);
   _mulle_structarray_init( &path->_floats,
                            sizeof(CGFloat),
                            alignof(CGFloat),
                            8,
                            allocator);

                            
}


struct CGPath   *CGPathCreate(struct mulle_allocator *allocator)
{
   CGMutablePathRef   path;

   path = mulle_allocator_malloc( allocator, sizeof( struct CGPath));
   _CGPathInit( path, allocator);
   return( path);
}


void   _CGPathDone(struct CGPath *path)
{
   mulle_buffer_done(&path->_commands);
   _mulle_structarray_done(&path->_floats);
}


void CGPathDestroy(struct CGPath *path)
{
   struct mulle_allocator *allocator;
   
   if( ! path) 
      return;

   allocator = mulle_buffer_get_allocator( &path->_commands);
   _CGPathDone( path);
   mulle_allocator_free( allocator, path);
}

