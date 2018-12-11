#include "include.h"

#include <stdio.h>

//
// From eventspersecond.c we know that on Linux you can send 
// ca. 150000 events/s  (2.6Ghz Xeon single core)
// model name      : Intel(R) Xeon(R) CPU E5-2660 v3 @ 2.60GHz
//
// we can have max 32693 channels on linux
// but this is also tied to coroutines apparently because otherwise the
// sender won't start up (so max is 32692)
//
// we can send ca. 1/Mio events/s
// So that reduces to ~ 10000 events/frame for 100 Hz  
// Since each event needs to be sent to a UIView, that reduces even more
// If the chain is 10 deep, that means we can handle 1000 events per frame.
//
#define N_VIEWS       32692 // 32693    // channels limit really
#define VIEW_DEBUG    0
#define SENDER_DEBUG  1


struct uievent
{
   int  _eventid;
};


void   uievent_init( struct uievent *self, int eventid)
{
   self->_eventid = eventid;
}

struct uiview 
{
   int  _channel[ 2];
   char *_name;
};

void   uiview_init( struct uiview *self, char *name)
{
   char  *strdup( char *s);

   self->_name = strdup( name);
   if( chmake( self->_channel))
      abort();
}


void   uiview_done( struct uiview *self)
{
   char   *s;

   chdone( self->_channel[ 1]);
   s            = self->_name;
   self->_name  = "dealloc";  
   free( s);
}


coroutine void  uiview_listen( struct uiview *self)
{
   struct uievent   event;
   static int       flag;
 
   for(;;)
   {
      if( chrecv( self->_channel[ 0], &event, sizeof( event), -1))
      {
         // window closed up on us
         switch( errno)
         {
            case ECANCELED :            
#if VIEW_DEBUG
               printf( "%s got ECANCELED during chrecv and exits\n", self->_name);
#endif   
               return;

         case EPIPE :
#if VIEW_DEBUG
               printf( "%s got EPIPE during chrecv and exits\n", self->_name);
#endif   
             return;
             
         case ETIMEDOUT :
#if VIEW_DEBUG
               printf( "%s got ETIMEDOUT during chrecv and exits\n", self->_name);
#endif   
             return;
         }
         perror( "chrecv:");
         abort();
      }

      flag = (event._eventid % N_VIEWS) == (N_VIEWS - 1);
#if VIEW_DEBUG
      // printf( "%s did %shandle event %d\n", self->_name, flag ? "" : "NOT ", event._eventid);
#endif   
      if( chsend( self->_channel[ 1], &flag, sizeof( flag), -1))
      {
         // window closed up on us
         switch( errno)
         {
            case ECANCELED :            
#if VIEW_DEBUG
               printf( "%s got ECANCELED during chsend and exits\n", self->_name);
#endif   
               return;

         case EPIPE :
#if VIEW_DEBUG
               printf( "%s got EPIPE during chsend and exits\n", self->_name);
#endif   
             return;

         case ETIMEDOUT :
#if VIEW_DEBUG
               printf( "%s got ETIMEDOUT during chsend and exits\n", self->_name);
#endif   
             return;
         }

         perror( "chsend:");
         abort();
      }
   }
}   


int   send_event_to_view( struct uievent event,
                          struct uiview *view)
{
   int  flag;

   if( chsend( view->_channel[ 1], &event, sizeof( event), 0))
   {
      switch( errno)
      {
         case ECANCELED :            
         case ETIMEDOUT :         
            return( -1);
      }
      perror( "chsend:");
      abort();
   }
   yield();  // make sure uiview runs immediately

   if( chrecv( view->_channel[ 0], &flag, sizeof( flag), 0))
   {
      switch( errno)
      {
         case ECANCELED :   
         case ETIMEDOUT :         
            return( -1);
      }
      perror( "chrecv:");
      abort();
   }   
   return( flag);
}                          


coroutine void  event_sender( struct uiview *views, int n, int *eventid)
{
   struct uievent  event;
   int    i;
   int    rval;

#if SENDER_DEBUG
   fprintf( stderr, "Event sender starts\n");
#endif   
   for(;;) 
   {
      for( i = 0; i < n; i++)
      {
         uievent_init( &event, (*eventid)++);
         rval = send_event_to_view( event, &views[ i]);
         if( rval == -1)
         {
#if SENDER_DEBUG
            fprintf( stderr, "Event sender stops\n");
#endif   
            return;
         }
         if( rval)
            break;
      } 
   }
}


main()
{
   int             bd;
   struct uiview   *views;
   struct uiview   view2;
   struct uievent  event;
   int             eventid;
   int            flag;
   int             i;
   int             j;
   int             n;
   char            buf[ 64];

   n       = N_VIEWS;
   views   = malloc( sizeof( struct uiview) * n);
   if( ! views)
   {
      perror( "malloc:");
      abort();
   }

   eventid = 0;

   bd = bundle();
   for( i = 0; i < n; i++)
   {
      sprintf( buf, "view #%d", i);

      uiview_init( &views[ i], buf);
      bundle_go( bd, uiview_listen( &views[ i]));
   }

   bundle_go( bd, event_sender( views, n, &eventid));

   bundle_wait( bd, now() + 1000);
   hclose( bd);

   printf( "done with %d events\n", eventid);
}
