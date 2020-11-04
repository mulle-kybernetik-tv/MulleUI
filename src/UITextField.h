//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "UIView.h")
#  import "UIView.h"
# endif
#endif

#import "import.h"

#import "UIControl.h"
#import "MulleTextLayer.h" // expose those properties and methods (forward)


//
// https://stackoverflow.com/questions/1345561/how-to-create-a-multiline-uitextfield
// UITextField only does one line of text.
//
@interface UITextField : UIView < UIControl>
{
   UIControlIvars;

   MulleTextLayer   *_titleLayer;
   CALayer          *_titleBackgroundLayer;
}


UIControlProperties;

- (void) setTitleCString:(char *) s;
- (char *) titleCString;

// UIControlState can be:
//
//    UIControlStateNormal
//    UIControlStateSelected
//    UIControlStateNormal|UIControlStateDisabled
//    UIControlStateSelected|UIControlStateDisabled
//
// Highlighting will use the inverse of the current selection state
//

- (void) setupLayersWithFrame:(CGRect) frame;
- (void) layoutLayersWithFrame:(CGRect) frame;

// subclasses can style by overriding these
+ (MulleTextLayer *) titleLayerWithFrame:(CGRect) rect;
+ (CALayer *) mulleTitleBackgroundLayerWithFrame:(CGRect) rect;

- (CGRect) mulleInsetTextLayerFrameWithFrame:(CGRect) frame;

- (void) insertCharacter:(unichar) c;
- (void) backspaceCharacter;

- (void) paste;

@end


@interface UITextField ( Forward)

/// ??
@property( assign) struct MulleIntegerPoint  cursorPosition;

- (struct MulleIntegerPoint) maxCursorPosition;

- (void) insertCharacter:(unichar) c;
- (void) backspaceCharacter;

- (void) getCursorPosition:(struct MulleIntegerPoint *) cursor_p;

@end
