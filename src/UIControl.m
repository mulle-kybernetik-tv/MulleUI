#import "UIControl.h"


@implementation UIControl

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


MULLE_C_NEVER_INLINE
static UIEvent  *consumeEventIfDisabled( UIControl *self, UIEvent *event)
{
	UIControlState   state;

   // a disable control swallows events
 	state = [self state];
	if( state & UIControlStateDisabled)
		return( nil);

   return( event);   
}


// @method_alias( mouseUp:, mouseDown:);

- (UIEvent *) mouseDown:(UIEvent *) event
{
	event = consumeEventIfDisabled( self, event);
	// event was handled if nil
	if( ! event)
	   return( event);   

   fprintf( stderr, "%s: %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
   [self becomeFirstResponder];
   // we alway snarf up the mouseDown: event (why pass to parent ?)
   return( nil);
}


- (UIEvent *) mouseUp:(UIEvent *) event
{
   UIControlClickHandler  *click;
   SEL                    sel;

	event = consumeEventIfDisabled( self, event);
	// event was handled if nil
	if( ! event)
   {
      assert( ! [self isFirstResponder] && "mouseUp: overridden, but mouseDown: made us first responder");
	   return( event);
   }

   fprintf( stderr, "%s: %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
   [self resignFirstResponder];
   if( click = [self click])
      event = (*click)( self, event);
   if( event && (sel = [self action]))
      [[self target] performSelector:sel
                          withObject:self];
   return( event);
}


static inline BOOL   getStateBit( UIControl *self, enum UIControlStateBit bit)
{
	UIControlState   state;

	state = [self state];
	return( state & bit ? YES : NO);
}


static void   setStateBit( UIControl *self, enum UIControlStateBit bit, BOOL flag)
{
	UIControlState   state;
	UIControlState   newState;

	state = [self state];
	if( flag)
		newState = state | bit;
	else
		newState &= state | ~bit;
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
		assert( state != UIControlStateHighlighted|UIControlStateDisabled);
		assert( state != UIControlStateHighlighted|UIControlStateDisabled|UIControlStateSelected);
		assert( state != UIControlStateDisabled|UIControlStateFocused);
		assert( state != UIControlStateHighlighted|UIControlStateDisabled|UIControlStateFocused);
		assert( state != UIControlStateDisabled|UIControlStateSelected|UIControlStateFocused);
		assert( state != UIControlStateHighlighted|UIControlStateDisabled|UIControlStateSelected|UIControlStateFocused);

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
@end
