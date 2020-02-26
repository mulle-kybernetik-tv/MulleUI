#import "UIButton.h"

#import "UIImage.h"
#import "CALayer.h"
#import "MulleTextLayer.h"
#import "UIView+UIResponder.h"


// implemented by UIResponder protocol class, but mulle-clang can't figure
// it out (yet)
@interface UIView( ProtocolClass)

- (void) toggleState;

@end


@implementation UIButton

- (instancetype) initWithLayer:(CALayer *) layer 
{
   self = [super initWithLayer:layer];
   if( self)
   {
      _titleLayer = [[[MulleTextLayer alloc] initWithFrame:[self frame]] autorelease];

      //
      // if we composite on top of an image and leave the background 
      // transparent, then the cleartype font looks very ugly. It needs a
      // solid background. (White on black seems best ?)
      //
      // Idea: text layer could shrink to minimum required size and then center
      //       itself.
      // 
      //       Do not use cleartype font for UIButton, if the background is not
      //       opaque ?
      //

      [self setTitleCString:"Title"];
      [_titleLayer setFontName:"sans"];
      [_titleLayer setFontPixelSize:14.0 * 2];
      [_titleLayer setBackgroundColor:getNVGColor( 0x000000FF)];
      [_titleLayer setTextColor:getNVGColor( 0xFFFFFFFFF)];

      [self addLayer:_titleLayer];
   }
   return( self);
}

- (void) setTitleCString:(char *) s
{
   BOOL   visible;

   visible = s && *s;
   
   [_titleLayer setHidden:! visible];
   [_titleLayer setCString:visible ? s : ""];
}

- (char *) titleCString
{
   return( [_titleLayer CString]);
}


// use compatible code
- (void) toggleState
{
	UIControlState   state;
	CGRect           frame;
	UIImage          *image;

   //
	// target/action has been called already by UIControl
	//
   [super toggleState];

   state = [self state];
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