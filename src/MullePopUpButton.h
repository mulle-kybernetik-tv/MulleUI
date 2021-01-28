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
@class MulleMenuButton;

//
// Puts up a menu in the menuplane of its window. Positions the menu as it
// sees fit.
// {
//    title :   value,
//    foo   :   value,
// }
//
// TODO: Need a selectedTitle happening, need a string for no selection.
//
@interface MullePopUpButton : UIButton
{
   CALayer           *_disclosureLayer;
   char              **_titles;
   NSUInteger        _titlesCount;

   NSUInteger        _selectedIndex;     // NSNotFound == no selection!
   char              *_noSelectionTitle;
   MulleMenuButton   *_clickedButton;
}

@property( retain) MulleMenu   *menu;

//- (id) representedValue;

- (void) removeAllItems;
- (void) addMenuItemWithTitleCString:(char *) s
                   representedObject:(id) obj;

- (void) setTitlesCStrings:(char **) titles
                     count:(NSUInteger) count;

- (MulleMenuButton *) clickedButton;

@end
