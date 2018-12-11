// must be compiled and linked with the UIView ....
// 
// On Linux you can send ca. 150000 events/s

coroutine void   send_events( UIWindow *window, int *eventid)
{
   int   i;

   for(;;)
   {
      for( i = 0; i < 10; i++)
      {
         [UIWindow sendEmptyEvent];
         (*eventid)++;
         [window discardPendingEvents];
      }
      if( yield() == ECANCELED)
         break;
   }
}


int   main()
{
   UIWindow   *window;
   int        eventid;

   window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 640.0, 400.0)] autorelease];
   assert( window);

   [[UIApplication sharedInstance] addWindow:window];

   eventid = 0;
   go( send_events( window, &eventid));

   msleep( now() + 1000);

   fprintf( stderr, "events sent %d", eventid);
}

