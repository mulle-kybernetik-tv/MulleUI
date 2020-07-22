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
// We forward the menubutton as the sender, ATM. This is wrong the receiver
// should ask the MullePopUpButton for the selected title or value...
//
- (void) menuButtonClicked:(id) sender
{
   UIControlClickHandler  *click;
   SEL                    sel;
   MulleMenu              *menu;

   click = [self click];
   if( click)
      (*click)( sender, nil);

   if( (sel = [self action]))
   {
      [[self target] performSelector:sel
                          withObject:sender];
   }

   menu = [self menu];
   [menu setHidden:YES];   
}


- (void) outsideMenuClicked:(id) sender
{
   fprintf( stderr, "%s\n", __PRETTY_FUNCTION__);

   [[self menu] setHidden:YES];
}


@end
