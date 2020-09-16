#import "import.h"

#import "UIResponder.h"


//
// keeping with NSView event handling, we keep the UIEvent subclasses somewhat
// opaque in the method signatures. More or less for readability. Technically
// You can cast the events to the proper subclass (i.e. UIMouseButtonEvent
// for mouseDown: etc.)
//
@class UIEvent;


enum UIControlStateBit
{
	UIControlStateNormal      = 0x0,
	UIControlStateHighlighted = 0x1,
	UIControlStateDisabled    = 0x2,
	UIControlStateSelected    = 0x4,
	UIControlStateFocused	  = 0x8
};

/* 
Possible state combinations.
Disable and highlight can't coexist.
Disable and focus can't coexist.
Assume focus is painted.
Highlight, will show normal image when selected and 
selected image when deselected.

 Highlight |  Disable  |   Select  |   Focus   | Image Choice
-----------|-----------|-----------|-----------|--------
     0     |     0     |     0     |     0     | Normal
     1     |     0     |     0     |     0     | Select
     0     |     1     |     0     |     0     | DisableNormal
     1     |     1     |     0     |     0     | *impossible*
     0     |     0     |     1     |     0     | Select
     1     |     0     |     1     |     0     | Normal
     0     |     1     |     1     |     0     | DisableSelect
     1     |     1     |     1     |     0     | *impossible*
     0     |     0     |     0     |     1     | Normal
     1     |     0     |     0     |     1     | Select
     0     |     1     |     0     |     1     | *impossible*
     1     |     1     |     0     |     1     | *impossible*
     0     |     0     |     1     |     1     | Select
     1     |     0     |     1     |     1     | Normal
     0     |     1     |     1     |     1     | *impossible*
     1     |     1     |     1     |     1     | *impossible*
*/

typedef NSUInteger    UIControlState;

// put these into your UIControl adopting class interface ivars
#define UIControlIvars              \
   UIControlState           _state;	\
   UIControlClickHandler   *_click;	\
   id                      _target;	\
   SEL                     _action

// put these into your UIControl adopting class property block

#define UIControlProperties                         \
   @property( assign) UIControlState  state;        \
   @property( assign) id  target;                   \
   @property( assign) SEL action;                   \
   @property( assign) UIControlClickHandler  *click

//
// A UIControl translates event into target/Action or click Events. Though
// it provides states for selection and highlighting. It does not change them
// on events by itself (well highlighting it does currently, but should it ?)
//
PROTOCOLCLASS_INTERFACE( UIControl, UIResponder)

// TODO: put a userinfo into this ?
typedef UIEvent   *UIControlClickHandler( id <UIControl> control, 
                                          UIEvent *event);

UIControlProperties;

@optional 

- (UIEvent *) mouseUp:(UIEvent *) event;

- (UIEvent *) consumeMouseUp:(UIEvent *) event;
- (UIEvent *) consumeMouseDown:(UIEvent *) event;
- (UIEvent *) performClickAndTargetActionCallbacks:(UIEvent *) event;


// these are convenience for state, don't override these
// overide state if needed

- (BOOL) isHighlighted;
- (void) setHighlighted:(BOOL) flag;
- (BOOL) isDisabled;
- (void) setDisabled:(BOOL) flag;
- (BOOL) isSelected;
- (void) setSelected:(BOOL) flag;

- (char *) cStringDescription;

/* utilities for implementors */
- (void) mulleToggleSelectedState;
- (void) mulleToggleHighlightedState;

PROTOCOLCLASS_END()


