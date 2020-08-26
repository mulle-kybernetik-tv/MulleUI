//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MulleMenu+UIEvent.h"

#import "import-private.h"

#import "UIEvent.h"
#import "UIView+UIEvent.h"


@implementation MulleMenu ( UIEvent)


// TODO: we are not really waiting for the mouseUp event, which may lead to
//       a stray and surprising mouseUp event for a control later on. But on
//       the other hand, the window might get entered with a physical mouse
//       down anyway, so where is the harm ?
//
- (UIEvent *) handleMouseButtonEvent:(UIMouseButtonEvent *) event
{
   int       action;
   CGPoint   translated;

   //
   // Check that the event didn't hit space inside of the menu, that's not 
   // reacting to events, so we don't close the menu unexpectedly
   //
   translated = [event _translatedPointForView:self];
   if( [super hitTest:translated
            withEvent:event])
   {
      return( nil);
   }    

   action = [event action];
   if( action == GLFW_PRESS)
   {
      [self performClickAndTargetActionCallbacks:event];
      return( nil);
   }
   return( event);
}


- (UIEvent *) handleKeyboardEvent:(UIKeyboardEvent *) event
{
   if( [event key] == GLFW_KEY_ESCAPE &&
       [event action] == GLFW_PRESS)
   {
#ifdef EVENT_DEBUG
      fprintf( stderr, "request close\n");
#endif      
      [self performClickAndTargetActionCallbacks:event];
      return( nil);
   }

   return( event);
}


- (UIEvent *) _handleEvent:(UIEvent *) event
{
   if( [self isUserInteractionEnabled] == NO)
   {
#ifdef EVENT_DEBUG
       fprintf( stderr, "Disabled view %s ignores event\n", [self cStringDescription]);
#endif      
      return( event);
   }

#ifdef EVENT_DEBUG
    fprintf( stderr, "Try to handle event %s\n", [self cStringDescription]);
#endif 

   switch( [event eventType])
   {
   case UIEventTypePresses :
      event = [self handleKeyboardEvent:(UIKeyboardEvent *) event];
      break;

   case UIEventTypeTouches :
      event = [self handleMouseButtonEvent:(UIMouseButtonEvent *) event];
      break;

   case UIEventTypeMotion :
      break;

   case UIEventTypeScroll :
      break;
   }

#ifdef EVENT_DEBUG
   if( event)
      fprintf( stderr, "Discarding unhandled event %s\n", [self cStringDescription]);
#endif    
   return( nil);
}

//
// The menu slurps up all events, if a subview doesn't handle the event, we
// will get called for _handleEvent soon
//
- (BOOL) hitTest:(CGPoint) point
       withEvent:(UIEvent *) event
{
   return( YES);
}


- (void) mulleSubviewDidHandleEvent:(UIEvent *) event
{
#ifdef EVENT_DEBUG
    fprintf( stderr, "A subview processed the event %s\n", [self cStringDescription]);
#endif   
   [self _handleEvent:event];
}

@end
