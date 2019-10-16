#import "MulleTrackingArea.h"

#import "import-private.h"


# pragma mark - struct MulleTrackingAreaArray

void
   MulleTrackingAreaArrayInit( struct MulleTrackingAreaArray *array,
                               struct mulle_allocator *allocator)
{
   assert( array);

   array->size      = 0;
   array->n         = 0;
   array->allocator = allocator;
   array->items     = NULL;
}


static void
   MulleTrackingAreaDoneItems( struct MulleTrackingAreaArray *array)
{
   struct MulleTrackingArea   *p;
   struct MulleTrackingArea   *sentinel;

   assert( array);

   p        = array->items;
   sentinel = &p[ array->n];
   while( p < sentinel)
   {
      MulleTrackingAreaDone( p);
      ++p;
   }
}


void
   MulleTrackingAreaArrayDone( struct MulleTrackingAreaArray *array)
{
   assert( array);

   MulleTrackingAreaDoneItems( array);
   mulle_allocator_free( array->allocator, array->items);

   // this is important
   array->items = NULL;
   array->n     = 0;
   array->size  = 0;
}


struct MulleTrackingArea   *
   MulleTrackingAreaArrayNewItem( struct MulleTrackingAreaArray *array)
{
   struct MulleTrackingArea   *p;

   assert( array);

   if( array->n == array->size)
   {
      array->size += array->size;
      if( array->size < 4)
         array->size = 4;

      array->items = mulle_allocator_realloc( array->allocator, 
                                              array->items, 
                                              sizeof( struct MulleTrackingArea) * array->size);
   }

   p = &array->items[ array->n++];
   memset( p, 0, sizeof( struct MulleTrackingArea));
   return( p);
}


struct MulleTrackingArea *
   MulleTrackingAreaArrayGetItemWithRect( struct MulleTrackingAreaArray *array,
                                          CGRect rect)
{
   struct MulleTrackingArea   *p;
   struct MulleTrackingArea   *sentinel;

   assert( array);

   p        = &array->items[ 0];
   sentinel = &array->items[ array->n];

   while( p < sentinel)
   {
      if( CGRectEqualToRect( MulleTrackingAreaGetRect( p), rect))
      {
         return( p);
      }
      ++p;
   }
   return( NULL);
}



void
   MulleTrackingAreaArrayRemoveItem( struct MulleTrackingAreaArray *array,
                                     struct MulleTrackingArea *item)
{
   ptrdiff_t   index;
   int         tocopy;

   if( ! item)
      return;

   assert( array);
   
   index = item - array->items;
   assert( index >= 0 && index < array->n);

   MulleTrackingAreaDone( item);

   //
   // assume: 4 entries (0,1,2,3), removing entry 2, have to compact 1 from behind
   //          
   tocopy = array->n - index - 1;      // 4 - 2 - 1 = 2
   if( tocopy > 0)
   {
      memmove( &array->items[ index], 
               &array->items[ index + 1], 
               tocopy * sizeof( struct MulleTrackingArea));
   }
   --array->n;
}



