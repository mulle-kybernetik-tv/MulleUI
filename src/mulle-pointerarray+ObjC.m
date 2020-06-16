#import "mulle-pointerarray+ObjC.h"


void  mulle_pointerarray_release_all( struct mulle_pointerarray *array)
{
   struct mulle_pointerarrayenumerator   rover;
   id     obj;

   rover = mulle_pointerarray_enumerate_nil( array);
   while( (obj = _mulle_pointerarrayenumerator_next( &rover)))
      [obj release];
   mulle_pointerarrayenumerator_done( &rover);
}


void  mulle_pointerarray_retain_all( struct mulle_pointerarray *array)
{
   struct mulle_pointerarrayenumerator   rover;
   id     obj;

   rover = mulle_pointerarray_enumerate_nil( array);
   while( (obj = _mulle_pointerarrayenumerator_next( &rover)))
      [obj retain];
   mulle_pointerarrayenumerator_done( &rover);
}



void  mulle_pointerarray_copy_all( struct mulle_pointerarray *array, id *dst)
{
   struct mulle_pointerarrayenumerator   rover;
   id     obj;

   rover = mulle_pointerarray_enumerate_nil( array);
   while( (obj = _mulle_pointerarrayenumerator_next( &rover)))
      *dst++ = obj;;
   mulle_pointerarrayenumerator_done( &rover);
}
