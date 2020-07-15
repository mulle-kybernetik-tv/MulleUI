//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "UIButton.h")
#  import "UIButton.h"
# endif
#endif

#import "import.h"

@class MulleMenu;

//
// Puts up a menu in the menuplane of its window. Positions the menu as it
// sees fit.
// {
//    title :   value,
//    foo   :   value,
// }
@interface MullePopUpButton : UIButton
{
   MulleMenu    *_menu;  // temporary as long as the menu exists on screen

}

- (id) representedValue;

- (void) removeAllItems;
- (void) addMenuItemWithTitleCString:(char *) s
                   representedObject:(id) obj;

@end
