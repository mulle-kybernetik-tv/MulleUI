#import "UIView.h"

#import "UIEdgeInsets.h"

#import "CGGeometry+CString.h"


/* 
 * a UIScrollView is a container for UIViews like a regular UIView
 * a specialty of the UIScrollView is, that it doesn't scale the
 * subviews.
 */
@class UIScrollContentView;
@class MulleScrollIndicatorView;
@class UIScrollView;

@protocol UIScrollViewDelegate

@optional
- (void) scrollViewDidScroll:(UIScrollView *) scrollView;
- (void) scrollViewDidZoom:(UIScrollView *) scrollView;
- (void) scrollViewWillBeginDragging:(UIScrollView *) scrollView;
- (void) scrollViewWillEndDragging:(UIScrollView *) scrollView 
                      withVelocity:(CGPoint) velocity 
               targetContentOffset:(CGPoint *) targetContentOffset;
- (void) scrollViewDidEndDragging:(UIScrollView *) scrollView 
                   willDecelerate:(BOOL)decelerate;
- (void) scrollViewWillBeginDecelerating:(UIScrollView *) scrollView;
- (void) scrollViewDidEndDecelerating:(UIScrollView *) scrollView;
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *) scrollView;
- (UIView *) viewForZoomingInScrollView:(UIScrollView *) scrollView;
- (void) scrollViewWillBeginZooming:(UIScrollView *) scrollView 
                           withView:(UIView *) view;
- (void) scrollViewDidEndZooming:(UIScrollView *) scrollView 
                        withView:(UIView *) view 
                         atScale:(CGFloat) scale;
- (BOOL) scrollViewShouldScrollToTop:(UIScrollView *) scrollView;
- (void) scrollViewDidScrollToTop:(UIScrollView *) scrollView;

@end

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



@interface UIScrollView : UIView
{
	UIScrollContentView         *_contentView;
	MulleScrollIndicatorView    *_horIndicatorView;
	MulleScrollIndicatorView    *_verIndicatorView;

// Event handling state
   CGPoint                     _momentum;
   CGPoint                     _mousePosition;
   CGPoint                     _bubbleDragOffset;
   CAAbsoluteTime              _scrollStartTime;
   CAAbsoluteTime              _momentumTimestamp;
   
   struct MullePointHistory    _mousePositionHistory;
}

@property UIEdgeInsets                         contentInset;
@property( assign) id <UIScrollViewDelegate>   delegate;
@property( assign) CGSize                      contentSize;
@property( assign, getter=isDragging) BOOL     dragging;

- (void) setContentOffset:(CGPoint) offset;
- (void) scrollContentOffsetBy:(CGPoint) diff;
- (CGPoint) contentOffset;

// move this into category
- (void) scrollRectToVisible:(CGRect) rect 
                    animated:(BOOL) animated;

// add subviews to contentView not to UIScrollView
- (UIScrollContentView *) contentView;  
- (UIView *) horizontalScrollIndicatorView; 
- (UIView *) verticalScrollIndicatorView;   

- (CGPoint) clampedContentOffset:(CGPoint) offset;
- (CGRect) clampedContentViewBounds:(CGRect) bounds;

@end


@interface UIScrollContentView : UIView
{
}
@end
