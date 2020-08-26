#import "UIView+CAAnimation.h"

#import "import-private.h"

#import "CALayer.h"


@implementation UIView ( CAAnimation)

enum
{
   UIViewAnimationIdle,
   UIViewAnimationStarted,
   UIViewAnimationCommitting
};


static struct
{
   mulle_thread_mutex_t        _lock;

   // mutable state
   struct mulle_pointerarray   _animatedLayers;

   char                        *_animationID;
   void                        *_context;
   id                          _delegate;
   SEL                         _animationWillStartSelector;
   SEL                         _animationDidStopSelector;

   CARelativeTime              _animationDelay;
   CARelativeTime              _animationDuration;
   float                       _animationRepeatCount;
   NSUInteger                  _animationCurve;
   BOOL                        _animationReverses;

   mulle_atomic_pointer_t      _animationState;
} Self;


static inline void   SelfLock()
{
   mulle_thread_mutex_lock( &Self._lock);
}

static inline void   SelfUnlock()
{
   mulle_thread_mutex_unlock( &Self._lock);
}


+ (void) load
{
   mulle_thread_mutex_init( &Self._lock);
}


+ (void) unload
{
   _mulle_pointerarray_done( &Self._animatedLayers);
   mulle_thread_mutex_done( &Self._lock);
}

+ (void) beginAnimations:(char *) animationID
                 context:(void *) context
{
   assert( _mulle_atomic_pointer_read( &Self._animationState) == NULL);

   SelfLock();
   {
      mulle_free( Self._animationID);

      Self._animationID       = animationID ? mulle_strdup( animationID) : NULL;
      Self._context           = context;
      _mulle_atomic_pointer_nonatomic_write( &Self._animationState,
                                            (void *) (intptr_t)  UIViewAnimationStarted);
      
      _mulle_pointerarray_done( &Self._animatedLayers);
      _mulle_pointerarray_init( &Self._animatedLayers, 16, NULL);

      // reset everything to default values or ?
      Self._animationDelay              = 0.0;
      Self._animationDuration           = 2.0;
      Self._animationReverses           = 0.0;
      Self._animationRepeatCount        = 0.0;
      Self._delegate                    = nil;
      Self._animationWillStartSelector  = 0;
      Self._animationDidStopSelector    = 0;
   }
   SelfUnlock();
}

+ (void) commitAnimations
{
   CALayer                               *layer;
   char                                  *animationID;
   struct mulle_pointerarray             tmp;
   struct mulle_pointerarrayenumerator   rover;
   void                                  *context;
   id                                    delegate;
   SEL                                   willStart;
   SEL                                   didEnd;
   MulleAnimationDelegate                *animationDelegate;

   assert( _mulle_atomic_pointer_read( &Self._animationState) == (void *) (intptr_t) UIViewAnimationStarted);

   SelfLock();
   {
      _mulle_atomic_pointer_nonatomic_write( &Self._animationState,
                                            (void *) (intptr_t)  UIViewAnimationCommitting);

      memcpy( &tmp, &Self._animatedLayers, sizeof( struct mulle_pointerarray));
      _mulle_pointerarray_init( &Self._animatedLayers, 16, NULL);
      animationID       = Self._animationID;
      Self._animationID = NULL;
      context           = Self._context;
      context           = NULL;

      delegate                         = Self._delegate;
      Self._delegate                   = nil;
      willStart                        = Self._animationWillStartSelector;
      Self._animationWillStartSelector = 0;
      didEnd                           = Self._animationDidStopSelector;
      Self._animationDidStopSelector   = 0;
   }
   SelfUnlock();

   animationDelegate = nil;
   if( delegate)
   {
      animationDelegate = [[MulleAnimationDelegate new] autorelease];
      [animationDelegate setIdentifier:animationID];
      [animationDelegate setContext:context];
      [animationDelegate setDelegate:delegate];
      [animationDelegate setAnimationWillStartSelector:willStart];
      [animationDelegate setAnimationDidStopSelector:didEnd];
   }

   rover = mulle_pointerarray_enumerate( &tmp);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &layer))
   {
      [layer commitImplicitAnimationsWithAnimationID:animationID
                                   animationDelegate:animationDelegate];
   }
   mulle_pointerarrayenumerator_done( &rover);

   mulle_free( animationID);
   mulle_pointerarray_done( &tmp);

   //
   // TODO: we need a special kind of animation that is actually just calling
   //       the delegate at appropriate times. This animation needs to be
   //       part of a layer ? Window layer ? Or some completely different
   //       mechanism ?
   //

   // return to idle
   _mulle_atomic_pointer_write( &Self._animationState,
                               (void *) (intptr_t)  UIViewAnimationIdle);
}

