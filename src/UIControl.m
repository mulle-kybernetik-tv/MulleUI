#import "UIControl.h"

#import "UIView.h"

#define LOG_EVENTS
// #define LOG_MOUSE_MOVE_EVENTS


PROTOCOLCLASS_IMPLEMENTATION( UIControl)

//
// so the protocolclass can not provide implementations, as it doesn't
// know the layout of the class that inherits
//
@dynamic action;
@dynamic click;
@dynamic state;
@dynamic target;

- (BOOL) canBecomeFirstResponder
{
   UIControlState   state;

 	state = [self state];
   return( (state & UIControlStateDisabled) ? NO : YES);
}


- (UIEvent *) consumeMouseEventIfDisabled:(UIEvent *) event
{
	UIControlState   state;

   // a disabled control swallows events
 	state = [self state];
	if( state & UIControlStateDisabled)
		return( nil);

   return( event);   
}


// @method_alias( mouseUp:, mouseDown:);

- (UIEvent *) consumeMouseDown:(UIEvent *) event
{
   return( nil);
}


- (UIEvent *) mouseDown:(UIEvent *) event
{
#ifdef LOG_EVENTS   
   fprintf( stderr, "%s: %s\n", __PRETTY_FUNCTION__, [(UIView *) self cStringDescription]);
#endif

	event = [self consumeMouseEventIfDisabled:event];
	// event was handled if nil
	if( ! event)
	   return( event);   

   if( ! [self isFirstResponder])
      [self becomeFirstResponder];
   // we alway snarf up the mouseDown: event (why pass to parent ?)
   event = [self consumeMouseDown:event];
   return( event);
}


- (UIEvent *) consumeMouseDragged:(UIEvent *) event
{
   return( nil);
}


- (UIEvent *) mouseDragged:(UIEvent *) event
{
#ifdef LOG_EVENTS   
   fprintf( stderr, "%s: %s\n", __PRETTY_FUNCTION__, [(UIView *) self cStringDescription]);
#endif

	event = [self consumeMouseEventIfDisabled:event];
	// event was handled if nil
	if( ! event)
	   return( event);   

   // we alway snarf up the mouseDragged: event (why pass to parent ?)
   event = [self consumeMouseDragged:event];
   return( event);
}
 

- (UIEvent *) performClickAndTargetActionCallbacks:(UIEvent *) event
{
   UIControlClickHandler  *click;
   SEL                    sel;

   click = [self click];
   if( click)
      event = (*click)( self, event);
   if( event && (sel = [self action]))
   {
      [[self target] performSelector:sel
                          withObject:self];
      event = nil;
   }
   return( event);
}


- (UIEvent *) consumeMouseUp:(UIEvent *) event
{
   event = [self performClickAndTargetActionCallbacks:event];
   return( event);
}


- (UIEvent *) mouseUp:(UIEvent *) event
{
   BOOL   flag;

#ifdef LOG_EVENTS   
   fprintf( stderr, "%s: %s\n", __PRETTY_FUNCTION__, [(UIView *) self cStringDescription]);
#endif

	event = [self consumeMouseEventIfDisabled:event];
	// event was handled if nil
	if( ! event)
   {
      assert( ! [self isFirstResponder] && "mouseUp: overridden, but mouseDown: made us first responder");
	   return( event);
   }

   flag  = [self resignFirstResponder];
   event = [self consumeMouseUp:event];
   return( flag ? nil : event);  // or swallow always ?
}


- (UIEvent *) consumeMouseEntered:(UIEvent *) event
{
   [self mulleToggleHighlightedState]; // what if already set ???
   return( nil);
}


- (UIEvent *) mouseEntered:(UIEvent *) event
{
#ifdef LOG_EVENTS   
   fprintf( stderr, "%s: %s\n", __PRETTY_FUNCTION__, [(UIView *) self cStringDescription]);
#endif

   // TODO: have a "consumeEvent" method instead, which checks for being
   //       disabled in UIControl. UIView will return event by default
   //       modal MulleWindowPlane might return nil if not hidden.. ??
	event = [self consumeMouseEventIfDisabled:event];
	// event was handled if nil
	if( ! event)
	   return( event);   

   event = [self consumeMouseEntered:event];
   return( event);
}


- (UIEvent *) consumeMouseMoved:(UIEvent *) event
{
   return( nil);
}


- (UIEvent *) mouseMoved:(UIEvent *) event
{
#ifdef LOG_MOUSE_MOVE_EVENTS   
   fprintf( stderr, "%s: %s\n", __PRETTY_FUNCTION__, [(UIView *) self cStringDescription]);
#endif

   // TODO: have a "consumeEvent" method instead, which checks for being
   //       disabled in UIControl. UIView will return event by default
   //       modal MulleWindowPlane might return nil if not hidden.. ??
	event = [self consumeMouseEventIfDisabled:event];
	// event was handled if nil
	if( ! event)
	   return( event);   

   event = [self consumeMouseMoved:event];
   return( event);
}


- (UIEvent *) consumeMouseExited:(UIEvent *) event
{
   [self mulleToggleHighlightedState]; // what if already set ???
   return( nil);
}

- (UIEvent *) mouseExited:(UIEvent *) event
{
#ifdef LOG_EVENTS   
   fprintf( stderr, "%s: %s\n", __PRETTY_FUNCTION__, [(UIView *) self cStringDescription]);
#endif

   // TODO: have a "consumeEvent" method instead, which checks for being
   //       disabled in UIControl. UIView will return event by default
   //       modal MulleWindowPlane might return nil if not hidden.. ??
	event = [self consumeMouseEventIfDisabled:event];
	// event was handled if nil
	if( ! event)
	   return( event);   

   event = [self consumeMouseExited:event];
   return( event);
}


