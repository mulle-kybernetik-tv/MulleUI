#import "MulleObjectArray.h"


@interface MulleObjectArrayEnumerator : NSObject <NSEnumeration>
{
   struct mulle_pointerarrayenumerator   _rover;
}
@end

@implementation MulleObjectArrayEnumerator

- (instancetype) initWithPointerarray:(struct mulle_pointerarray *) p
{
   assert( p);

   _rover = mulle_pointerarray_enumerate( p);
   return( self);
}


- (id) nextObject
{
   return(  mulle_pointerarrayenumerator_next( &_rover));
}

@end


@implementation MulleObjectArray 

- (instancetype) initWithPointerarray:(struct mulle_pointerarray *) p
                         freeWhenDone:(BOOL) yn
{
   assert( p);
   self->_pointerarray = p;
   self->_freeWhenDone = yn;
   return( self);
}


- (instancetype) init
{
   self->_pointerarray = mulle_pointerarray_create_nil( MulleObjCObjectGetAllocator( self));
   self->_freeWhenDone = YES;
   return( self);
}


- (void) dealloc
{
   if( self->_freeWhenDone)
   {
      // release them all
      struct mulle_pointerarrayenumerator   rover;
      id <NSObject>                         obj;

      rover = mulle_pointerarray_enumerate( self->_pointerarray);
      while( (obj = mulle_pointerarrayenumerator_next( &rover)))
         [obj release];
      mulle_pointerarrayenumerator_done( &rover);

      mulle_pointerarray_destroy( self->_pointerarray);
   }
   [super dealloc];
}


- (id) objectAtIndex:(NSUInteger) i
{
   // (ab)use assert of mulle_pointerarray
   return( mulle_pointerarray_get( self->_pointerarray, i));
}


- (NSUInteger) count
{
   return( mulle_pointerarray_get_count( self->_pointerarray));
}


struct _MulleObjectArrayFastEnumerationState
{
   struct mulle_pointerarrayenumerator   _rover;
};


- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *) rover
                                      objects:(id *) buffer
                                        count:(unsigned long) len
{
   struct _MulleObjectArrayFastEnumerationState   *dstate;
   id                                             *sentinel;
   id <NSObject>                                  obj;

   assert( sizeof( struct _MulleObjectArrayFastEnumerationState) <= sizeof( long) * 5);
   assert( alignof( struct _MulleObjectArrayFastEnumerationState) <= alignof( long));

   if( rover->state == -1)
      return( 0);

   // get our stat and init if its the first run
   dstate = (struct _MulleObjectArrayFastEnumerationState *) rover->extra;
   if( ! rover->state)
   {
      dstate->_rover = mulle_pointerarray_enumerate( self->_pointerarray);
      rover->state   = 1;
   }

   rover->itemsPtr  = buffer;

   sentinel = &buffer[ len];
   while( buffer < sentinel)
   {
      obj = mulle_pointerarrayenumerator_next( &dstate->_rover);
      if( ! obj)
      {
         rover->state = -1;
         break;
      }
      *buffer++ = obj;
   }

   rover->mutationsPtr = &rover->extra[ 4];

   return( len - (sentinel - buffer));
}


- (id <NSObject, NSEnumeration>) objectEnumerator
{
   return( [[[MulleObjectArrayEnumerator alloc] initWithPointerarray:self->_pointerarray] autorelease]);
}

@end





@implementation MulleMutableObjectArray 


- (void) insertObject:(id <NSObject>) obj
              atIndex:(NSUInteger) i;
{
   abort();
} 


- (void) removeObjectAtIndex:(NSUInteger) i
{
   abort();
} 


- (void) removeAllObjects
{
   abort();
} 


- (void) addObject:(id <NSObject>) obj
{
   [obj retain];
   mulle_pointerarray_add( self->_pointerarray, obj);
} 


- (void) removeLastObject
{
   id <NSObject>   obj;

   obj = mulle_pointerarray_remove_last( self->_pointerarray);
   [obj autorelease];
} 


- (void) replaceObjectAtIndex:(NSUInteger) i
                  withObject:(id <NSObject>) obj
{
   abort();
} 

@end