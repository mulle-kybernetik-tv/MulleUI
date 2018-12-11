#include "include.h"

#include <stdio.h>


static void  (*listeners[ 5][ 10])( int, int);

void  send_event( int bd, int event, int value)
{
   int   i;

   for( i = 0; i < 10; i++)
   {
      if( listeners[ event][ i])
          bundle_go( bd, (*listeners[ event][ i])( event, value));
   }
}

int   add_listener( int event, void (*listener)( int, int))
{
   int   i;

   for( i = 0; i < 10; i++)
   {
      if( ! listeners[ event][ i])
      {
         listeners[ event][ i] = listener;
         return( 0);
      }
   }
   return( -1);
}


void  event_source( int bd)
{
   static int   event_nr;
   int          i;

   for( i = 0; i < 10; i++)
   {
      event_nr = (event_nr + 1) % 5;
      send_event( bd, event_nr, i);
      fprintf( stderr, ">>> %llu: %d, %d\n", now(), event_nr, i);
   }
}


coroutine void  event_consumer1( int event, int value)
{
   msleep( now() + 200);
   printf( "%llu: %s %d: %d\n", now(), __PRETTY_FUNCTION__, event, value);
}


coroutine void  event_consumer2( int event, int value)
{
   msleep( now() + 100);
   printf( "%llu: %s %d: %d\n", now(), __PRETTY_FUNCTION__, event, value);
}


coroutine void  event_consumer3( int event, int value)
{
   printf( "%llu: %s %d: %d\n", now(), __PRETTY_FUNCTION__, event, value);
}


main()
{
   int   bd;

   bd = bundle();

   add_listener( 1, event_consumer1);
   add_listener( 3, event_consumer1);
   add_listener( 3, event_consumer2);
   add_listener( 3, event_consumer3);

   event_source( bd);

   bundle_wait( bd, -1);
   hclose( bd);

   printf( "done\n");
}
