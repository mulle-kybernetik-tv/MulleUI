//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIResponder.h"
#import "UIControl.h"

@class UIImage;

//
// a MulleGenericObject contains a dictionary where to place key/values
// that way it can be easily expanded like a JavaScript object
// You can replace it with NSObject if you want
//
#define MulleControlBackgroundImageIvars \
   UIImage   *_backgroundImage[ 4]

#define MulleControlBackgroundImageProperties

PROTOCOLCLASS_INTERFACE( MulleControlBackgroundImage, UIControl, UIResponder)

- (void) getBackgroundImageIVar:(UIImage ***) ivar;

@optional
- (UIImage *) backgroundImageForState:(UIControlState) state;
- (void) setBackgroundImage:(UIImage *) image
                   forState:(UIControlState) state;
- (void) setBackgroundImage:(UIImage *) image;

PROTOCOLCLASS_END();