BOOL   UIViewAreAnimationsEnabled( void)
{
   void  *state;

   state = _mulle_atomic_pointer_read( &Self._animationState);
   return( state != NULL);
}


+ (BOOL) areAnimationsEnabled
{
   return( UIViewAreAnimationsEnabled());
}

//
//
//
+ (void) addAnimatedLayer:(CALayer *) layer
{
   assert( layer);
   assert( [layer isKindOfClass:[CALayer class]]);

   SelfLock();
   {
      assert( _mulle_pointerarray_find( &Self._animatedLayers, layer) == mulle_not_found_e);
      _mulle_pointerarray_add( &Self._animatedLayers, layer);
   }
   SelfUnlock();
}

/* "properties" */


+ (id) animationDelegate
{
   id   value;

   SelfLock();
   {
      value = Self._delegate;
   }
   SelfUnlock();
   return( value);
}

+ (SEL) animationDidStopSelector
{
   SEL   value;

   SelfLock();
   {
      value = Self._animationDidStopSelector;
   }
   SelfUnlock();
   return( value);
}

+ (SEL) animationWillStartSelector
{
   SEL   value;

   SelfLock();
   {
      value = Self._animationWillStartSelector;
   }
   SelfUnlock();
   return( value);
}


+ (void) setAnimationDelegate:(id) value
{
   SelfLock();
   {
      Self._delegate = value;
   }
   SelfUnlock();
}


+ (void) setAnimationDidStopSelector:(SEL) value
{
   SelfLock();
   {
      Self._animationDidStopSelector = value;
   }
   SelfUnlock();
}


+ (void) setAnimationWillStartSelector:(SEL) value
{
   SelfLock();
   {
      Self._animationWillStartSelector = value;
   }
   SelfUnlock();
}



//


+ (CARelativeTime) animationDelay
{
   CARelativeTime   value;

   SelfLock();
   {
      value = Self._animationDelay;
   }
   SelfUnlock();
   return( value);
}


+ (void) setAnimationDelay:(CARelativeTime) delay
{
   SelfLock();
   {
      Self._animationDelay = delay;
   }
   SelfUnlock();
}

+ (CARelativeTime) animationDuration
{
   CARelativeTime   value;

   SelfLock();
   {
      value = Self._animationDuration;
   }
   SelfUnlock();
   return( value);
}


+ (void) setAnimationDuration:(CARelativeTime) duration
{
   SelfLock();
   {
      Self._animationDuration = duration;
   }
   SelfUnlock();
}


+ (NSUInteger) animationCurve
{
   NSUInteger   value;

   SelfLock();
   {
      value = Self._animationCurve;
   }
   SelfUnlock();
   return( value);
}


+ (void) setAnimationCurve:(NSUInteger) value
{
   SelfLock();
   {
      Self._animationCurve = value;
   }
   SelfUnlock();
}


+ (BOOL) animationRepeatAutoreverses
{
   BOOL   value;

   SelfLock();
   {
      value = Self._animationReverses;
   }
   SelfUnlock();
   return( value);
}


+ (void) setAnimationRepeatAutoreverses:(BOOL) flag
{
   SelfLock();
   {
      Self._animationReverses = flag;
   }
   SelfUnlock();
}

// incompatible
+ (float) animationRepeatCount
{
   float   value;

   SelfLock();
   {
      value = Self._animationRepeatCount;
   }
   SelfUnlock();
   return( value);
}


+ (void) setAnimationRepeatCount:(float) value
{
   SelfLock();
   {
      Self._animationRepeatCount = value < 0.0 ? -1.0 : value;
   }
   SelfUnlock();
}


// incompatible
+ (BOOL) mulleAnimationRepeats
{
   BOOL   value;

   SelfLock();
   {
      value = Self._animationRepeatCount != 0.0;
   }
   SelfUnlock();
   return( value);
}


+ (void) mulleSetAnimationRepeats:(BOOL) flag
{
   SelfLock();
   {
      Self._animationRepeatCount = flag ? -1.0 : 0.0;
   }
   SelfUnlock();
}

@end
