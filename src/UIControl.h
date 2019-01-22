#import <MulleObjC/MulleObjC.h>


@class UIEvent;

enum UIControlStateBits 
{
	UIControlStateNormal      = 0x0,
	UIControlStateHighlighted = 0x1,
	UIControlStateDisabled    = 0x2,
	UIControlStateSelected    = 0x4,
	UIControlStateFocused	  = 0x8
};


typedef NSUInteger    UIControlState;


// protocolclass! @protocolclass 
@class UIControl;
// formal protocol part
@protocol UIControl

typedef UIEvent       *UIControlClickHandler( id <UIControl> control, 
								  							 UIEvent *event);
@property( assign) UIControlState  state;
@property( assign) id  target;
@property( assign) SEL action;
@property( assign) UIControlClickHandler  *click;

@end


@interface UIControl < UIControl>
@end

// informal protocol part
@interface UIControl( UIControl)

- (UIEvent *) mouseUp:(UIEvent *) event;

@end



#define UIControlIvars \
   UIControlState           _state;	\
   id                      _target;	\
   UIControlClickHandler   *_click;	\
   SEL                     _action