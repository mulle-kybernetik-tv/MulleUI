//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UITextField.h"

#import "import-private.h"

#import "MulleTextLayer.h"


@implementation UITextField

#define BORDER_WIDTH    1.5
#define TEXT_MARGIN     1.0
#define CORNER_RADIUS   8

+ (MulleTextLayer *) titleLayerWithFrame:(CGRect) frame
 {
    MulleTextLayer   *layer;

   layer = [[[MulleTextLayer alloc] initWithFrame:frame] autorelease];

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
   [layer setFontName:"sans"];
   //
   // Even with pixel size full frame, we won't cover the button. I suspect
   // because the font leaves vertical room for a previous row of text
   // Fontsize is probably usefully set by the user anyway 
   [layer setFontPixelSize:frame.size.height / 2];
   [layer setBackgroundColor:getNVGColor( 0x0000000)];
   [layer setTextColor:getNVGColor( 0x000000FF)];
   // set this as we are transparent
   [layer setTextBackgroundColor:getNVGColor( 0xFFFF00FF)];

   return( layer);
}

/* Selection and highlight colors are currently hardcoded in 
 * UIButton+UIResponder.
 */
+ (CALayer *) mulleTitleBackgroundLayerWithFrame:(CGRect) frame
{
   CALayer   *layer;

   layer = [[[CALayer alloc] initWithFrame:frame] autorelease];

   [layer setBackgroundColor:getNVGColor( 0xFFFFFFFF)];
   // this ensures that the background fill does not antialias into the
   // outside
   [layer setBorderWidth:BORDER_WIDTH];
   [layer setBorderColor:getNVGColor( 0x7F7FFFFF)];
   [layer setCornerRadius:CORNER_RADIUS];
   [layer setCStringName:"UIButton titleBackgroundLayer"];
   return( layer);
}

- (void) setupLayersWithFrame:(CGRect) frame
{
   Class   cls;

   cls = [self class];

   _titleBackgroundLayer = [cls mulleTitleBackgroundLayerWithFrame:frame];
   [_titleBackgroundLayer setCStringName:"UIButton titleBackgroundLayer"];
   [self addLayer:_titleBackgroundLayer];

   _titleLayer = [cls titleLayerWithFrame:frame];
   [_titleLayer setCStringName:"UIButton titleLayer"];
   [self addLayer:_titleLayer];
}


- (instancetype) initWithLayer:(CALayer *) layer 
{
   CGRect         frame;
   CGRect         textLayerFrame;
   UIEdgeInsets   insets;

   self = [super initWithLayer:layer];
   if( ! self)
      return( self);

   // layout later
   frame = [layer frame];

   [self setupLayersWithFrame:frame];
   [self layoutLayersWithFrame:frame];

   return( self);
}


#if DEBUG
- (void) renderWithContext:(CGContext *) context
{
   [super renderWithContext:context];
}
#endif


//
// When using Yoga to do the layout. It will change the frame of the
// UIButton. This frame is identical to the frame of the mainLayer.
// But the other layers are not affected.
// One could mark the button as needing a layout, but we are doing this
// immediately. Note that Yoga is the layouting step and doing another
// layouting is kinda weird.
//
- (CGRect) mulleInsetTextLayerFrameWithFrame:(CGRect) frame
{
   UIEdgeInsets   insets;
   double         borderWidth;

   borderWidth = [_titleBackgroundLayer borderWidth];
   insets = UIEdgeInsetsMake( borderWidth / 2 + TEXT_MARGIN, 
                              borderWidth / 2 + TEXT_MARGIN, 
                              borderWidth / 2 + TEXT_MARGIN,
                              borderWidth / 2 + TEXT_MARGIN);

   return( UIEdgeInsetsInsetRect( frame, insets));
}


- (void) layoutLayersWithFrame:(CGRect) frame
{
   CGRect   textLayerFrame;

   textLayerFrame = [self mulleInsetTextLayerFrameWithFrame:frame];   
   [_titleLayer setFrame:textLayerFrame];
   [_titleBackgroundLayer setFrame:frame];
}


- (void) setFrame:(CGRect) frame
{
   [super setFrame:frame];
   assert( CGRectEqualToRect( [[self layer] frame], frame));
   [self layoutLayersWithFrame:frame];
}


- (void *) forward:(void *) param
{
   id    target;

   target = _mainLayer;
   switch( _cmd)
   {
   case @selector( isEditable)                : 
   case @selector( setEditable:)              : 

   case @selector( fontPixelSize)             : 
   case @selector( setFontPixelSize:)         : 

   case @selector( cursorPosition)            : 
   case @selector( setCursorPosition:)        :

   case @selector( cString)                   :  
   case @selector( setCString:)               :  
   case @selector( setCursorPositionToPoint:) :
      target = _titleLayer;
      break;
   }
   return( mulle_objc_object_inlinecall_variablemethodid( target,
                                                          (mulle_objc_methodid_t) _cmd,
                                                          param));
}


- (void) insertCharacter:(unichar) c
{
   char         *s;
   NSUInteger   cursorPosition;

   s              = [self cString];
   cursorPosition = [self cursorPosition];
   s = MulleObjC_asprintf( "%.*s%C%s", 
               (int) cursorPosition, 
               s, 
               c, 
               &s[ cursorPosition]);
   [self setCString:s];
   [self setCursorPosition:cursorPosition+1];
}

- (void) backspaceCharacter
{
   char         *s;
   NSUInteger   cursorPosition;

   s              = [self cString];
   cursorPosition = [self cursorPosition];
   if( ! cursorPosition)
      return;

   s = MulleObjC_asprintf( "%.*s%s", 
               (int) cursorPosition - 1, 
               s, 
               &s[ cursorPosition]);
   [self setCString:s];
   [self setCursorPosition:cursorPosition-1];
}


@end