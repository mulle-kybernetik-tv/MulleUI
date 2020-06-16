//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local UIView over one in import.h
#ifdef __has_include
# if __has_include( "UIView.h")
#  import "UIView.h"
# endif
#endif

// we wan't "import.h" always anyway
#import "import.h"


/* 
 * A UIView has some properties that define its wishes how to be placed
 * into a superview. First of all is the frame. If the autoresizingMask of
 * the view is UIViewAutoresizingNone, then the frame is absolute and should
 * not be changed ever by the superview.
 *
 * Otherwise the UIView can indicate if it wants to be stretched 
 * in a horizontal or vertical fashion or both.
 *
 * A stretched view will cover the entire given bounds. The given bounds are
 * reduced by the margins though. That effectively creates some distance from
 * the bounds.
 *
 * The non stretchable dimension can indicate a preferred sticking point,
 * which could be top/left for example.
 */ 


typedef enum 
{
   UILayoutConstraintAxisVertical   = MulleVerticalIndex,  
   UILayoutConstraintAxisHorizontal = MulleHorizontalIndex
} UILayoutConstraintAxis;


@interface UIView( Layout)

- (void) setNeedsLayout;    // use this to touch up all hierarchy
- (void) _setNeedsLayout; 


- (CGSize) sizeThatFits:(CGSize) size;

//
// You do not need not to call super in UIView subclasses, if you manually
// layout everything
// 
//- (void) layoutSubviews;

- (void) startLayoutWithFrameInfo:(struct MulleFrameInfo *) info;
- (void) layout;
- (void) layoutIfNeeded;
- (void) layoutSubview:(UIView *) view
              inBounds:(CGRect) bounds
      autoresizingMask:(UIViewAutoresizing) autoresizingMask;
- (void) endLayout;

// yoga uses this to its layout
- (enum UILayoutStrategy) layoutStrategy;


@end
