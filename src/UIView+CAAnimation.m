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


struct 
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
   mulle_pointerarray_init( &Self._animatedLayers, 16, 0, NULL);
}

+ (void) unload 
{
   mulle_pointerarray_done( &Self._animatedLayers);
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
      mulle_pointerarray_done( &Self._animatedLayers);
      mulle_pointerarray_init( &Self._animatedLayers, 16, 0, NULL);

      // reset everything to default values or ?
      Self._animationDelay              = 0.0;
      Self._animationDuration           = 2.0;
      Self._animationReverses = 0.0;
      Self._animationRepeatCount        = 0.0;
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
 
   assert( _mulle_atomic_pointer_read( &Self._animationState) == (void *) (intptr_t) UIViewAnimationStarted);

   SelfLock();
   {
      _mulle_atomic_pointer_nonatomic_write( &Self._animationState, 
                                            (void *) (intptr_t)  UIViewAnimationCommitting);

      memcpy( &tmp, &Self._animatedLayers, sizeof( struct mulle_pointerarray));
      mulle_pointerarray_init( &Self._animatedLayers, 16, 0, NULL);
      animationID       = Self._animationID;
      Self._animationID = NULL;
      context           = Self._context;
      context           = NULL;
   }
   SelfUnlock();

   rover = mulle_pointerarray_enumerate_nil( &tmp);
   while( layer = mulle_pointerarrayenumerator_next( &rover))
      [layer commitImplicitAnimationsWithAnimationID:animationID
                                             context:context];
   mulle_pointerarrayenumerator_done( &rover);

   mulle_free( animationID);
   mulle_pointerarray_done( &tmp);

   //
   // TODO: we need a special kind of animation that is actually just calling
   //       the delegate at appropriate times. This animation needs to be 
   //       part of a layer ? Window layer ? Or some completely different 
   //       mechanism ?
   //
   _mulle_atomic_pointer_write( &Self._animationState, 
                               (void *) (intptr_t)  UIViewAnimationCommitting);
}                 


+ (BOOL) areAnimationsEnabled
{
   void  *state;

   state = _mulle_atomic_pointer_read( &Self._animationState);
   return( state != NULL);
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
      assert( mulle_pointerarray_find( &Self._animatedLayers, layer) == -1);
      mulle_pointerarray_add( &Self._animatedLayers, layer);   
   }
   SelfUnlock();
}

/* "properties" */

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



+ (void) setAnimationDelegate:(id) delegate
{
   SelfLock();
   {
      Self._delegate = delegate;
   }
   SelfUnlock();  
}


+ (void) setAnimationWillStartSelector:(SEL) selector
{
   SelfLock();
   {
      Self._animationWillStartSelector = selector;
   }
   SelfUnlock();  
}


+ (void) setAnimationDidStopSelector:(SEL) selector
{
   SelfLock();
   {
      Self._animationDidStopSelector = selector;
   }
   SelfUnlock();  
}
@end
