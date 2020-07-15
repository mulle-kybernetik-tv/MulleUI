//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifndef mulle_point_history_h__
#define mulle_point_history_h__

#include "include.h"


struct MullePointHistoryItem
{
   CAAbsoluteTime   timestamp;
   CGPoint          point;
};


static inline void   MullePointHistoryItemPrintf( FILE *fp, struct MullePointHistoryItem *item)
{
   fprintf( fp, "{ timestamp=%.9f, point=%.2f,%2.f }\n", 
                  item->timestamp, item->point.x, item->point.y);
}


struct MullePointHistory
{
   struct MullePointHistoryItem    items[ 8];
   unsigned int                    i;
};


static inline void   _MullePointHistoryAdd( struct MullePointHistory *p, 
                                           CAAbsoluteTime timestamp,
                                           CGPoint point)
{
   p->i                      = (p->i + 1) & 0x7;
   p->items[ p->i].timestamp = timestamp;
   p->items[ p->i].point     = point;
}

//
// if previous timestamp is closer than xxx, then do what ?
// drop old ? drop new (!) ? interpolate ?
//
static inline void   MullePointHistoryAdd( struct MullePointHistory *p, 
                                           CAAbsoluteTime timestamp,
                                           CGPoint point)
{
   // drop new, if its coming in too quicly
   if( p->items[ p->i].timestamp + 0.01 > timestamp)
      return;
   _MullePointHistoryAdd( p, timestamp, point);
}


static inline void   MullePointHistoryStart( struct MullePointHistory *p,
                                             CAAbsoluteTime timestamp,
                                             CGPoint point)
{
   unsigned int   n;

   p->i = 0;
   n    = 8;
   do
      _MullePointHistoryAdd( p, timestamp, point);
   while( --n);
}

static inline void   MullePointHistoryPrint( FILE *fp,
                                             struct MullePointHistory *p)
{
#ifdef SCROLLVIEW_DEBUG
   unsigned int   n, i;

   i = p->i;
   n = 8;
   do
   {
      MullePointHistoryItemPrintf( fp, &p->items[ i]);
      i = (i - 1) & 0x7;
   }
   while( --n);
#endif
}


//
// start is the current time - 0.5 (or so) to get values from the past
// returns the position at that time
//
static inline struct MullePointHistoryItem   
   MullePointHistoryGetItemForTimestamp( struct MullePointHistory *p, 
                                         CAAbsoluteTime timestamp)
{
   unsigned int                   n;
   struct MullePointHistoryItem   *last;

   last = &p->items[ p->i];
   n    = 8;
   do
   {
      if( p->items[ p->i].timestamp < timestamp)
         break;
      last = &p->items[ p->i];
      p->i = (p->i - 1) & 0x7;
   }
   while( --n);

   return( *last);
}


#endif
