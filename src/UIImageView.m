//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIImageView.h"

#import "import-private.h"

#import "UIImage.h"
#import "MulleImageLayer.h"


@implementation UIImageView


+ (Class) layerClass
{
   return( [MulleImageLayer class]);
}


- (instancetype) initWithImage:(UIImage *) image
{
   CALayer   *layer;
   Class     layerClass;
   CGRect    frame;

   layerClass = [image preferredLayerClass];
   if( ! layerClass)
      layerClass = [[self class] layerClass];
   
   frame.origin = CGPointMake( 0, 0);
   frame.size   = [image size];

   layer = [[[layerClass alloc] initWithImage:image] autorelease];
   [layer setFrame:frame];
   self  = [self initWithLayer:layer];

   return( self);
}

@end
