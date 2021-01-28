//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MullePopUpButton+UIEvent.h"

#import "import-private.h"

#import "MullePopUpButton+MulleMenu.h"



@implementation MullePopUpButton ( UIEvent)


- (UIEvent *) performClickAndTargetActionCallbacks:(UIEvent *) event
{
   MulleMenu   *menu;

   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);

   menu = [self menu];
   [self positionMenu:menu];
   [menu setHidden:NO];
   return( nil);
}


//
// forward this action to our target/action and clickHandler customers
// because we don't have an event, we send "nil"
// The sender is the actual button clicked, not the menu
//
- (void) menuButtonClicked:(id) sender
{
   UIControlClickHandler  *click;
   SEL                    sel;
   MulleMenu              *menu;

   _clickedButton = sender;
   {
      click = [self click];
      if( click)
         (*click)( self, nil);

      if( (sel = [self action]))
      {
         [[self target] performSelector:sel
                           withObject:self];
      }
   }
   _clickedButton = nil;

   menu = [self menu];
   [menu setHidden:YES];
}


- (void) outsideMenuClicked:(id) sender
{
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);

   [[self menu] setHidden:YES];
}


@end
