//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "UIScrollView.h")
#  import "UIScrollView.h"
# endif
#endif

#import "import.h"

//
// TODO: will be a UIScrollView later, which can't be a UIControl
//
#import "UIControl.h"

@class MulleTextLayer;

//
// IDEA 1:
//
// Each span of a string with the same font attributes is managed in
// its own MulleTextLayer. 
// 
//    +---------------------------+
//    | #textlayer0# #textlayer1# |
//    | #      textlayer2       # |
//    | # textlayer 3 #           |
//    | #textlayer4# #textlayer5# |
//    +---------------------------+
//
// Possibly each textlayer has a different height, depending on the font 
// being used.
// 
//
// IDEA 2:
//
// Extend MulleTextLayer to support multiple font attributes. Then there
// would only be a single textlayer for each line.
// 
//    +---------------------------+
//    | #      textlayer0       # |
//    | #      textlayer1       # |
//    | #      textlayer2 #       |
//    | #      textlayer3       # |
//    +---------------------------+
//
// Pro:  MulleTextLayer with multiple fonts is more compatible I think ?
// Cons: MulleTextLayer gets significantly more complicated
//
// ------------------
//
// The big problem: embedded images, where one would want to have multiple
// textlayers beside it. That's then DTP, and beyond the scope of this class.
// A embedded image, would take up a line and could be followed by another
// textlayer. Conceivably that textlayer might have multiple lines though..
// But you couldn't vertically stack multiple textlayers, it would all be on
// the same line.
// 
// So someone has to manage the text, splice it into lines. Keep the line
// height information and feed the UITextView with the appropriate textlayers.
// Textlayers that are scrolled off, can be reclaimed.
//
@interface UITextView : UIView < UIControl>
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

- (void) paste;

@end


@interface UITextView ( Forward)

@property( assign) NSUInteger  cursorPosition;

- (void) insertCharacter:(unichar) c;
- (void) backspaceCharacter;

@end
