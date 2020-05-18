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
- (void) layoutSelfInBounds:(CGRect) bounds; // does the autoresize, margins
- (void) endLayout;

// yoga uses this to its layout
- (enum UILayoutStrategy) layoutStrategy;


@end
