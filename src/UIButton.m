#import "UIButton.h"

#import "UIImage.h"
#import "CALayer.h"
#import "MulleTextLayer.h"
#import "UIView+UIResponder.h"
#import "UIEdgeInsets.h"

// implemented by UIResponder protocol class, but mulle-clang can't figure
// it out (yet)
@interface UIView( ProtocolClass)

- (void) toggleState;

@end


@implementation UIButton

#define BORDER_WIDTH    3.0
#define TEXT_MARGIN     1.0
#define CORNER_RADIUS   8
              
- (instancetype) initWithLayer:(CALayer *) layer 
{
   CGRect         frame;
   CGRect         textLayerFrame;
   UIEdgeInsets   insets;

   self = [super initWithLayer:layer];
   if( ! self)
      return( self);

   frame          = [self frame];
   insets         = UIEdgeInsetsMake( BORDER_WIDTH + TEXT_MARGIN, 
                                      BORDER_WIDTH + TEXT_MARGIN, 
                                      BORDER_WIDTH + TEXT_MARGIN,
                                      BORDER_WIDTH + TEXT_MARGIN);
   textLayerFrame = UIEdgeInsetsInsetRect( frame, insets);
 
   _titleLayer = [[[MulleTextLayer alloc] initWithFrame:textLayerFrame] autorelease];

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

   // [self setTitleCString:"Title"];
   [_titleLayer setFontName:"sans"];
   //
   // Even with pixel size full frame, we won't cover the button. I suspect
   // because the font leaves vertical room for a previous row of text
   // Fontsize is probably usefully set by the user anyway 
   [_titleLayer setFontPixelSize:frame.size.height / 2];
   [_titleLayer setBackgroundColor:getNVGColor( 0x0000000)];
   [_titleLayer setTextColor:getNVGColor( 0x000000FF)];
   // set this as we are transparent
   [_titleLayer setTextBackgroundColor:getNVGColor( 0xFFFF00FF)];
   [_titleLayer setHidden:YES];

   _titleBackgroundLayer = [[[CALayer alloc] initWithFrame:frame] autorelease];
   [_titleBackgroundLayer setBackgroundColor:getNVGColor( 0x00FFFFFF)];
   // this ensures that the background fill does not antialias into the
   // outside
   [_titleBackgroundLayer setBorderWidth:1.5];
   [_titleBackgroundLayer setBorderColor:getNVGColor( 0x7F7FFFFF)];
   [_titleBackgroundLayer setCornerRadius:CORNER_RADIUS];
   [self addLayer:_titleBackgroundLayer];
   [self addLayer:_titleLayer];

   [self hideUnhideTitleLayers];

   return( self);
}

- (void) hideUnhideTitleLayers
{
   char  *s;
   BOOL   visible;

   s = [_titleLayer cString];

   visible = s && *s;
   
   [_titleLayer setHidden:! visible];
   [_titleBackgroundLayer setHidden:! visible];
   [_titleLayer setCString:visible ? s : ""];
}


- (void) setTitleCString:(char *) s
{
   [_titleLayer setCString:s];
   [self hideUnhideTitleLayers];
}

- (char *) titleCString
{
   return( [_titleLayer cString]);
}


- (void) getBackgroundImageIVar:(UIImage ***) ivar
{
  *ivar = _backgroundImage;
}

- (void) setBackgroundImage:(UIImage *) image
{
   CALayer   *layer;
   Class     preferredLayerClass;
   Class     layerClass;

   assert( ! image || [image isKindOfClass:[UIImage class]]);

   if( ! image)
      return;

   // hackish cast, fix later
   layer               = [self mainLayer];
   layerClass          = [layer class];
   preferredLayerClass = [image preferredLayerClass];

   if( [layerClass isSubclassOfClass:preferredLayerClass])
      [(CALayer<CAImageLayer> *) layer setImage:image];
   else
      abort();
}


- (void) reflectState
{
   UIControlState   state;
   UIControlState   fallbackState;
   CGRect           frame;
   UIImage          *image;
   
   state = [self state];

   if( state & UIControlStateSelected)
   {
      [_titleBackgroundLayer setBackgroundColor:getNVGColor( 0xD0D0D0FF)];
      [_titleLayer setTextBackgroundColor:getNVGColor( 0xD0D0D0FF)];
   }
   else
   {
      [_titleBackgroundLayer setBackgroundColor:getNVGColor( 0xFFFFFFFF)];
      [_titleLayer setTextBackgroundColor:getNVGColor( 0xFFFFFFFF)];
   }

   image         = [self backgroundImageForState:state];
   fallbackState = state & ~UIControlStateDisabled;
   if( ! image)
   {
      image = [self backgroundImageForState:fallbackState];
      fallbackState &=~UIControlStateSelected;
   }
   if( ! image)
      image = [self backgroundImageForState:fallbackState];
   [self setBackgroundImage:image];
}

// use compatible code
- (void) toggleState
{
   //
   // target/action has been called already by UIControl
   //
   [super toggleState];
   [self reflectState];
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

@end