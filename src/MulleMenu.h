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


@class UIScrollView;
@class UIStackView;
@class MulleMenuButton;

//
// MulleMenu will send target/action if a click or ESC happens outside of
// it's menu. The menu buttons should each have their own target/action.
//
@interface MulleMenu : UIView <UIControl>
{
   UIControlIvars;

   UIScrollView   *_scrollView;
   UIStackView    *_stackView;
}

UIControlProperties;

// @property( assign) UIView   *referenceView;
// @property( assign) CGPoint  anchorPoint;
// 
- (void) addMenuButton:(MulleMenuButton *) button;

@end


/*
 * UIPopUpButton
 * 
 * -> list of values  (unknown)    MulleMenu
 *                                 ->  buttons
 *                                     -> actions  ... UIPopUpButton
 * 
 * ---
 * 
 * If you have a list of values, you create the MulleMenu dynamically. Then
 * the event handling with action/target will be done by the UIPopUpButton.
 * The selected value will be retrieved from the MulleMenu button and stored
 * and show in the UIPopUpButton.
 * 
 * Conversely if the UIPopUpButton has just a MulleMenu that shows up and
 * hides, then the value of the UIPopUpButton will have to be set by a third
 * party that handles the MulleMenu events.
 * In that case, the UIPopUpButton is just really a UIButton with a MulleMenu 
 * and doesn't need a special subclass (except maybe for positioning the menu)
*/