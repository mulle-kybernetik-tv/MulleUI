#import "import.h"

#include "CGGeometry.h"


struct MulleTrackingArea
{
   CGRect    rect;
   id        userInfo;
   struct 
   {
      unsigned  receivesObscuredEvents : 1;
   } flag;
};



static inline void    MulleTrackingAreaInit( struct MulleTrackingArea *p, CGRect rect, id userInfo)
{
   p->rect     = rect;
   p->userInfo = [userInfo retain];
   p->flag.receivesObscuredEvents = NO;
}

static inline void    MulleTrackingAreaDone( struct MulleTrackingArea *p)
{
   [p->userInfo autorelease];
}


static inline void    MulleTrackingAreaSetRect( struct MulleTrackingArea *p, 
                                                CGRect rect)
{
   p->rect = rect;
}


static inline CGRect    MulleTrackingAreaGetRect( struct MulleTrackingArea *p)
{
   return( p->rect);
}


static inline void    MulleTrackingAreaSetUserInfo( struct MulleTrackingArea *p, 
                                                    id userInfo)
{
   [p->userInfo autorelease];
   p->userInfo = [userInfo retain]; 
}

static inline id    MulleTrackingAreaGetUserInfo( struct MulleTrackingArea *p)
{
   return( p->userInfo); 
}



// not that useful for public consumption, therefore not typedef
struct MulleTrackingAreaArray
{
   NSUInteger                  n;
   NSUInteger                  size;
   struct mulle_allocator      *allocator;
   struct MulleTrackingArea    *items;
};


void
   MulleTrackingAreaArrayInit( struct MulleTrackingAreaArray *array,
                               struct mulle_allocator *allocator);

void
   MulleTrackingAreaArrayDone( struct MulleTrackingAreaArray *array);

static inline NSUInteger
   MulleTrackingAreaArrayGetCount( struct MulleTrackingAreaArray *array)
{
   return( array ? array->n : 0);
}   

struct MulleTrackingArea   *
   MulleTrackingAreaArrayNewItem( struct MulleTrackingAreaArray *array);

void
   MulleTrackingAreaArrayRemoveItem( struct MulleTrackingAreaArray *array,
                                     struct MulleTrackingArea *item);


// pointer only valid, as long as nothing gets added or removed.
static inline struct MulleTrackingArea   *
   MulleTrackingAreaArrayGetItemAtIndex( struct MulleTrackingAreaArray *array,
                                         NSUInteger  index)
{
   assert( index < array->n);
   return( &array->items[ index]);
}

struct MulleTrackingArea   *
   MulleTrackingAreaArrayGetItemWithRect( struct MulleTrackingAreaArray *array,
                                          CGRect rect);
