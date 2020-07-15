//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MulleMenuButton.h"

#import "import-private.h"



@implementation MulleMenuButton


+ (CALayer *) mulleTitleBackgroundLayerWithFrame:(CGRect) frame
{
   CALayer   *layer;

   layer = [[[CALayer alloc] initWithFrame:frame] autorelease];

   [layer setBackgroundColor:getNVGColor( 0xFFFFFFFF)];
   // this ensures that the background fill does not antialias into the
   // outside
   [layer setBorderWidth:1.0];
   [layer setBorderColor:getNVGColor( 0x7F7FFFFF)];
   [layer setCornerRadius:0.0];
   [layer setCStringName:"UIButton titleBackgroundLayer"];
   return( layer);
}

@end
