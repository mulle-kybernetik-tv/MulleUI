#import "UIButton.h"

#import "UIImage.h"
#import "CALayer.h"
#import "UIView+UIResponder.h"


@implementation UIButton



// use compatible code
- (void) toggleState
{
	UIControlState   state;
	CGRect           frame;
	UIImage          *image;
   	//
	// target/action has been called already by UIControl
	//
	state = [self state];
	if( state & UIControlStateSelected)
		state &= ~UIControlStateSelected;
	else
		state |= UIControlStateSelected;
	[self setState:state];

	image = [self backgroundImageForState:state];
	if( ! image)
	{
		state &=~UIControlStateDisabled;
		image = [self backgroundImageForState:state];
	}
	if( ! image)
	{
		state &=~UIControlStateSelected;
		image = [self backgroundImageForState:state];
	}
	[self setBackgroundImage:image];   
}

- (BOOL) becomeFirstResponder
{
   if( [super becomeFirstResponder])
   {
      fprintf( stderr, "become\n");
      [self toggleState];
      return( YES);
   }
   return( NO);
}


- (BOOL) resignFirstResponder
{
   if( [super resignFirstResponder])
   {
      fprintf( stderr, "resign\n");
      [self toggleState];
      return( YES);
   }
   return( NO);
}


static NSUInteger   imageIndexForControlState( UIControlState state)
{
	switch( state) 
	{
	case UIControlStateNormal                          : return( 0);
	case UIControlStateSelected                        : return( 1);
	case UIControlStateNormal|UIControlStateDisabled   : return( 2);
	case UIControlStateSelected|UIControlStateDisabled : return( 3);
	}
	abort();
}


- (UIImage *) backgroundImageForState:(UIControlState) state
{
	NSUInteger   index;

	if( state & UIControlStateHighlighted)
		state ^= UIControlStateSelected;

	state &= UIControlStateSelected|UIControlStateDisabled;
	index = imageIndexForControlState( state);
	return( self->_backgroundImage[ index]);
}


- (void) setBackgroundImage:(UIImage *) image 
                   forState:(UIControlState) state
{
	NSUInteger    index;

	index = imageIndexForControlState( state);

	[self->_backgroundImage[ index] autorelease];
	self->_backgroundImage[ index] = [image retain];
}


- (void) setBackgroundImage:(UIImage *) image
{
	CALayer   *layer;
	Class     preferredLayerClass;
	Class     layerClass;

	assert( ! image || [image isKindOfClass:[UIImage class]]);
	
	if( ! image)
		return;
	
	layer               = _mainLayer;
	layerClass          = [layer class];
	preferredLayerClass = [image preferredLayerClass];

	if( [layerClass isSubclassOfClass:preferredLayerClass])
		[(CALayer<CAImageLayer> *) layer setImage:image];
	else
		abort();
}

@end