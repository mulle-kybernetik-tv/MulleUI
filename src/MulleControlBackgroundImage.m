//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//

#import "MulleControlBackgroundImage.h"

#import "import-private.h"

#import "UIImage.h"
#import "CALayer.h"
#import "UIView.h"


PROTOCOLCLASS_IMPLEMENTATION( MulleControlBackgroundImage)

static NSUInteger   imageIndexForControlState( UIControlState state)
{
   switch( state)
   {
   case UIControlStateNormal                          : return( 0);
   case UIControlStateSelected                        : return( 1);
   case UIControlStateNormal|UIControlStateDisabled   : return( 2);
   case UIControlStateSelected|UIControlStateDisabled : return( 3);
   }
   abort();
}


- (UIImage *) backgroundImageForState:(UIControlState) state
{
   NSUInteger   index;
   UIImage      **ivar;

   [self getBackgroundImageIVar:&ivar];

   if( state & UIControlStateHighlighted)
      state ^= UIControlStateSelected;

   state &= UIControlStateSelected|UIControlStateDisabled;
   index = imageIndexForControlState( state);
   return( ivar[ index]);
}


- (void) setBackgroundImage:(UIImage *) image
                   forState:(UIControlState) state
{
   NSUInteger    index;
   UIImage       **ivar;

   [self getBackgroundImageIVar:&ivar];
   index = imageIndexForControlState( state);

   [ivar[ index] autorelease];
   ivar[ index] = [image retain];
}


- (void) setBackgroundImage:(UIImage *) image
{
   CALayer   *layer;
   Class     preferredLayerClass;
   Class     layerClass;

   assert( ! image || [image isKindOfClass:[UIImage class]]);

   if( ! image)
      return;

   // hackish cast, fix later
   layer               = [(UIView *) self mainLayer];
   layerClass          = [layer class];
   preferredLayerClass = [image preferredLayerClass];

   if( [layerClass isSubclassOfClass:preferredLayerClass])
      [(CALayer<CAImageLayer> *) layer setImage:image];
   else
      abort();
}

PROTOCOLCLASS_END();