/*
 * Keyboard
 */ 
// @method_alias( keyUp:, keyDown:);

- (BOOL) shouldProcessKeyEvent:(UIEvent *) event
{
	UIControlState   state;

   // a disabled control swallows events
 	state = [self state];
	if( state & UIControlStateDisabled)
		return( NO);

   return( YES);   
}


- (BOOL) shouldProcessUnicodeEvent:(UIEvent *) event
{
   return( [self shouldProcessKeyEvent:event]);
}



// if we don't want it, pass it up i guess
- (UIEvent *) consumeKeyUp:(UIEvent *) event
{
   return( nil);
}


- (UIEvent *) keyUp:(UIEvent *) event
{
   BOOL       flag;
   UIEvent   *result;
   
#ifdef LOG_EVENTS   
   fprintf( stderr, "%s: %s\n", __PRETTY_FUNCTION__, [(UIView *) self cStringDescription]);
#endif

	if( ! [self shouldProcessKeyEvent:event])
	   return( event);

   event = [self consumeKeyUp:event];
   return( event);  
}


// if we don't want it, pass it up i guess
- (UIEvent *) consumeKeyDown:(UIEvent *) event
{
   return( nil);
}


- (UIEvent *) keyDown:(UIEvent *) event
{
#ifdef LOG_EVENTS   
   fprintf( stderr, "%s: %s\n", __PRETTY_FUNCTION__, [(UIView *) self cStringDescription]);
#endif

	if( ! [self shouldProcessKeyEvent:event])
	   return( event);   

   if( ! [self isFirstResponder])
      [self becomeFirstResponder];

   event = [self consumeKeyDown:event];
   return( event);
}



// if we don't want it, pass it up i guess
- (UIEvent *) consumeUnicodeCharacter:(UIEvent *) event
{
   return( nil);
}


- (UIEvent *) unicodeCharacter:(UIEvent *) event
{
#ifdef LOG_EVENTS   
   fprintf( stderr, "%s: %s\n", __PRETTY_FUNCTION__, [(UIView *) self cStringDescription]);
#endif

	if( ! [self shouldProcessUnicodeEvent:event])
	   return( event);   

   if( ! [self isFirstResponder])
      [self becomeFirstResponder];
      
   event = [self consumeUnicodeCharacter:event];
   return( event);
}


static inline BOOL   getStateBit( UIControl *self, enum UIControlStateBit bit)
{
	UIControlState   state;

	state = [self state];
	return( state & bit ? YES : NO);
}

- (void) mulleToggleSelectedState
{
   UIControlState   state;

	state = [self state];
	if( state & UIControlStateSelected)
		state &= ~UIControlStateSelected;
	else
		state |= UIControlStateSelected;
	[self setState:state];
}


- (void) mulleToggleHighlightedState
{
   UIControlState   state;

	state = [self state];
	if( state & UIControlStateHighlighted)
		state &= ~UIControlStateHighlighted;
	else
		state |= UIControlStateHighlighted;
	[self setState:state];
}


static void   setStateBit( UIControl *self, enum UIControlStateBit bit, BOOL flag)
{
	UIControlState   state;
	UIControlState   newState;

	state = [self state];
	if( flag)
		newState = state | bit;
	else
		newState = state & ~bit;
      
	if( newState != state)
	{
		/*
		 H | D | S | F | 
		---|---|---|---|--------------
		 0 | 0 | 0 | 0 | 
		 1 | 0 | 0 | 0 | 
		 0 | 1 | 0 | 0 | 
		 1 | 1 | 0 | 0 | *impossible*
		 0 | 0 | 1 | 0 | 
		 1 | 0 | 1 | 0 | 
		 0 | 1 | 1 | 0 | 
		 1 | 1 | 1 | 0 | *impossible*
		 0 | 0 | 0 | 1 | 
		 1 | 0 | 0 | 1 | 
		 0 | 1 | 0 | 1 | *impossible*
		 1 | 1 | 0 | 1 | *impossible*
		 0 | 0 | 1 | 1 | 
		 1 | 0 | 1 | 1 | 
		 0 | 1 | 1 | 1 | *impossible*
		 1 | 1 | 1 | 1 | *impossible*		
		*/
		assert( state != (UIControlStateHighlighted|UIControlStateDisabled));
		assert( state != (UIControlStateHighlighted|UIControlStateDisabled|UIControlStateSelected));
		assert( state != (UIControlStateDisabled|UIControlStateFocused));
		assert( state != (UIControlStateHighlighted|UIControlStateDisabled|UIControlStateFocused));
		assert( state != (UIControlStateDisabled|UIControlStateSelected|UIControlStateFocused));
		assert( state != (UIControlStateHighlighted|UIControlStateDisabled|UIControlStateSelected|UIControlStateFocused));

		[self setState:newState];
	}
}


- (BOOL) isHighlighted
{
	return( getStateBit( self, UIControlStateHighlighted));
}


- (void) setHighlighted:(BOOL) flag
{
	setStateBit( self, UIControlStateHighlighted, flag);
}


- (BOOL) isDisabled
{
	return( getStateBit( self, UIControlStateDisabled));
}


- (void) setDisabled:(BOOL) flag;
{
	setStateBit( self, UIControlStateDisabled, flag);
}


- (BOOL) isSelected;
{
	return( getStateBit( self, UIControlStateSelected));
}


- (void) setSelected:(BOOL) flag;
{
	setStateBit( self, UIControlStateSelected, flag);
}

PROTOCOLCLASS_END()

